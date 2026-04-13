;;; -*- lexical-binding: t; -*-

(defvar pb/use-vterm
  (and (not (eq system-type 'windows-nt))
       (require 'vterm nil t)))

(defvar pb/vterm-shell nil)

(defvar pb/language-config
  '((c
     :display-name "C"
     :mode         simpc-mode
     :extension    ".c"
     :compilers    ("gcc" "cc")
     :template     "\
#include <stdio.h>

int main(void) {
    printf(\"Hello, world!\\n\");
    return 0;
}
")
    (rust
     :display-name "Rust"
     :mode         rust-mode
     :extension    ".rs"
     :compilers    ("rustc")
     :template     "\
fn main() {
    println!(\"Hello, world!\");
}
")
    (javascript
     :display-name "JavaScript"
     :mode         js-mode
     :extension    ".js"
     :runner       ("node" "nodejs")
     :template     "\
console.log(\"Hello, world!\");
")
    (python
     :display-name "Python"
     :mode         python-mode
     :extension    ".py"
     :runner       ("python3" "python")
     :template     "\
print(\"Hello, world!\")
")
    (haskell
     :display-name "Haskell"
     :mode         haskell-mode
     :extension    ".hs"
     :runner       ("runghc" "runhaskell")
     :template     "\
main :: IO ()
main = putStrLn \"Hello, world!\"
")
    (julia
     :display-name "Julia"
     :mode         julia-mode
     :extension    ".jl"
     :runner       ("julia")
     :template     "\
println(\"Hello, world!\")
")))

(defvar pb/lang-openers (make-hash-table :test #'equal))

(defun pb/find-compiler (compilers)
  (cl-find-if #'executable-find compilers))

(defun pb/find-runner (runners)
  (cl-find-if #'executable-find runners))

(defun pb/probe-name (lang)
  (format "*probe-%s*" (symbol-name lang)))

(defun pb/shell-name (lang)
  (format "*probe-%s-shell*" (symbol-name lang)))

(defun pb/lang-from-probe-name (buf-name)
  (when (string-match "\\*probe-\\([^*]+\\)\\*" buf-name)
    (intern (match-string 1 buf-name))))

(defun pb/work-dir (lang)
  (let ((dir (expand-file-name
              (symbol-name lang)
              (expand-file-name "pb" temporary-file-directory))))
    (make-directory dir t)
    dir))

(defun pb/src-file (lang config)
  (expand-file-name (concat "probe" (plist-get config :extension))
                    (pb/work-dir lang)))

(defun pb/run-command (lang config)
  (let ((src (pb/src-file lang config)))
    (if-let ((runners (plist-get config :runner))
             (runner  (pb/find-runner runners)))
        (format "%s %s"
                (shell-quote-argument runner)
                (shell-quote-argument src))
      (let* ((compilers (plist-get config :compilers))
             (compiler  (pb/find-compiler compilers))
             (bin       (expand-file-name "probe" (pb/work-dir lang))))
        (unless compiler
          (user-error "pb: no compiler found; tried: %s"
                      (string-join compilers ", ")))
        (format "%s -o %s %s && %s"
                (shell-quote-argument compiler)
                (shell-quote-argument bin)
                (shell-quote-argument src)
                (shell-quote-argument bin))))))

(defun pb/resolve-shell ()
  (or (and pb/vterm-shell
           (executable-find pb/vterm-shell)
           pb/vterm-shell)
      (and (getenv "SHELL")
           (executable-find (getenv "SHELL"))
           (getenv "SHELL"))
      (executable-find "bash")
      "/bin/sh"))

(defun pb/ensure-shell (lang)
  (let* ((name   (pb/shell-name lang))
         (buf    (get-buffer-create name))
         (freshp (not (get-buffer-process buf))))
    (when freshp
      (if pb/use-vterm
          (with-current-buffer buf
            (let ((vterm-shell (pb/resolve-shell)))
              (vterm-mode)))
        (with-current-buffer buf
          (shell buf))))
    (cons buf freshp)))

(defun pb/send-to-shell (shell-buf command)
  "Send COMMAND (a string, without trailing newline) to SHELL-BUF."
  (if pb/use-vterm
      (with-current-buffer shell-buf
        (vterm-send-string (concat command "\n")))
    (comint-send-string (get-buffer-process shell-buf)
                        (concat command "\n"))))

(defun pb/display (probe-buf shell-buf)
  (delete-other-windows)
  (switch-to-buffer probe-buf)
  (let* ((total     (window-height))
         (top-lines (floor (* 0.70 total)))
         (bot-win   (split-window-below top-lines)))
    (set-window-buffer bot-win shell-buf)
    (select-window (get-buffer-window probe-buf))))

(defun pb/session-exists-p (lang)
  (let ((config (alist-get lang pb/language-config)))
    (and config (file-exists-p (pb/src-file lang config)))))

(defun pb/save-probe ()
  (interactive)
  (let* ((lang   (pb/lang-from-probe-name (buffer-name)))
         (_      (unless lang
                   (user-error "pb: cannot determine language from '%s'"
                               (buffer-name))))
         (config (alist-get lang pb/language-config))
         (_      (unless config
                   (user-error "pb: no config for language '%s'" lang))))
    (write-region (buffer-string) nil (pb/src-file lang config))
    (set-buffer-modified-p nil)
    (message "pb: saved %s" (pb/probe-name lang))))

(defun pb/rerun-probe ()
  (interactive)
  (let* ((lang   (pb/lang-from-probe-name (buffer-name)))
         (_      (unless lang
                   (user-error "pb: cannot determine language from '%s'"
                               (buffer-name))))
         (config (alist-get lang pb/language-config))
         (_      (unless config
                   (user-error "pb: no config for language '%s'" lang)))
         (shell  (pb/ensure-shell lang))
         (sh-buf (car shell)))
    (write-region (buffer-string) nil (pb/src-file lang config))
    (pb/send-to-shell sh-buf (pb/run-command lang config))
    (message "pb: running %s..." (pb/probe-name lang))))

(defun pb/open-langs-buffer ()
  (interactive)
  (let ((buf (get-buffer-create "*probe-langs*")))
    (with-current-buffer buf
      (let ((inhibit-read-only t))
        (erase-buffer)
        (dolist (entry pb/language-config)
          (insert (plist-get (cdr entry) :display-name) "\n"))
        (let ((restore-langs
               (cl-remove-if-not #'pb/session-exists-p
                                 (mapcar #'car pb/language-config))))
          (when restore-langs
            (insert "\n")
            (dolist (lang restore-langs)
              (let* ((display-name (plist-get (alist-get lang pb/language-config)
                                              :display-name))
                     (label        (format "Restore %s" display-name))
                     (lang-capture lang))
                (puthash label
                         (lambda ()
                           (interactive)
                           (pb/open-probe lang-capture t))
                         pb/lang-openers)
                (insert label "\n"))))))
      (read-only-mode 1)
      (nu/wrap-nav-mode 1)
      (goto-char (point-min)))
    (switch-to-buffer buf)))

(defun pb/open-probe (lang &optional restore)
  (let* ((config  (alist-get lang pb/language-config))
         (_       (unless config (user-error "pb: unknown language '%s'" lang)))
         (mode    (plist-get config :mode))
         (tmpl    (plist-get config :template))
         (p-buf   (get-buffer-create (pb/probe-name lang)))
         (shell   (pb/ensure-shell lang))
         (sh-buf  (car shell))
         (freshp  (cdr shell)))

    (with-current-buffer p-buf
      (when (zerop (buffer-size))
        (if (and restore (pb/session-exists-p lang))
            (insert-file-contents (pb/src-file lang config))
          (insert tmpl)))
      (unless (eq major-mode mode)
        (funcall mode))
      (local-set-key (kbd "C-s")     #'pb/save-probe)
      (local-set-key (kbd "C-c p b") #'pb/rerun-probe))

    (when freshp
      (write-region (with-current-buffer p-buf (buffer-string))
                    nil
                    (pb/src-file lang config))
      (pb/send-to-shell sh-buf (pb/run-command lang config)))

    (pb/display p-buf sh-buf)
    (message "pb: opened %s" (pb/probe-name lang))))

(dolist (entry pb/language-config)
  (let* ((lang         (car entry))
         (display-name (plist-get (cdr entry) :display-name))
         (fn-name      (intern (format "pb/open-%s-probe"
                                       (downcase display-name)))))
    (defalias fn-name
      (lambda ()
        (interactive)
        (pb/open-probe lang))
      (format "Open (or revisit) the %s probe buffer." display-name))
    (puthash display-name fn-name pb/lang-openers)))

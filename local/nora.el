;;; nora.el --- NO Root Authentication -*- lexical-binding: t; -*-

(defvar-local nora--needs-auth nil)
(defvar-local nora--authenticated nil)
(defvar-local nora--password nil)

(defconst nora--priv-path
  (or (and (file-executable-p "/run/wrappers/bin/doas")
           "/run/wrappers/bin/doas")
      (executable-find "doas")
      (executable-find "sudo")
      (error "NORA: cannot find doas or sudo")))

(defconst nora--priv-tool
  (file-name-nondirectory nora--priv-path))

(defconst nora--edit-commands
  '(
    self-insert-command
    newline newline-and-indent open-line
    delete-char delete-backward-char backward-delete-char-untabify
    kill-word backward-kill-word
    kill-line kill-region
    yank yank-pop
    transpose-chars transpose-words transpose-lines
    upcase-word downcase-word capitalize-word
    upcase-region downcase-region
    indent-for-tab-command delete-indentation just-one-space
    fill-paragraph
    replace-string replace-regexp query-replace query-replace-regexp
    nu/backward-delete-word
    nu/move-text-up nu/move-text-down
    nu/indent-more-rigidly nu/dedent-rigidly
    nu/toggle-comment
    rc/duplicate-line
    ))

(defun nora--edit-intent-p ()
  (or
   (memq this-command nora--edit-commands)
   (let* ((vec (this-command-keys-vector))
          (key (and (> (length vec) 0) (aref vec 0))))
     (and key (characterp key) (>= key 32)))))

(defun nora--run-with-priv (password &rest args)
  (let ((exit-code nil))
    (make-process
     :name            "nora-priv"
     :command         (cons nora--priv-path args)
     :connection-type 'pty :noquery t :sentinel (lambda (proc _event)
                                                  (setq exit-code (process-exit-status proc)))
     :filter          (lambda (proc output)
                        (when (string-match-p "[Pp]assword" output)
                          (process-send-string proc (concat password "\n")))))
    (while (null exit-code)
      (accept-process-output nil 0.1))
    exit-code))

(defun nora--verify-password (password)
  (= 0 (nora--run-with-priv password "true")))

(defun nora--write-with-priv ()
  (let* ((filename buffer-file-name)
         (tmpfile  (make-temp-file "nora-save-"))
         (saved    nil))
    (unwind-protect
        (condition-case err
            (progn
              (write-region nil nil tmpfile nil 'silent)
              (let ((rc (nora--run-with-priv nora--password "cp" tmpfile filename)))
                (if (= rc 0)
                    (setq saved t)
                  (error "%s cp exited with code %d" nora--priv-tool rc))))
          (error
           (message "NORA: Save failed with error... %s" (error-message-string err))))
      (when (file-exists-p tmpfile)
        (delete-file tmpfile)))
    (if saved
        (progn
          (set-buffer-modified-p nil)
          (message "NORA: Saved %s" (abbreviate-file-name filename)))
      (message "NORA: Save failed"))
    t))

(defun nora--authenticate ()
  (let* ((prompt   (format "NORA: password for %s is... "
                           (abbreviate-file-name buffer-file-name)))
         (password (read-passwd prompt))
         (ok       (nora--verify-password password)))
    (if ok
        (progn
          (setq-local nora--password     password
                      nora--authenticated t)
          (setq buffer-read-only nil)
          (let ((inhibit-read-only t))
            (put-text-property (point-min) (point-max) 'read-only nil))
          (set-buffer-modified-p nil)
          (when (bound-and-true-p view-mode)
            (view-mode -1))
          (add-hook 'write-contents-functions #'nora--write-with-priv nil t)
          (remove-hook 'pre-command-hook #'nora--pre-command-hook t)
          (message "NORA: Authenticated! (via %s)" nora--priv-tool))
      (message "NORA: Wrong password"))))

(defun nora--pre-command-hook ()
  (when (and (not nora--authenticated)
             (nora--edit-intent-p))
    (setq this-command 'ignore)
    (let ((buf (current-buffer)))
      (run-at-time 0 nil (lambda ()
                           (when (buffer-live-p buf)
                             (with-current-buffer buf
                               (nora--authenticate))))))))

(defun nora--file-needs-root-p (filename)
  (and filename
       (file-exists-p filename)
       (not (file-writable-p filename))))

(defun nora--find-file-hook ()
  (when (nora--file-needs-root-p buffer-file-name)
    (setq-local nora--needs-auth t)
    (add-hook 'pre-command-hook #'nora--pre-command-hook nil t)
    (message "NORA: This buffer is read-only, press any edit key to authenticate")))

(unless (eq system-type 'windows-nt)
  (add-hook 'find-file-hook #'nora--find-file-hook))

(provide 'nora)

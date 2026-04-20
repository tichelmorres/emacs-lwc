;;; -*- lexical-binding: t; -*-

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

(defun nora-authenticate ()
  (interactive)
  (unless nora--needs-auth
    (user-error "NORA: This buffer does not require authentication"))
  (when nora--authenticated
    (user-error "NORA: Already authenticated"))
  (let* ((prompt   (format "NORA: Password for %s is... "
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
          (nora-mode -1)
          (message "NORA: Authenticated! (via %s)" nora--priv-tool))
      (message "NORA: Wrong password"))))

(defun nora--command-error-function (data context caller)
  (if (and (eq (car data) 'buffer-read-only)
           (bound-and-true-p nora-mode))
      (message "NORA: Buffer is read-only. Press %s to authenticate"
               (substitute-command-keys "\\[nora-authenticate]"))
    (command-error-default-function data context caller)))

(setq command-error-function #'nora--command-error-function)

(defvar nora-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-n") #'nora-authenticate)
    map))

(define-minor-mode nora-mode
  "Indicate that this buffer needs privilege escalation before editing.
While active, \\[nora-authenticate] prompts for a password and unlocks
the buffer for writing via `doas'/`sudo'."
  :keymap nora-mode-map
  :lighter " NORA")

(defun nora--file-needs-root-p (filename)
  (and filename
       (file-exists-p filename)
       (not (file-writable-p filename))))

(defun nora--find-file-hook ()
  (when (nora--file-needs-root-p buffer-file-name)
    (setq-local nora--needs-auth t)
    (nora-mode 1)
    (message "NORA: Press %s to authenticate"
             (substitute-command-keys "\\[nora-authenticate]"))))

(unless (eq system-type 'windows-nt)
  (add-hook 'find-file-hook #'nora--find-file-hook))

(provide 'nora)

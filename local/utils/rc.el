(defgroup rc nil
  "Utilities gotten from external Elisp config files."
  :group 'tools)

(defvar rc/font-family nil)

(defvar rc/package-contents-refreshed nil)

(defun rc/package-refresh-contents-once ()
  (when (not rc/package-contents-refreshed)
    (setq rc/package-contents-refreshed t)
    (package-refresh-contents)))

(defun rc/require-one-package (package)
  (when (not (package-installed-p package))
    (rc/package-refresh-contents-once)
    (package-install package)))

(defun rc/require (&rest packages)
  (dolist (package packages)
    (rc/require-one-package package)))

(defun rc/require-theme (theme)
  (let* ((theme-name (symbol-name theme))
         (theme-package (intern (concat theme-name "-theme"))))
    (rc/require theme-package)
    (load-theme theme t)))

(defun rc/duplicate-line ()
  (interactive)
  (let* ((regionp (use-region-p))
         (line-beg (save-excursion
                     (goto-char (if regionp (region-beginning) (point)))
                     (line-beginning-position)))
         (line-end (save-excursion
                     (goto-char (if regionp (region-end) (point)))
                     (if (and regionp (bolp))
                         (progn (forward-line -1) (line-end-position))
                       (line-end-position))))
         (col  (current-column))
         (text (buffer-substring-no-properties line-beg line-end))
         insert-beg insert-end)
    (atomic-change-group
      (save-excursion
        (goto-char line-end)
        (insert "\n" text)
        (setq insert-end (point))
        (setq insert-beg (- insert-end (length text)))))
    (if regionp
        (progn
          (set-mark insert-beg)
          (goto-char insert-end)
          (setq deactivate-mark nil)
          (activate-mark))
      (forward-line 1)
      (move-to-column col))))

(defun rc/set-up-whitespace-handling ()
  (interactive)
  (whitespace-mode 1)
  (add-to-list 'write-file-functions 'delete-trailing-whitespace))

(defun rc/kill-buffer-and-window ()
  (interactive)
  (kill-buffer)
  (unless (one-window-p)
    (delete-window)))

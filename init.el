(when (eq system-type 'windows-nt)
  (setq package-gnupghome-dir
        (expand-file-name "elpa/gnupg" user-emacs-directory))
  (unless (file-directory-p package-gnupghome-dir)
    (make-directory package-gnupghome-dir t))
  (setq package-check-signature nil))

(package-initialize)

(defvar lwc/config-dir
  (cond
   ((eq system-type 'windows-nt) (expand-file-name "~/.emacs.d/"))
   (t                            (expand-file-name "~/.config/emacs/"))))

(defun lwc/config-path (&rest segments)
  (apply #'expand-file-name
         (mapconcat #'identity segments "/")
         (list lwc/config-dir)))

(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

(add-to-list 'load-path (lwc/config-path "local"))
(load-file (lwc/config-path "local" "rc.el"))
(load-file (lwc/config-path "local" "nu.el"))
(load-file (lwc/config-path "local" "zt.el"))
(load-file (lwc/config-path "local" "pb.el"))
(load-file (lwc/config-path "local" "simpc-mode.el"))
(add-to-list 'custom-theme-load-path (lwc/config-path "themes"))

(cond
 ((eq system-type 'windows-nt) (load-file (lwc/config-path "windows.el")))
 (t
  (load-file (lwc/config-path "nixos.el"))
  (load-file (lwc/config-path "local" "nora.el"))))

(load-file (lwc/config-path "shared.el"))

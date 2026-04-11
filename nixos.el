(let* ((raw    (ignore-errors (string-trim (shell-command-to-string "manpath 2>/dev/null"))))
       (paths  (if (and raw (not (string-empty-p raw)))
                   raw
                 (string-join
                  (seq-filter #'file-directory-p
                              (list "/run/current-system/sw/share/man"
                                    (expand-file-name "~/.nix-profile/share/man")))
                  ":"))))
  (setenv "MANPATH" paths))

(with-eval-after-load 'man
  (advice-add 'Man-completion-table :around
    (lambda (orig string pred action)
      (unless Man-completion-cache
        (setq Man-completion-cache
              (condition-case err
                  (nu/man-pages-from-manpath)
                (error (message "man completion: %s" err) nil))))
      (funcall orig string pred action))))

(setq nu/dash-file (lwc/config-path "dash-nixos.org"))
(prefer-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(add-to-list 'default-frame-alist '(font . "Iosevka Nerd Font Mono-17"))
(set-face-attribute 'default nil :weight 'normal)
;; (set-face-attribute 'font-lock-comment-face nil :weight 'bold)
;; (set-face-attribute 'font-lock-comment-face nil :slant 'italic)
;; (setq-default line-spacing 0.0)

(add-hook 'emacs-startup-hook
          (lambda ()
            (when (string-equal (buffer-file-name) nu/dash-file)
              (org-mode)
              (setq-local org-link-elisp-confirm-function nil)
              (setq-local visual-fill-column-width 40)
              (visual-line-mode 1)
              (read-only-mode 1)
              (visual-fill-column-mode 1)
              (nu/dashboard-nav-mode 1)
              (nu/dashboard-nav--collect-items)
              (nu/dashboard-nav--goto-item 0 0)
              (let ((win (get-buffer-window (current-buffer) t)))
                (when win (with-selected-window win (recenter (/ (window-body-height) 2))))))))

;; Prefer fish for interactive shells,
;; but keep POSIX sh for non-interactive commands
(let* ((fish-candidates (list (executable-find "fish")
                              (expand-file-name "~/.nix-profile/bin/fish")
                              "/run/current-system/sw/bin/fish"))
       (fish (seq-find #'identity fish-candidates)))
  (when fish
    (setq explicit-shell-file-name fish)
    (setq shell-file-name "/bin/sh")
    (setenv "SHELL" fish)
    (add-to-list 'exec-path (file-name-directory fish))
    (setq pb/vterm-shell fish)))

;; (setq-default header-line-format " ")

(defvar mo/menu-background "#181818")
(when (display-graphic-p)
  (require 'color)
  (set-face-attribute 'header-line nil
                      :background mo/menu-background
                      :box nil)

  (set-face-attribute 'menu nil :background mo/menu-background))

(rc/require-theme 'gruber-darker)
(load-theme 'gruber-darker t)

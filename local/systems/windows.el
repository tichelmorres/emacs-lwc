(setq nu/dash-file (lwc/config-path "local" "systems" "dash" "windows.org"))

(prefer-coding-system        'utf-8)
(set-language-environment    "UTF-8")
(set-default-coding-systems  'utf-8)
(set-terminal-coding-system  'utf-8)
(set-keyboard-coding-system  'utf-8)
(set-selection-coding-system 'utf-16le-dos)

(setq rc/font-family "Consolas")
(add-to-list 'default-frame-alist '(font . "Consolas-15"))

(add-hook 'emacs-startup-hook
          (lambda ()
            (when (string-equal (buffer-file-name) nu/dash-file)
              (org-mode)
              (setq-local org-link-elisp-confirm-function nil)
              (setq-local visual-fill-column-width 34)
              (visual-line-mode 1)
              (read-only-mode 0)
              (visual-fill-column-mode 1)
              (goto-char (point-min))
              (forward-line 5)
              (let ((win (get-buffer-window (current-buffer) t)))
                (when win (with-selected-window win (recenter (/ (window-body-height) 2))))))))

;; (load-theme 'automata t)
(load-theme 'konosuba t)

;; (setq-default header-line-format " ")
;; (defvar mo/menu-background "#181818")
;; (require 'color)
;; (set-face-attribute 'header-line nil
;;                     :background mo/menu-background
;;                     :box nil)
;; (set-face-attribute 'menu nil :background mo/menu-background)
;; (rc/require-theme 'gruber-darker)
;; (load-theme 'gruber-darker t)

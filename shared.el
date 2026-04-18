;; | --------------------------------------------
;; |  General
;; | --------------------------------------------

;; Disable warnings at initialization
(setq warning-minimum-level :emergency)

;; Kill running processes without prompting on exit
(setq confirm-kill-processes nil)

;; Enable mouse on -nw mode
(unless (display-graphic-p)
  (xterm-mouse-mode 1))

;; Disable auto-saving
(setq auto-save-default nil)

;; Backup settings
(setq backup-directory-alist `((".*" . ,(lwc/config-path "backups"))))
(setq make-backup-files t)
(setq backup-by-copying t)
(setq delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t)
(setq create-lockfiles nil)

;; Use space characters, not tabs
(setq-default indent-tabs-mode nil)

;; Disable annoying GUI dialogs
(setq use-dialog-box nil)

;; Disable menu bar, toolbar and scrollbars
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(horizontal-scroll-bar-mode -1)

;; Stop the cursor from blinking
(blink-cursor-mode 0)

;; Disable top/bottom padding while scrolling
(setq scroll-margin 0)

;; Buffers split window view vertically this way
;; (setq split-width-threshold nil
;;       split-height-threshold 0)

;; Buffers split window view horizontally this way
(setq split-height-threshold nil
      split-width-threshold  0)

;; Disable annoying bell sound
(setq ring-bell-function 'ignore)

;; Disable automatic indentation
(electric-indent-mode -1)

;; Use the uniform line height "latex-mode",
;; insert a literal " instead of smart quotes (`` / ''),
;; enable truncate mode automatically for LaTeX mode
(with-eval-after-load 'latex
  (advice-add 'LaTeX-mode :override #'latex-mode))

(add-hook 'latex-mode-hook
          (lambda ()
            (display-line-numbers-mode 0)
            (visual-line-mode t)
            ;; (local-set-key (kbd "\"") #'self-insert-command)
            )
          t)

;; Disable line numbers and truncate big lines on MD
(add-hook 'markdown-mode-hook
          (lambda ()
            (display-line-numbers-mode 0)
            (visual-line-mode t))
          t)

;; Wayland wl-copy support for emacs -nw
(unless (eq system-type 'windows-nt)
  (rc/require 'xclip)
  (setq xclip-program "wl-copy")
  (setq xclip-method 'wl-copy)
  (xclip-mode 1))

;; Auto-completion
(rc/require 'smex 'ido-completing-read+)
(require 'ido-completing-read+)

(ido-mode 1)
(ido-everywhere 1)
(ido-ubiquitous-mode 1)

(global-set-key (kbd "M-x") 'smex)

;; Enable global line numbers
;; (and disable it in some cases)
(global-display-line-numbers-mode t)

(add-hook 'org-mode-hook      (lambda () (display-line-numbers-mode 0)))
(add-hook 'gfm-mode-hook      (lambda () (display-line-numbers-mode 0)))

;; Set min number line width to 4 characters
(setq-default display-line-numbers-width 4)

;; Org files config
(rc/require 'org-inline-anim)
(setq org-inline-anim-loop t)

(setq org-startup-with-inline-images t)

(defun nu/org-animate-gifs-in-dash ()
  (when (and buffer-file-name
	     (string-equal (file-truename buffer-file-name)
			   (file-truename nu/dash-file)))
    (org-display-inline-images)
    (org-inline-anim-mode 1)
    (when (fboundp 'org-inline-anim-animate-all)
      (org-inline-anim-animate-all))))

(add-hook 'org-mode-hook #'nu/org-animate-gifs-in-dash)

(setq org-startup-indented t)
(setq org-hide-leading-stars t)
(setq org-hide-emphasis-markers t)
(setq org-hide-leading-stars t)

;; Disable automatic line wrapping
(setq-default truncate-lines t)

;; One-line scrolling when pointer hits window edge
(setq scroll-conservatively 101
      scroll-step 1
      scroll-preserve-screen-position nil
      scroll-margin 0)

;; Disable splash screen and welcome message
(setq inhibit-startup-screen t)
(setq inhibit-startup-message t)
(setq initial-scratch-message nil)

(defun display-startup-echo-area-message ()
  (message ""))

;; Scratch buffer should only have markdown, visual-line and whitespace modes
(add-hook 'emacs-startup-hook
          (lambda ()
            (with-current-buffer (get-buffer-create "*scratch*")
              (erase-buffer)
              (markdown-mode)
              (visual-line-mode 1)
              (whitespace-mode 1)
              (auto-fill-mode -1)
              (eldoc-mode -1)))
          t)

;; Use custom start page (read-only)
(setq initial-buffer-choice nu/dash-file)
(rc/require 'visual-fill-column)
(setq visual-fill-column-center-text t)

;; Dired config
(setq wdired-allow-to-change-permissions t)

(require 'ls-lisp)
(require 'dired-x)
(setq ls-lisp-use-insert-directory-program nil)
(setq ls-lisp-dirs-first nil)

(defvar nu/lualatex '("aux" "log" "out"))

;; Hide lualatex build artefacts only.
;; The default dired-omit-files also matches "." and "..", so we
;; replace it with just the auto-save/lock-file pattern to keep
;; those two entries visible.  Comment the three lines below to
;; show artefacts again.
(setq dired-omit-files "^\\.?#")
(setq dired-omit-extensions nu/lualatex)
(add-hook 'dired-mode-hook #'dired-omit-mode)
(add-hook 'dired-mode-hook #'nu/wrap-nav-mode)

(with-eval-after-load 'dired
  (define-key dired-mode-map (kbd "C-l")       #'dired-find-file)
  (define-key dired-mode-map (kbd "M-<left>")  #'dired-up-directory)
  (define-key dired-mode-map (kbd "M-<right>") #'dired-find-file)
  (define-key dired-mode-map (kbd "C-<down>")
    (lambda () (interactive "^")
      (forward-line 5)
      (ignore-errors (dired-move-to-filename))))
  (define-key dired-mode-map (kbd "C-<up>")
    (lambda () (interactive "^")
      (forward-line -5)
      (ignore-errors (dired-move-to-filename)))))

(defun nu/dired-extension-priority (filename)
  (let* ((base (directory-file-name (file-name-nondirectory filename)))
         (ext  (downcase (or (file-name-extension base) ""))))
    (cond ((string= base ".")          0)
          ((string= base "..")         1)
          ((string= ext  "tex")        2)
          ((string= ext  "pdf")        3)
          ((member  ext  nu/lualatex)  4)
          ;; <- other files and dirs come here
          ((string= base ".git")       6)
          ((string= base ".gitignore") 7)
          (t                           5))))

(advice-add 'ls-lisp-handle-switches :filter-return
            (lambda (file-alist)
              (sort file-alist
                    (lambda (a b)
                      (let ((pa (nu/dired-extension-priority (car a)))
                            (pb (nu/dired-extension-priority (car b))))
                        (if (= pa pb)
                            (ls-lisp-string-lessp (car a) (car b))
                          (< pa pb))))))
            '((name . nu/dired-extension-priority-sort)))

;; | --------------------------------------------
;; |  Binds
;; | --------------------------------------------

;; Enable Common User Access mode to use
;; C-c, C-v, C-z and other default binds
(cua-mode t)

;; Copy without losing selection
(advice-add 'kill-ring-save :after #'nu/keep-region-active-after-copy)

(when (fboundp 'cua-copy-region)
  (advice-add 'cua-copy-region :after #'nu/keep-region-active-after-copy))

;; Deselect text area on cursor move
(add-hook 'pre-command-hook #'nu/pre-command-deselect-on-move)

;; C-z => undo  /  C-y => redo
;; Both deactivate any active selection first so they always operate
;; on the whole buffer (CUA would otherwise scope C-z to the region).
;; global-set-key alone is not enough for C-z because CUA registers it
;; in its own higher-priority keymap; we must override it there directly.
(global-set-key (kbd "C-z") #'nu/undo)
(global-set-key (kbd "C-y") #'nu/undo-redo)
(with-eval-after-load 'cua-base
  (define-key cua--cua-keys-keymap (kbd "C-z") #'nu/undo))

;; Move line(s) contents Up or Down
;; M-<up> && M-<down>
(global-set-key (kbd "M-<up>")  'nu/move-text-up)
(global-set-key (kbd "M-<down>") 'nu/move-text-down)

;; C-+ => larger window
;; C-- => smaller window
(global-set-key (kbd "C-+")  #'nu/text-scale-increase)
(global-set-key (kbd "C-=")  #'nu/text-scale-increase)
(global-set-key (kbd "C--")  #'nu/text-scale-decrease)
(global-set-key (kbd "C-_")  #'nu/text-scale-decrease)

;; Unset now unuseful binds
(global-unset-key (kbd "C-x C-+"))
(global-unset-key (kbd "C-x C-="))
(global-unset-key (kbd "C-x C--"))
(global-unset-key (kbd "C-x C-_"))

;; EWW
(global-set-key (kbd "C-e") #'eww)
(with-eval-after-load 'eww
  (define-key eww-mode-map (kbd "M-<left>")  #'eww-back-url)
  (define-key eww-mode-map (kbd "M-<right>") #'eww-forward-url))

;; M-left opens dired at the current file's directory
;; M-right should be unbinded
(global-set-key (kbd "M-<left>") #'dired-jump)
(with-eval-after-load 'org
  (define-key org-mode-map (kbd "M-<left>")  #'dired-jump)
  (define-key org-mode-map (kbd "M-<right>") nil))
(global-unset-key (kbd "M-<right>"))

;; Make ESC act like a universal quit
(global-set-key [escape]  #'keyboard-escape-quit)

;; C-p => select current line, cursor at end of line
(global-set-key (kbd "C-p") #'nu/select-line)

;; Toggle line numbers
(global-set-key (kbd "C-/") #'display-line-numbers-mode)

;; -nw mode causes C-/ to be sent as C-_
;; so we overwrite the C-_ bind
(unless (display-graphic-p)
    (global-set-key (kbd "C-_") #'display-line-numbers-mode))

;; Ctrl + f for search and Ctrl + s for writing
;; Also remove Ctrl + b
(global-set-key (kbd "C-f") #'isearch-forward)
(with-eval-after-load 'isearch
  (define-key isearch-mode-map (kbd "C-f") #'isearch-repeat-forward))

(define-key isearch-mode-map (kbd "C-v") #'isearch-yank-kill)

(global-set-key (kbd "C-b") (lambda () (interactive)))
(global-set-key (kbd "C-s") #'save-buffer)

;; Ctrl + a selects all text
(global-set-key (kbd "C-a") #'mark-whole-buffer)

;; Ctrl + l => open link
(rc/require 'dumb-jump)
(add-hook 'xref-backend-functions #'dumb-jump-xref-activate)
(global-set-key (kbd "C-l") #'nu/goto-link-source)

;; Dedent by one tab
(global-set-key (kbd "<backtab>") #'nu/dedent-rigidly)

;; Overwrite default indent
;; (so selection mark is not unset after use)
(global-set-key (kbd "<tab>") #'nu/indent-more-rigidly)

;; Toggle comment on region or current line
(global-set-key (kbd "C-;") #'nu/toggle-comment)

;; Duplicate line
(global-set-key (kbd "C-,") 'rc/duplicate-line)

;; Open LaTeX as PDF
(global-set-key (kbd "C-c p p") #'la/latex-compile-and-open)

;; Open GAMES buffer
(global-set-key (kbd "C-c g") #'nu/open-games-buffer)

;; Open compiled languages list for scratch-compile
(global-set-key (kbd "C-c p c") #'pb/open-langs-buffer)

;; Ctrl + Backspace should not push word to kill ring
(global-set-key (kbd "C-<backspace>") #'nu/backward-delete-word)

;; -nw mode causes C-<backspace> to be sent as C-h
(unless (display-graphic-p)
    (global-set-key (kbd "C-h") #'nu/backward-delete-word))

;; Multiple cursors
(rc/require 'multiple-cursors)

(global-set-key (kbd "C->") 'nu/mc-mark-next)
(global-set-key (kbd "C-<") 'nu/mc-mark-previous)

;; M-d => add cursor at next match occurrence of selection
;; M-l => select all occurrences of current selection
(global-set-key (kbd "M-d") #'nu/select-word-or-next)
(global-set-key (kbd "M-l") #'nu/select-all-occurrences)

;; Scroll keys to snap cursor to column 0 when pushed off-screen
(global-set-key (kbd "<wheel-down>") #'nu/mwheel-snap)
(global-set-key (kbd "<wheel-up>")   #'nu/mwheel-snap)

;; | --------------------------------------------
;; |  Theming
;; | --------------------------------------------

;; Don't let the theme set a background color on -nw mode
(unless (display-graphic-p)
  (set-face-background 'default "unspecified-bg"))

;; | --------------------------------------------
;; |  Programming
;; | --------------------------------------------

;; Use Simple C instead of C mode
;; Source: https://github.com/rexim/simpc-mode
(require 'simpc-mode)
(add-to-list 'auto-mode-alist '("\\.[hc]\\(pp\\)?\\'" . simpc-mode))

;; Julia
(rc/require 'julia-mode)
(require 'julia-mode)
(add-to-list 'auto-mode-alist '("\\.j\\(l\\|ulia\\)\\'" . julia-mode))

(define-key julia-mode-map (kbd "TAB") 'julia-latexsub-or-indent)

;; Nix
(rc/require 'nix-mode)
(require 'nix-mode)
(add-to-list 'auto-mode-alist '("\\.nix\\'" . nix-mode))

;; Markdown
(rc/require 'markdown-mode)
(require 'markdown-mode)
(add-to-list 'auto-mode-alist '("\\.m\\(d\\|arkdown\\)\\'" . markdown-mode))

;; Rust / RON
(rc/require 'rust-mode)
(require 'rust-mode)
(add-to-list 'auto-mode-alist '("\\.r\\(s\\|lib\\)\\'" . rust-mode))

(rc/require 'ron-mode)
(require 'ron-mode)
(add-to-list 'auto-mode-alist '("\\.ron\\'" . ron-mode))

;; Haskell
(rc/require 'haskell-mode)
(require 'haskell-mode)
(add-to-list 'auto-mode-alist '("\\.hs\\'" . haskell-mode))

;; HTML / CSS
(add-hook 'html-mode-hook (lambda () (visual-line-mode t)))
(add-hook 'css-mode-hook  (lambda () (visual-line-mode t)))

;; JSONC
(add-to-list 'auto-mode-alist '("\\.jsonc\\'" . js-json-mode))

;; Disable lsp info window at the bottom
(setq lsp-signature-auto-activate nil)

;; Magit
(rc/require 'cl-lib)
(rc/require 'magit)

(setq magit-auto-revert-mode nil)

(global-set-key (kbd "C-c m l") 'magit-status)

;; Whitespace mode
(setq whitespace-style '(face tabs spaces trailing space-before-tab
                              indentation space-after-tab tab-mark))

(add-hook 'c++-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'c-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'simpc-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'emacs-lisp-mode 'rc/set-up-whitespace-handling)
(add-hook 'rust-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'markdown-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'python-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'asm-mode-hook 'rc/set-up-whitespace-handling)

;; | --------------------------------------------
;; |  Others
;; | --------------------------------------------

;; Translation
(rc/require 'google-translate)
(require 'google-translate)
(require 'google-translate-smooth-ui)
(global-set-key (kbd "C-c t") 'google-translate-smooth-translate)

;; ERC
(setq erc-inhibit-multiline-input t)
(setq erc-send-whitespace-lines t)
(setq erc-ask-about-multiline-input t)

;; Color visualization
(rc/require 'colorful-mode)

;; Emacs auto-generated custom file
(setq custom-file (lwc/config-path "custom.el"))
(load-file (lwc/config-path "custom.el"))

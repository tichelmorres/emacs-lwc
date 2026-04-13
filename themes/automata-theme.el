(rc/require 'autothemer)
(require 'autothemer)

(autothemer-deftheme
 automata "A refined personal theme for Emacs, roughly based on NieR:Automata's colors."

 (
  (((class color) (min-colors #xFFFFFF)))

  ;; === Palatte ===

  ;; White
  (automata-light-white "#ffffff")
  (automata-dark-white  "#927e59")

  ;; Red
  (automata-red "#9d0006")

  ;; Green
  (automata-green "#79740e")

  ;; Yellow
  (automata-yellow "#b57614")

  ;; Blue
  (automata-blue "#076678")

  ;; Magenta
  (automata-light-magenta "#c378a7")  ;; unused
  (automata-dark-magenta  "#8f3f71")

  ;; Cyan
  (automata-cyan "#427b58")

  ;; Gray
  (automata-light-gray "#504945")
  (automata-dark-gray  "#282828")

  ;; General
  (automata-background  "#c2bda6")
  (automata-foreground  "#48463d")

  ;; Mark
  (automata-cursor      "#f4f0e1"))

  ;; === Faces ===

  (
    ;; Basic
    (default (:foreground automata-foreground :background automata-background))
    (cursor  (:background automata-cursor))
    (fringe  (:background automata-background))
    (shadow  (:foreground automata-light-gray))

    (link         (:foreground automata-blue         :underline t))
    (link-visited (:foreground automata-dark-magenta :underline t))
    (match        (:background automata-dark-gray))
    (highlight    (:background automata-dark-gray    :foreground nil))

    (vertical-border   (:foreground automata-dark-gray))
    (help-key-binding  (:foreground automata-dark-white :background automata-dark-gray))
    (region            (:foreground automata-dark-white :background automata-dark-gray))
    (minibuffer-prompt (:foreground automata-blue))

    (tooltip (:foreground automata-light-white :background automata-dark-gray))

    ;; Font Lock
    (font-lock-builtin-face           (:foreground automata-yellow))
    (font-lock-preprocessor-face      (:foreground automata-red))
    (font-lock-string-face            (:foreground automata-dark-magenta))
    (font-lock-doc-face               (:foreground automata-green))
    (font-lock-type-face              (:foreground automata-red))
    (font-lock-function-name-face     (:foreground automata-blue))
    (font-lock-function-call-face     (:foreground automata-cyan))
    (font-lock-keyword-face           (:foreground automata-blue :bold t))
    (font-lock-variable-name-face     (:foreground automata-foreground))
    (font-lock-constant-face          (:foreground automata-light-gray))
    (font-lock-comment-face           (:foreground automata-dark-white))
    (font-lock-comment-delimiter-face (:foreground automata-light-gray))
    (font-lock-reference-face         (:foreground automata-light-gray))
    (font-lock-warning-face           (:foreground automata-red))

    ;; Font Lock (Emacs 29+)
    (font-lock-bracket-face          (:foreground automata-light-gray))
    (font-lock-operator-face         (:foreground automata-light-gray))
    (font-lock-punctuation-face      (:foreground automata-light-gray))
    (font-lock-delimiter-face        (:foreground automata-light-gray))
    (font-lock-misc-punctuation-face (:foreground automata-light-gray))
    (font-lock-number-face           (:foreground automata-dark-magenta))
    (font-lock-escape-face           (:foreground automata-dark-magenta))

    ;; Rainbow delimiters
    (rainbow-delimiters-depth-1-face    (:foreground automata-yellow))
    (rainbow-delimiters-depth-2-face    (:foreground automata-blue))
    (rainbow-delimiters-depth-3-face    (:foreground automata-dark-magenta))
    (rainbow-delimiters-depth-4-face    (:foreground automata-cyan))
    (rainbow-delimiters-depth-5-face    (:foreground automata-green))
    (rainbow-delimiters-depth-6-face    (:foreground automata-yellow))
    (rainbow-delimiters-depth-7-face    (:foreground automata-blue))
    (rainbow-delimiters-depth-8-face    (:foreground automata-dark-magenta))
    (rainbow-delimiters-depth-9-face    (:foreground automata-cyan))
    (rainbow-delimiters-unmatched-face  (:foreground automata-light-white :background automata-red))
    (rainbow-delimiters-mismatched-face (:foreground automata-light-white :background automata-red))

    ;; Line numbers
    (line-number              (:foreground automata-yellow))
    (line-number-current-line (:foreground automata-yellow :bold t))

    ;; Mode line
    (mode-line           (:foreground automata-dark-white  :background automata-dark-gray))
    (mode-line-inactive  (:foreground automata-dark-gray   :background automata-light-gray))
    (mode-line-buffer-id (:foreground automata-light-white :background automata-dark-gray))

    ;; Search
    (isearch                     (:foreground automata-dark-gray   :background automata-yellow))
    (isearch-fail                (:foreground automata-light-white :background automata-red))
    (isearch-lazy-highlight-face (:foreground automata-foreground  :background automata-dark-white))

    ;; Show Paren
    (show-paren-match    (:background automata-dark-gray))
    (show-paren-mismatch (:background automata-red))

    ;; Dired
    (dired-directory (:foreground automata-blue :weight 'bold))
    (dired-ignored   (:foreground automata-light-gray))

    ;; Whitespace
    (whitespace-space            (:foreground automata-background  :background automata-background))
    (whitespace-tab              (:foreground automata-background  :background automata-background))
    (whitespace-newline          (:foreground automata-dark-white  :background automata-background))
    (whitespace-hspace           (:foreground automata-dark-white  :background automata-background))
    (whitespace-line             (:foreground automata-red         :background automata-dark-gray))
    (whitespace-empty            (:foreground automata-red         :background automata-red))
    (whitespace-trailing         (:foreground automata-red         :background automata-red))
    (whitespace-indentation      (:foreground automata-red         :background automata-yellow))
    (whitespace-space-after-tab  (:foreground automata-yellow      :background automata-yellow))
    (whitespace-space-before-tab (:foreground automata-yellow      :background automata-yellow))
    (trailing-whitespace         (:foreground automata-light-white :background automata-red))

    ;; Diff
    (diff-added   (:foreground automata-green :background nil))
    (diff-removed (:foreground automata-red   :background nil))

    ;; Compilation
    (compilation-info           (:foreground automata-green))
    (compilation-warning        (:foreground automata-yellow :bold t))
    (compilation-error          (:foreground automata-red))
    (compilation-mode-line-fail (:foreground automata-red    :weight 'bold))
    (compilation-mode-line-exit (:foreground automata-green  :weight 'bold))

    ;; Flymake
    (flymake-error   (:underline (:style 'wave :color automata-red)))
    (flymake-warning (:underline (:style 'wave :color automata-yellow)))
    (flymake-note    (:underline (:style 'wave :color automata-green)))

    ;; Flyspell
    (flyspell-incorrect (:underline (:style 'wave :color automata-red)))
    (flyspell-duplicate (:underline (:style 'wave :color automata-yellow)))

    ;; Ivy
    (ivy-current-match           (:foreground automata-light-white :background automata-blue))
    (ivy-prompt-match            (:foreground automata-light-white :background automata-blue))
    (ivy-minibuffer-match-face-2 (:foreground automata-light-white :background automata-yellow))
    (ivy-minibuffer-match-face-4 (:foreground automata-light-white :background automata-yellow))
    (ivy-subdir                  (:foreground automata-light-white :background automata-blue))

    ;; Swiper
    (swiper-line-face    (:foreground automata-light-white :background automata-blue))
    (swiper-match-face-1 (:foreground automata-dark-gray   :background automata-light-white))
    (swiper-match-face-3 (:foreground automata-light-white :background automata-red))

    ;; Ido
    (ido-first-match (:foreground automata-yellow))
    (ido-only-match  (:foreground automata-yellow :weight 'bold))
    (ido-subdir      (:foreground automata-blue   :weight 'bold))

    ;; Orderless
    (orderless-match-face-0 (:foreground automata-yellow))
    (orderless-match-face-1 (:foreground automata-green))
    (orderless-match-face-2 (:foreground automata-cyan))
    (orderless-match-face-3 (:foreground automata-light-gray))

    ;; Company
    (company-tooltip                  (:foreground automata-foreground  :background automata-dark-gray))
    (company-tooltip-selection        (:foreground automata-light-white :background automata-dark-gray))
    (company-tooltip-annotation       (:foreground automata-yellow      :background automata-dark-gray))
    (company-tooltip-common           (:foreground automata-green))
    (company-tooltip-common-selection (:foreground automata-green))
    (company-scrollbar-fg             (:background automata-light-gray))
    (company-scrollbar-bg             (:background automata-dark-gray))
    (company-preview                  (:background automata-green))
    (company-preview-common           (:foreground automata-green       :background automata-dark-gray))

    ;; Org
    (org-agenda-structure  (:foreground automata-blue))
    (org-done              (:foreground automata-green))
    (org-todo              (:foreground automata-red))
    (org-upcoming-deadline (:foreground automata-yellow))

    ;; Magit
    (magit-branch        (:foreground automata-blue))
    (magit-tag           (:foreground automata-yellow     :background automata-background))
    (magit-log-sha1      (:foreground automata-red))
    (magit-log-author    (:foreground automata-yellow))
    (magit-item-highlight (:background automata-dark-gray))
    (magit-blame-heading (:foreground automata-foreground :background automata-dark-gray))

    ;; EShell
    (eshell-ls-backup     (:foreground automata-light-gray))
    (eshell-ls-directory  (:foreground automata-blue))
    (eshell-ls-executable (:foreground automata-green))
    (eshell-ls-symlink    (:foreground automata-yellow))

    ;; Tab bar
    (tab-bar              (:foreground automata-light-gray :background automata-dark-gray))
    (tab-bar-tab          (:foreground automata-yellow     :background nil :weight 'bold))
    (tab-bar-tab-inactive (:foreground automata-light-gray :background nil))

    ;; Term / vterm
    (term-color-black   (:foreground automata-dark-gray    :background automata-dark-gray))
    (term-color-red     (:foreground automata-red          :background automata-red))
    (term-color-green   (:foreground automata-green        :background automata-green))
    (term-color-yellow  (:foreground automata-yellow       :background automata-yellow))
    (term-color-blue    (:foreground automata-blue         :background automata-blue))
    (term-color-magenta (:foreground automata-dark-magenta :background automata-dark-magenta))
    (term-color-cyan    (:foreground automata-cyan         :background automata-cyan))
    (term-color-white   (:foreground automata-light-white  :background automata-light-white))
  )
)

(provide-theme 'automata)

;;; konosuba-theme.el --- A color theme for Emacs, based on the KonoSuba anime series.

(deftheme konosuba
  "A color theme for Emacs, based on the KonoSuba anime series.")

(let (
      (konosuba-light-white    "#ffffff")
      (konosuba-dark-white     "#f4f4ff")

      (konosuba-red            "#f43841")
      (konosuba-orange         "#cc8c3c")
      (konosuba-green          "#77c686")
      (konosuba-yellow         "#fdf3b6")
      (konosuba-blue           "#7ca4d6")
      (konosuba-cyan           "#57afc0")
      (konosuba-teal           "#00b089")
      (konosuba-purple         "#9e95c7")
      (konosuba-magenta        "#f7a0bf")
      (konosuba-quartz         "#a4a9af")

      (konosuba-light-dimm     "#565f73")
      (konosuba-dark-dimm      "#303540")
      (konosuba-light-gray     "#52494e")
      (konosuba-dark-gray      "#282828")
      (konosuba-light-brown    "#b3ad91")
      (konosuba-dark-brown     "#453d41")

      (konosuba-black          "#000000")

      (konosuba-background     "#181818")
      (konosuba-foreground     "#f5f4f9")

      (konosuba-region         "#363636")
      (konosuba-comment        "#6e4f4a")
      )

  (custom-theme-set-variables
   'konosuba
   '(frame-brackground-mode (quote dark)))

  (custom-theme-set-faces
   'konosuba

   ;; Agda2
   `(agda2-highlight-datatype-face              ((t  (     :foreground ,konosuba-green      ))))
   `(agda2-highlight-primitive-type-face        ((t  (     :foreground ,konosuba-green      ))))
   `(agda2-highlight-function-face              ((t  (     :foreground ,konosuba-blue       ))))
   `(agda2-highlight-keyword-face               ((t ,(list :foreground  konosuba-red :bold t))))
   `(agda2-highlight-inductive-constructor-face ((t  (     :foreground ,konosuba-yellow     ))))
   `(agda2-highlight-number-face                ((t  (     :foreground ,konosuba-cyan       ))))

   ;; AUCTeX
   `(font-latex-bold-face         ((t  (     :foreground ,konosuba-green :bold   t))))
   `(font-latex-italic-face       ((t  (     :foreground ,konosuba-green :italic t))))
   `(font-latex-math-face         ((t  (     :foreground ,konosuba-yellow         ))))
   `(font-latex-sectioning-5-face ((t ,(list :foreground  konosuba-blue  :bold   t))))
   `(font-latex-slide-title-face  ((t  (     :foreground ,konosuba-blue           ))))
   `(font-latex-string-face       ((t  (     :foreground ,konosuba-yellow         ))))
   `(font-latex-warning-face      ((t  (     :foreground ,konosuba-magenta        ))))

   ;; Basic Coloring (or Uncategorized)
   `(border              ((t ,(list :background  konosuba-black      :foreground  konosuba-dark-brown          ))))
   `(cursor              ((t  (     :background ,konosuba-red                                                  ))))
   `(default             ((t ,(list :foreground  konosuba-foreground :background  konosuba-background          ))))
   `(fringe              ((t ,(list :background 'unspecified         :foreground  konosuba-dark-brown          ))))
   `(vertical-border     ((t ,(list :foreground  konosuba-dark-brown                                           ))))
   `(link                ((t  (     :foreground ,konosuba-blue       :underline t                              ))))
   `(link-visited        ((t  (     :foreground ,konosuba-purple     :underline t                              ))))
   `(match               ((t  (     :background ,konosuba-light-gray                                           ))))
   `(shadow              ((t  (     :foreground ,konosuba-light-gray                                           ))))
   `(minibuffer-prompt   ((t  (     :foreground ,konosuba-blue                                                 ))))
   `(region              ((t  (     :background ,konosuba-region     :foreground  unspecified                  ))))
   `(secondary-selection ((t ,(list :background  konosuba-region     :foreground 'unspecified                  ))))
   `(trailing-whitespace ((t ,(list :foreground  konosuba-black      :background  konosuba-magenta             ))))
   `(tooltip             ((t ,(list :background  konosuba-light-gray :foreground  konosuba-light-white         ))))
   `(warning             ((t  (     :foreground ,konosuba-magenta    :weight       bold                        ))))
   `(header-line         ((t  (     :background ,konosuba-dark-gray  :foreground ,konosuba-light-white :box nil))))

   ;; Calendar
   `(holiday-face ((t (:foreground ,konosuba-magenta))))

   ;; Compilation
   `(compilation-info           ((t ,(list :foreground  konosuba-yellow                :inherit 'unspecified))))
   `(compilation-warning        ((t ,(list :foreground  konosuba-green   :bold t       :inherit 'unspecified))))
   `(compilation-error          ((t  (     :foreground ,konosuba-magenta                                    ))))
   `(compilation-mode-line-fail ((t ,(list :foreground  konosuba-magenta :weight 'bold :inherit 'unspecified))))
   `(compilation-mode-line-exit ((t ,(list :foreground  konosuba-yellow  :weight 'bold :inherit 'unspecified))))

   ;; Completion
   `(completions-annotations ((t (:inherit 'shadow))))

   ;; Custom
   `(custom-state ((t (:foreground ,konosuba-yellow))))

   ;; Diff
   `(diff-removed ((t ,(list :foreground konosuba-magenta :background 'unspecified))))
   `(diff-added   ((t ,(list :foreground konosuba-yellow  :background 'unspecified))))

   ;; Dired
   `(dired-directory ((t  (     :foreground ,konosuba-blue  :weight   bold       ))))
   `(dired-ignored   ((t ,(list :foreground  konosuba-green :inherit 'unspecified))))

   ;; Ebrowse
   `(ebrowse-root-class ((t (:foreground ,konosuba-blue :weight bold))))
   `(ebrowse-progress   ((t (:background ,konosuba-blue             ))))

   ;; Egg
   `(egg-branch           ((t (:foreground  ,konosuba-red       ))))
   `(egg-branch-mono      ((t (:foreground  ,konosuba-red       ))))
   `(egg-diff-add         ((t (:foreground  ,konosuba-yellow    ))))
   `(egg-diff-del         ((t (:foreground  ,konosuba-magenta   ))))
   `(egg-diff-file-header ((t (:foreground  ,konosuba-cyan      ))))
   `(egg-help-header-1    ((t (:foreground  ,konosuba-red       ))))
   `(egg-help-header-2    ((t (:foreground  ,konosuba-blue      ))))
   `(egg-log-HEAD-name    ((t (:box (:color ,konosuba-foreground)))))
   `(egg-reflog-mono      ((t (:foreground  ,konosuba-light-dimm))))
   `(egg-section-title    ((t (:foreground  ,konosuba-red       ))))
   `(egg-text-base        ((t (:foreground  ,konosuba-foreground))))
   `(egg-term             ((t (:foreground  ,konosuba-red       ))))

   ;; ERC
   `(erc-button-nick-default-face ((t (:inherit    'nil                                 ))))
   `(erc-notice-face              ((t (:foreground ,konosuba-teal                       ))))
   `(erc-input-face               ((t (:foreground ,konosuba-foreground                 ))))
   `(erc-default-face             ((t (:inherit    'default                             ))))
   `(erc-direct-msg-face          ((t (:foreground ,konosuba-yellow                     ))))
   `(erc-error-face               ((t (:foreground ,konosuba-magenta                    ))))
   `(erc-header-line              ((t (:inherit    'header-line                         ))))
   `(erc-nick-msg-face            ((t (:foreground ,konosuba-yellow                     ))))
   `(erc-nick-prefix-face         ((t (:inherit    'erc-nick-default-face               ))))
   `(erc-my-nick-prefix-face      ((t (:inherit    'erc-my-nick-face                    ))))
   `(erc-timestamp-face           ((t (:foreground ,konosuba-blue   :bold t             ))))
   `(erc-nick-default-face        ((t (:foreground ,konosuba-yellow :bold t             ))))
   `(erc-my-nick-face             ((t (:foreground ,konosuba-red    :bold t             ))))
   `(erc-current-nick-face        ((t (:foreground ,konosuba-green  :bold t             ))))
   `(erc-prompt-face              ((t (:foreground ,konosuba-red    :bold t             ))))
   `(erc-action-face              ((t (                             :bold t             ))))
   `(erc-command-indicator-face   ((t (                             :bold t             ))))
   `(erc-button                   ((t (                             :bold t :underline t))))

   ;; EShell
   `(eshell-ls-backup     ((t (:foreground ,konosuba-green ))))
   `(eshell-ls-directory  ((t (:foreground ,konosuba-blue  ))))
   `(eshell-ls-executable ((t (:foreground ,konosuba-yellow))))
   `(eshell-ls-symlink    ((t (:foreground ,konosuba-red   ))))

   ;; Font Lock
   `(font-lock-builtin-face           ((t (:foreground ,konosuba-yellow        ))))
   `(font-lock-comment-face           ((t (:foreground ,konosuba-comment       ))))
   `(font-lock-comment-delimiter-face ((t (:foreground ,konosuba-comment       ))))
   `(font-lock-constant-face          ((t (:foreground ,konosuba-quartz        ))))
   `(font-lock-doc-face               ((t (:foreground ,konosuba-green         ))))
   `(font-lock-doc-string-face        ((t (:foreground ,konosuba-green         ))))
   `(font-lock-function-name-face     ((t (:foreground ,konosuba-blue          ))))
   `(font-lock-keyword-face           ((t (:foreground ,konosuba-yellow :bold t))))
   `(font-lock-preprocessor-face      ((t (:foreground ,konosuba-quartz        ))))
   `(font-lock-reference-face         ((t (:foreground ,konosuba-quartz        ))))
   `(font-lock-string-face            ((t (:foreground ,konosuba-green         ))))
   `(font-lock-type-face              ((t (:foreground ,konosuba-quartz        ))))
   `(font-lock-variable-name-face     ((t (:foreground ,konosuba-dark-white    ))))
   `(font-lock-warning-face           ((t (:foreground ,konosuba-magenta       ))))

   ;; Flymake
   `(flymake-errline
     ((((supports :underline (:style wave                     )))
       (:underline (:style wave :color ,konosuba-magenta)
                   :foreground          unspecified
                   :background          unspecified
                   :inherit             unspecified           ))
      (t (         :foreground         ,konosuba-magenta
                   :weight bold :underline t                  ))))

   `(flymake-warnline
     ((((supports :underline (:style wave                      )))
       (:underline (:style wave :color ,konosuba-red)
                   :foreground          unspecified
                   :background          unspecified
                   :inherit             unspecified            ))
       (t (        :foreground         ,konosuba-red
                   :weight bold :underline t                   ))))

   `(flymake-infoline
     ((((supports :underline (:style wave                      )))
       (:underline (:style wave :color ,konosuba-yellow)
                   :foreground          unspecified
                   :background          unspecified
                   :inherit             unspecified            ))
       (t (        :foreground         ,konosuba-yellow
                   :weight bold :underline t                   ))))

   ;; Flyspell
   `(flyspell-incorrect
     ((((supports :underline (:style wave                          )))
       (:underline (:style wave :color      ,konosuba-magenta)
                    :inherit                 unspecified           ))
       (t (         :foreground             ,konosuba-magenta
                    :weight bold :underline t                      ))))

   `(flyspell-duplicate
     ((((supports :underline (:style wave                          )))
       (:underline (:style wave :color ,konosuba-red)
                    :inherit            unspecified                ))
       (t (         :foreground        ,konosuba-red
                    :weight bold :underline t                      ))))

   ;; Helm
   `(helm-candidate-number   ((t ,(list :background  konosuba-dark-brown :foreground  konosuba-red        :bold t))))
   `(helm-ff-directory       ((t ,(list :foreground  konosuba-blue       :background  konosuba-background :bold t))))
   `(helm-ff-executable      ((t  (     :foreground ,konosuba-yellow                                             ))))
   `(helm-ff-file            ((t  (     :foreground ,konosuba-foreground :inherit     unspecified                ))))
   `(helm-ff-invalid-symlink ((t ,(list :foreground  konosuba-background :background  konosuba-magenta           ))))
   `(helm-ff-symlink         ((t  (     :foreground ,konosuba-red        :bold t                                 ))))
   `(helm-selection-line     ((t  (     :background ,konosuba-dark-gray                                          ))))
   `(helm-selection          ((t  (     :background ,konosuba-dark-gray  :underline   nil                        ))))
   `(helm-source-header      ((t ,(list :foreground  konosuba-red        :background  konosuba-background
                             :box (list :line-width -1                   :style      'released-button            )))))

   ;; Ido
   `(ido-first-match ((t (:foreground ,konosuba-red    :bold   nil ))))
   `(ido-only-match  ((t (:foreground ,konosuba-orange :weight bold))))
   `(ido-subdir      ((t (:foreground ,konosuba-blue   :weight bold))))

   ;; Info
   `(info-xref    ((t (:foreground ,konosuba-blue))))
   `(info-visited ((t (:foreground ,konosuba-cyan))))

   ;; Jabber
   `(jabber-chat-prompt-foreign    ((t ,(list :foreground  konosuba-green :bold nil))))
   `(jabber-chat-prompt-local      ((t  (     :foreground ,konosuba-red            ))))
   `(jabber-chat-prompt-system     ((t  (     :foreground ,konosuba-yellow         ))))
   `(jabber-rare-time-face         ((t  (     :foreground ,konosuba-yellow         ))))
   `(jabber-roster-user-online     ((t  (     :foreground ,konosuba-yellow         ))))
   `(jabber-activity-face          ((t  (     :foreground ,konosuba-magenta        ))))
   `(jabber-activity-personal-face ((t  (     :foreground ,konosuba-red   :bold t  ))))

   ;; Line Highlighting
   `(highlight                   ((t  (     :background ,konosuba-red       :foreground ,konosuba-background))))
   `(highlight-current-line-face ((t ,(list :background  konosuba-dark-gray :foreground  nil                ))))

   ;; Line Numbers
   `(line-number              ((t (:inherit            default     :foreground    ,konosuba-light-gray
                                   :distant-foreground unspecified
                                   :weight             normal      :slant          unspecified
                                   :underline          unspecified :strike-through unspecified
                                   ))))

   `(line-number-current-line ((t (:inherit            line-number :foreground    ,konosuba-red
                                   :distant-foreground unspecified
                                   :weight             bold        :slant          unspecified
                                   :underline          unspecified :strike-through unspecified
                                   ))))

   ;; Linum
   `(linum ((t `(list :foreground konosuba-green :background konosuba-background))))

   ;; Magit
   `(magit-tag                   ((t ,(list :foreground  konosuba-red        :background konosuba-background))))
   `(magit-blame-heading         ((t ,(list :background  konosuba-dark-gray  :foreground konosuba-foreground))))
   `(magit-log-head-label-remote ((t ,(list :foreground  konosuba-yellow     :background konosuba-dark-gray ))))
   `(magit-log-head-label-local  ((t ,(list :foreground  konosuba-blue       :background konosuba-dark-gray ))))
   `(magit-log-head-label-tags   ((t ,(list :foreground  konosuba-red        :background konosuba-dark-gray ))))
   `(magit-log-head-label-head   ((t ,(list :foreground  konosuba-foreground :background konosuba-dark-gray ))))
   `(magit-branch                ((t  (     :foreground ,konosuba-blue                                      ))))
   `(magit-diff-hunk-header      ((t  (     :background ,konosuba-dark-brown                                ))))
   `(magit-diff-file-header      ((t  (     :background ,konosuba-light-gray                                ))))
   `(magit-log-sha1              ((t  (     :foreground ,konosuba-magenta                                   ))))
   `(magit-log-author            ((t  (     :foreground ,konosuba-green                                     ))))
   `(magit-item-highlight        ((t  (     :background ,konosuba-dark-gray                                 ))))

   ;; Message
   `(message-header-name ((t (:foreground ,konosuba-yellow))))

   ;; Mode Line
   `(mode-line           ((t ,(list :background konosuba-dark-gray :foreground konosuba-light-white))))
   `(mode-line-buffer-id ((t ,(list :background konosuba-dark-gray :foreground konosuba-light-white))))
   `(mode-line-inactive  ((t ,(list :background konosuba-dark-gray :foreground konosuba-foreground ))))

   ;; Neo Dir
   `(neo-dir-link-face ((t (:foreground ,konosuba-blue))))

   ;; Org Mode
   `(org-column-title      ((t (:background ,konosuba-background :underline t :weight bold))))
   `(org-agenda-structure  ((t (:foreground ,konosuba-blue                                ))))
   `(org-column            ((t (:background ,konosuba-background                          ))))
   `(org-done              ((t (:foreground ,konosuba-yellow                              ))))
   `(org-todo              ((t (:foreground ,konosuba-green                               ))))
   `(org-upcoming-deadline ((t (:foreground ,konosuba-red                                 ))))

   ;; Search
   `(isearch                     ((t ,(list :foreground konosuba-black :background konosuba-light-white))))
   `(isearch-fail                ((t ,(list :foreground konosuba-black :background konosuba-red        ))))
   `(isearch-lazy-highlight-face ((t ,(list :foreground konosuba-blue  :background konosuba-light-dimm ))))

   ;; Sh
   `(sh-quoted-exec ((t (:foreground ,konosuba-magenta))))

   ;; Show Paren
   `(show-paren-match         ((t (:background ,konosuba-cyan      ))))
   `(show-paren-match-face    ((t (:inherit    'show-paren-match   ))))
   `(show-paren-mismatch      ((t (:background ,konosuba-magenta   ))))
   `(show-paren-mismatch-face ((t (:inherit    'show-paren-mismatch))))

   ;; Slime
   `(slime-repl-inputed-output-face ((t (:foreground ,konosuba-magenta))))

   ;; Tuareg
   `(tuareg-font-lock-governing-face ((t (:foreground ,konosuba-red))))

   ;; Speedbar
   `(speedbar-directory-face ((t ,(list :foreground konosuba-blue :weight 'bold))))
   `(speedbar-file-face      ((t  (     :foreground ,konosuba-foreground       ))))
   `(speedbar-highlight-face ((t  (     :background ,konosuba-dark-gray        ))))
   `(speedbar-selected-face  ((t  (     :foreground ,konosuba-magenta          ))))
   `(speedbar-tag-face       ((t  (     :foreground ,konosuba-red              ))))

   ;; Which Function
   `(which-func ((t (:foreground ,konosuba-cyan))))

   ;; Whitespace
   `(whitespace-space            ((t ,(list :background  konosuba-background  :foreground konosuba-dark-gray ))))
   `(whitespace-tab              ((t ,(list :background  konosuba-background  :foreground konosuba-dark-gray ))))
   `(whitespace-hspace           ((t ,(list :background  konosuba-background  :foreground konosuba-dark-brown))))
   `(whitespace-line             ((t ,(list :background  konosuba-dark-brown  :foreground konosuba-magenta   ))))
   `(whitespace-newline          ((t ,(list :background  konosuba-background  :foreground konosuba-dark-brown))))
   `(whitespace-empty            ((t ,(list :background  konosuba-light-brown :foreground konosuba-dark-brown))))
   `(whitespace-indentation      ((t ,(list :background  konosuba-light-white :foreground konosuba-red       ))))
   `(whitespace-space-after-tab  ((t ,(list :background  konosuba-light-white :foreground konosuba-blue      ))))
   `(whitespace-space-before-tab ((t ,(list :background  konosuba-green       :foreground konosuba-green     ))))
   `(whitespace-trailing         ((t ,(list :inherit    'trailing-whitespace                                 ))))

   ;; Tab-bar
   `(tab-bar              ((t (:background ,konosuba-dark-gray :foreground ,konosuba-light-gray      ))))
   `(tab-bar-tab          ((t (:background  unspecified        :foreground ,konosuba-red :weight bold))))
   `(tab-bar-tab-inactive ((t (:background  unspecified                                              ))))

   ;; Vterm / Ansi-term
   `(term-color-black   ((t (:foreground ,konosuba-light-brown :background ,konosuba-light-gray ))))
   `(term-color-red     ((t (:foreground ,konosuba-red         :background ,konosuba-green      ))))
   `(term-color-green   ((t (:foreground ,konosuba-green       :background ,konosuba-yellow     ))))
   `(term-color-blue    ((t (:foreground ,konosuba-blue        :background ,konosuba-blue       ))))
   `(term-color-yellow  ((t (:foreground ,konosuba-yellow      :background ,konosuba-red        ))))
   `(term-color-magenta ((t (:foreground ,konosuba-cyan        :background ,konosuba-cyan       ))))
   `(term-color-cyan    ((t (:foreground ,konosuba-green       :background ,konosuba-green      ))))
   `(term-color-white   ((t (:foreground ,konosuba-foreground  :background ,konosuba-light-white))))

   ;; Company-mode
   `(company-tooltip                      ((t (:foreground ,konosuba-foreground :background ,konosuba-dark-gray ))))
   `(company-tooltip-annotation           ((t (:foreground ,konosuba-green      :background ,konosuba-dark-gray ))))
   `(company-tooltip-annotation-selection ((t (:foreground ,konosuba-green      :background ,konosuba-background))))
   `(company-tooltip-selection            ((t (:foreground ,konosuba-foreground :background ,konosuba-background))))
   `(company-preview-common               ((t (:foreground ,konosuba-yellow     :background ,konosuba-background))))
   `(company-tooltip-mouse                ((t (:background ,konosuba-background                                 ))))
   `(company-tooltip-common               ((t (:foreground ,konosuba-yellow                                     ))))
   `(company-tooltip-common-selection     ((t (:foreground ,konosuba-yellow                                     ))))
   `(company-scrollbar-fg                 ((t (:background ,konosuba-background                                 ))))
   `(company-scrollbar-bg                 ((t (:background ,konosuba-dark-brown                                 ))))
   `(company-preview                      ((t (:background ,konosuba-yellow                                     ))))

   ;; Proof General
   `(proof-locked-face ((t (:background ,konosuba-dark-dimm))))

   ;; Orderless
   `(orderless-match-face-0 ((t (:foreground ,konosuba-red   ))))
   `(orderless-match-face-1 ((t (:foreground ,konosuba-yellow))))
   `(orderless-match-face-2 ((t (:foreground ,konosuba-green ))))
   `(orderless-match-face-3 ((t (:foreground ,konosuba-green ))))
   ))

;;;###autoload
(when load-file-name
  (add-to-list 'custom-theme-load-path
               (file-name-as-directory (file-name-directory load-file-name))))

(provide-theme 'konosuba)

;; Local Variables:
;; no-byte-compile: t
;; indent-tabs-mode: nil
;; eval: (when (fboundp 'colorful-mode) (colorful-mode +1))
;; End:
;;; konosuba-theme.el ends here.

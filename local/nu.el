(require 'dired)
(defun nu/keep-region-active-after-copy (&rest _args)
  (when (use-region-p)
    (setq deactivate-mark nil)
    (setq mark-active t)))

(defun nu/undo ()
  (interactive)
  (deactivate-mark)
  (undo-only))

(defun nu/undo-redo ()
  (interactive)
  (deactivate-mark)
  (undo-redo))

(defconst nu/movement-commands
  '(forward-char           backward-char
    right-char             left-char
    next-line              previous-line
    forward-word           backward-word
    forward-paragraph      backward-paragraph
    beginning-of-line      end-of-line
    move-beginning-of-line move-end-of-line
    beginning-of-buffer    end-of-buffer
    scroll-up-command      scroll-down-command))

(defun nu/pre-command-deselect-on-move ()
  (when (and (use-region-p)
             (memq this-command nu/movement-commands)
             (not this-command-keys-shift-translated))
    (deactivate-mark)
    (when (boundp 'cua--last-region-shifted)
      (setq cua--last-region-shifted nil))))

(defun nu/move-text--block-lines ()
  (if (use-region-p)
      (let ((first (line-number-at-pos (region-beginning)))
            (last  (save-excursion
                     (goto-char (region-end))
                     (if (bolp)
                         (max (line-number-at-pos (region-beginning))
                              (1- (line-number-at-pos)))
                       (line-number-at-pos)))))
        (cons first last))
    (cons (line-number-at-pos) (line-number-at-pos))))

(defun nu/move-text--last-line ()
  (save-excursion
    (goto-char (point-max))
    (if (bolp) (max 1 (1- (line-number-at-pos)))
      (line-number-at-pos))))

(defun nu/move-text--line-at (n)
  (save-excursion
    (goto-char (point-min))
    (forward-line (1- n))
    (buffer-substring-no-properties (line-beginning-position)
                                    (line-end-position))))

(defun nu/move-text-internal (dir)
  (let* ((col      (current-column))
         (regionp  (use-region-p))
         (bounds   (nu/move-text--block-lines))
         (first    (car bounds))
         (last     (cdr bounds))
         (cur-line (line-number-at-pos)))
    (unless (or (and (= dir -1) (<= first 1))
                (and (= dir  1) (>= last (nu/move-text--last-line))))
      (let* ((new-first (+ first dir))
             (new-last  (+ last  dir))
             (pivot-n   (if (= dir 1) (1+ last) (1- first)))
             (pivot     (nu/move-text--line-at pivot-n))
             (block     (mapcar #'nu/move-text--line-at
                                (number-sequence first last)))
             (range-beg (min first pivot-n))
             (range-end (max last  pivot-n))
             (new-lines (if (= dir 1)
                            (cons pivot block)
                          (append block (list pivot)))))
        (atomic-change-group
          (save-excursion
            (goto-char (point-min))
            (forward-line (1- range-beg))
            (let ((beg (point)))
              (forward-line (- range-end range-beg))
              (delete-region beg (line-end-position))
              (insert (mapconcat #'identity new-lines "\n")))))
        (if regionp
            (progn
              (set-mark (save-excursion
                          (goto-char (point-min))
                          (forward-line (1- new-first))
                          (point)))
              (goto-char (point-min))
              (forward-line (1- new-last))
              (goto-char (line-end-position))
              (setq deactivate-mark nil))
          (goto-char (point-min))
          (forward-line (1- (+ cur-line dir)))
          (move-to-column col))))))

(defun nu/move-text-up (arg)
  (interactive "p")
  (dotimes (_ (or arg 1)) (nu/move-text-internal -1)))

(defun nu/move-text-down (arg)
  (interactive "p")
  (dotimes (_ (or arg 1)) (nu/move-text-internal 1)))

(defun nu/text-scale-increase ()
  (interactive)
  (text-scale-increase 1))

(defun nu/text-scale-decrease ()
  (interactive)
  (text-scale-increase -1))

(defun nu/dedent-rigidly ()
  (interactive)
  (let* ((step tab-width)
         (start (if (use-region-p) (region-beginning) (line-beginning-position)))
         (end   (if (use-region-p) (region-end)       (line-end-position))))
    (let ((deactivate-mark nil))
      (indent-rigidly start end (- step)))))

(defun nu/indent-more-rigidly ()
  (interactive)
  (if (use-region-p)
      (let ((start (region-beginning))
            (end   (region-end)))
        (let ((deactivate-mark nil))
          (indent-region start end)))
    (indent-for-tab-command)))

(defun nu/toggle-comment (beg end)
  (interactive
   (if (use-region-p)
       (list (save-excursion (goto-char (region-beginning))
                             (line-beginning-position))
             (save-excursion (goto-char (region-end))
                             (if (bolp) (point) (line-end-position))))
     (list (line-beginning-position) (line-end-position))))
  (let ((deactivate-mark nil))
    (comment-or-uncomment-region beg end)))

(defun nu/goto-link-source ()
  (interactive)
  (require 'subr-x)
  (cond
   ((string= (buffer-name) "*games*")
    (let* ((line  (string-trim (thing-at-point 'line t)))
           (game  (intern-soft line)))
      (if (and game (commandp game))
          (progn
            (kill-buffer "*games*")
            (call-interactively game))
        (message "No game found at point: %s" line))))

   ((string= (buffer-name) "*probe-langs*")
    (let* ((line   (string-trim (thing-at-point 'line t)))
           (opener (gethash line pb/lang-openers)))
      (if opener
          (progn
            (kill-buffer "*probe-langs*")
            (call-interactively opener))
        (message "No language found at point: %s" line))))

   ((derived-mode-p 'compilation-mode)
    (condition-case err
        (compile-goto-error)
      (error (message "No error location at point: %s" (error-message-string err)))))

   ((derived-mode-p 'org-mode)
    (let* ((el (ignore-errors (org-element-context)))
           (is-link (and el (eq (org-element-type el) 'link)))
           (raw (and is-link (org-element-property :raw-link el)))
           (type (and is-link (org-element-property :type el))))
      (if (and raw (or (string= type "eww") (string-match-p "\\`eww:" raw)))
          (let ((url (replace-regexp-in-string "\\`eww:" "" raw)))
            (require 'eww)
            (eww-browse-url url)
            (delete-other-windows))
        (let ((cmd (key-binding (kbd "C-u C-c C-o C-x 1"))))
          (if (commandp cmd)
              (call-interactively cmd)
            (execute-kbd-macro (kbd "C-u C-c C-o C-x 1")))))))

   ((derived-mode-p 'eww-mode)
    (let ((url (or (and (fboundp 'eww-link-at-point) (eww-link-at-point))
                   (get-text-property (point) 'shr-url)
                   (thing-at-point 'url))))
      (if url
          (progn
            (require 'eww)
            (eww-browse-url (string-trim url))
            (delete-other-windows)))))

   ((derived-mode-p 'prog-mode)
    (let ((sym (thing-at-point 'symbol t)))
      (if (not sym)
          (message "No symbol at point")
        (let ((pattern (concat "^[a-zA-Z_][^;\n]*\\b"
                               (regexp-quote sym)
                               "\\b[^;\n]*("))
              (origin (point)))
          (goto-char (point-min))
          (if (re-search-forward pattern nil t)
              (beginning-of-line)
            (goto-char origin)
            (condition-case err
                (xref-find-definitions sym)
              (error (message "No definition found for '%s'" sym))))))))

   (t
    (let ((url (thing-at-point 'url)))
      (if url
          (browse-url (string-trim url))
        (let ((cmd (key-binding (kbd "C-u C-c C-o C-x 1"))))
          (if (commandp cmd)
              (call-interactively cmd)
            (execute-kbd-macro (kbd "C-u C-c C-o C-x 1")))))))))

(defun nu/wrap-nav--on-last-line-p ()
  (save-excursion
    (end-of-line)
    (not (re-search-forward "^." nil t))))

(defun nu/wrap-nav--last-line-number ()
  (save-excursion
    (goto-char (point-max))
    (if (bolp)
        (max 1 (1- (line-number-at-pos)))
      (line-number-at-pos))))

(defun nu/wrap-nav--trim-edge-newlines ()
  (let ((inhibit-read-only t))
    (save-excursion
      (goto-char (point-min))
      (when (and (< (point) (point-max))
                 (eq (char-after) ?\n))
        (delete-char 1))
      (goto-char (point-max))
      (when (and (> (point) (point-min))
                 (eq (char-before) ?\n))
        (delete-char -1)))))

(defun nu/wrap-nav--dired-file-lines ()
  (let (lines)
    (save-excursion
      (goto-char (point-min))
      (while (not (eobp))
        (when (ignore-errors (dired-get-filename nil t))
          (push (line-beginning-position) lines))
        (forward-line 1)))
    (nreverse lines)))

(defun nu/wrap-nav--dired-current-index (lines)
  (let ((pos (line-beginning-position))
        (idx 0)
        (found 0))
    (dolist (line lines)
      (when (= pos line)
        (setq found idx))
      (setq idx (1+ idx)))
    found))

(defun nu/wrap-nav--dired-goto-index (lines idx)
  (let* ((count (length lines))
         (pos (nth (mod idx count) lines)))
    (when pos
      (goto-char pos)
      (dired-move-to-filename))))

(defun nu/wrap-nav--dired-next-line ()
  (let ((lines (nu/wrap-nav--dired-file-lines)))
    (when lines
      (nu/wrap-nav--dired-goto-index lines
                                     (1+ (nu/wrap-nav--dired-current-index lines))))))

(defun nu/wrap-nav--dired-previous-line ()
  (let ((lines (nu/wrap-nav--dired-file-lines)))
    (when lines
      (nu/wrap-nav--dired-goto-index lines
                                     (1- (nu/wrap-nav--dired-current-index lines))))))

(defun nu/wrap-next-line ()
  (interactive)
  (if (derived-mode-p 'dired-mode)
      (nu/wrap-nav--dired-next-line)
    (let ((col (current-column)))
      (if (= (line-number-at-pos) (nu/wrap-nav--last-line-number))
          (goto-char (point-min))
        (forward-line 1))
      (move-to-column col))))

(defun nu/wrap-previous-line ()
  (interactive)
  (if (derived-mode-p 'dired-mode)
      (nu/wrap-nav--dired-previous-line)
    (let ((col (current-column)))
      (if (= (line-number-at-pos) 1)
          (goto-char (point-max))
        (forward-line -1))
      (move-to-column col))))

(defun nu/wrap-forward-char ()
  (interactive)
  (if (eolp)
      (beginning-of-line)
    (forward-char)))

(defun nu/wrap-backward-char ()
  (interactive)
  (if (bolp)
      (end-of-line)
    (backward-char)))

(defconst nu/dashboard-nav-start-line 15)
(defconst nu/dashboard-nav-end-line   19)

(defvar-local nu/dashboard-nav--items nil)

(defun nu/dashboard-nav--collect-items ()
  (setq nu/dashboard-nav--items nil)
  (save-excursion
    (goto-char (point-min))
    (forward-line (1- nu/dashboard-nav-start-line))
    (dotimes (_ (1+ (- nu/dashboard-nav-end-line
                      nu/dashboard-nav-start-line)))
      (let ((bol (line-beginning-position))
            (eol (line-end-position)))
        (if (and (re-search-forward "^\\[\\[[^]\n]+\\]\\[\\(.*\\)\\]\\]$" eol t)
                 (match-beginning 1))
            (push (cons (match-beginning 1) (match-end 1)) nu/dashboard-nav--items)
          (push (cons bol eol) nu/dashboard-nav--items)))
      (forward-line 1)))
  (setq nu/dashboard-nav--items (nreverse nu/dashboard-nav--items)))

(defun nu/dashboard-nav--item-count ()
  (length nu/dashboard-nav--items))

(defun nu/dashboard-nav--current-index ()
  (let ((pos (point))
        (idx 0)
        (found 0))
    (dolist (item nu/dashboard-nav--items)
      (when (and (>= pos (car item))
                 (<= pos (cdr item)))
        (setq found idx))
      (setq idx (1+ idx)))
    found))

(defun nu/dashboard-nav--item-at-index (idx)
  (nth (mod idx (nu/dashboard-nav--item-count)) nu/dashboard-nav--items))

(defun nu/dashboard-nav--goto-item (idx column)
  (pcase-let* ((`(,beg . ,end) (nu/dashboard-nav--item-at-index idx))
               (len (max 1 (- end beg)))
               (col (min (or column 0) len))
               (new (+ beg col)))
    (goto-char new)))

(defun nu/dashboard-nav--normalize-point ()
  (let ((inside nil))
    (dolist (item nu/dashboard-nav--items)
      (when (and (>= (point) (car item))
                 (<= (point) (cdr item)))
        (setq inside t)))
    (unless inside
      (nu/dashboard-nav--goto-item 0 0))))

(defun nu/dashboard-nav-left ()
  (interactive)
  (unless nu/dashboard-nav--items
    (nu/dashboard-nav--collect-items))
  (let* ((idx (nu/dashboard-nav--current-index))
         (item (nu/dashboard-nav--item-at-index idx))
         (beg (car item))
         (end (cdr item)))
    (if (> (point) beg)
        (backward-char)
      (goto-char end))))

(defun nu/dashboard-nav-right ()
  (interactive)
  (unless nu/dashboard-nav--items
    (nu/dashboard-nav--collect-items))
  (let* ((idx (nu/dashboard-nav--current-index))
         (item (nu/dashboard-nav--item-at-index idx))
         (beg (car item))
         (end (cdr item)))
    (if (< (point) end)
        (forward-char)
      (goto-char beg))))

(defun nu/dashboard-nav-up ()
  (interactive)
  (unless nu/dashboard-nav--items
    (nu/dashboard-nav--collect-items))
  (let* ((idx (nu/dashboard-nav--current-index))
         (item (nu/dashboard-nav--item-at-index idx))
         (beg (car item))
         (col (- (point) beg)))
    (nu/dashboard-nav--goto-item (1- idx) col)))

(defun nu/dashboard-nav-down ()
  (interactive)
  (unless nu/dashboard-nav--items
    (nu/dashboard-nav--collect-items))
  (let* ((idx (nu/dashboard-nav--current-index))
         (item (nu/dashboard-nav--item-at-index idx))
         (beg (car item))
         (col (- (point) beg)))
    (nu/dashboard-nav--goto-item (1+ idx) col)))

(defvar nu/dashboard-nav-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "<down>")  #'nu/dashboard-nav-down)
    (define-key map (kbd "C-n")     #'nu/dashboard-nav-down)
    (define-key map (kbd "<up>")    #'nu/dashboard-nav-up)
    (define-key map (kbd "C-p")     #'nu/dashboard-nav-up)
    (define-key map (kbd "<right>") #'nu/dashboard-nav-right)
    (define-key map (kbd "C-f")     #'nu/dashboard-nav-right)
    (define-key map (kbd "<left>")  #'nu/dashboard-nav-left)
    (define-key map (kbd "C-b")     #'nu/dashboard-nav-left)
    map))

(define-minor-mode nu/dashboard-nav-mode
  "Pacman-style wrap-around navigation for the dash dashboard."
  :keymap nu/dashboard-nav-mode-map
  (if nu/dashboard-nav-mode
      (progn
        (unless nu/dashboard-nav--items
          (nu/dashboard-nav--collect-items))
        (nu/dashboard-nav--normalize-point)
        (add-hook 'post-command-hook #'nu/dashboard-nav--normalize-point nil t))
    (remove-hook 'post-command-hook #'nu/dashboard-nav--normalize-point t)))

(defvar nu/wrap-nav-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "<down>")  #'nu/wrap-next-line)
    (define-key map (kbd "C-n")     #'nu/wrap-next-line)
    (define-key map (kbd "<up>")    #'nu/wrap-previous-line)
    (define-key map (kbd "C-p")     #'nu/wrap-previous-line)
    (define-key map (kbd "<right>") #'nu/wrap-forward-char)
    (define-key map (kbd "C-f")     #'nu/wrap-forward-char)
    (define-key map (kbd "<left>")  #'nu/wrap-backward-char)
    (define-key map (kbd "C-b")     #'nu/wrap-backward-char)
    map))

(define-minor-mode nu/wrap-nav-mode
  "Pacman-style wrap-around navigation for read-only list buffers."
  :keymap nu/wrap-nav-mode-map
  (when nu/wrap-nav-mode
    (nu/wrap-nav--trim-edge-newlines)))

(defun nu/open-games-buffer ()
  (interactive)
  (let ((games-list '(
                      ;"5x5"
                      ;"blackbox"
                      ;"bubbles"
                      ;"dunnet"
                      ;"gomoku"
                      ;"hanoi"
                      ;"life"
                      ;"pong"
                      "snake"
                      "solitaire"
                      "tetris"
                      "zone"
                      ))
        (buf (get-buffer-create "*games*")))
    (with-current-buffer buf
      (let ((inhibit-read-only t))
        (erase-buffer)
        (insert (mapconcat #'identity games-list "\n")))
      (read-only-mode 1)
      (nu/wrap-nav-mode 1)
      (goto-char (point-min)))
    (switch-to-buffer buf)))

(defun nu/select-line ()
  (interactive)
  (goto-char (line-beginning-position))
  (set-mark (point))
  (goto-char (line-end-position))
  (activate-mark))

(defun nu/select-word-or-next ()
  (interactive)
  (if (use-region-p)
      (mc/mark-next-like-this 1)
    (let ((bounds (bounds-of-thing-at-point 'symbol)))
      (if bounds
          (progn
            (goto-char (cdr bounds))
            (set-mark  (car bounds))
            (activate-mark))
        (message "No symbol at point")))))

(defun nu/select-all-occurrences ()
  (interactive)
  (unless (use-region-p)
    (let ((bounds (bounds-of-thing-at-point 'symbol)))
      (if bounds
          (progn
            (goto-char (cdr bounds))
            (set-mark  (car bounds))
            (activate-mark))
        (message "No symbol at point")
        (cl-return-from nu/select-all-occurrences))))
  (when (use-region-p)
    (mc/mark-all-like-this)))

(defun nu/remove-all-comments ()
  (interactive)
  (let ((inhibit-read-only t)
        regions)
    (save-excursion
      (goto-char (point-min))
      (while (< (point) (point-max))
        (let ((ppss (syntax-ppss)))
          (cond
           ((nth 4 ppss)
            (let* ((cbeg (nth 8 ppss))
                   (lbeg (save-excursion
                           (goto-char cbeg)
                           (line-beginning-position)))
                   (whole-line-p
                    (string-match-p
                     "\\`[[:space:]]*\\'"
                     (buffer-substring-no-properties lbeg cbeg))))
              (goto-char cbeg)
              (forward-comment 1)
              (let ((cend (point)))
                (push
                 (if whole-line-p
                     (cons lbeg
                           (if (and (< cend (point-max))
                                    (eq (char-after cend) ?\n))
                               (1+ cend)
                             cend))
                   (cons (save-excursion
                           (goto-char cbeg)
                           (skip-syntax-backward " ")
                           (point))
                         cend))
                 regions))))
           ((nth 3 ppss)
            (goto-char (nth 8 ppss))
            (condition-case nil
                (forward-sexp 1)
              (error (forward-char 1))))
           (t
            (forward-char 1))))))
    (dolist (r (sort regions (lambda (a b) (> (car a) (car b)))))
      (delete-region (car r) (cdr r)))
    (message "Comments removed.")))

(defun nu/man-pages-from-manpath ()
  (let (pages)
    (dolist (dir (split-string (or (getenv "MANPATH") "") ":" t))
      (dolist (sec-dir (directory-files dir t "^man[0-9]" t))
        (when (file-directory-p sec-dir)
          (let ((sec (substring (file-name-nondirectory sec-dir) 3)))
            (dolist (f (directory-files sec-dir nil "[^.]" t))
              (let* ((base (replace-regexp-in-string "\\.gz$\\|\\.bz2$\\|\\.xz$" "" f))
                     (name (file-name-sans-extension base)))
                (push (format "%s(%s)" name sec) pages)))))))
    (delete-dups pages)))

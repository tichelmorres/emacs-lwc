(defconst ren/root-dir (expand-file-name "ren" (temporary-file-directory)))
(defconst ren/latex-dir (expand-file-name "LaTeX" ren/root-dir))
(defconst ren/markdown-dir (expand-file-name "Markdown" ren/root-dir))

(defun ren--ensure-output-dirs ()
  (dolist (dir (list ren/root-dir ren/latex-dir ren/markdown-dir))
    (unless (file-directory-p dir)
      (make-directory dir t))))

(defun ren--slugify (s)
  (replace-regexp-in-string "[^[:alnum:]._ -]+" "_" s))

(defun ren--short-hash (file)
  (substring (secure-hash 'sha1 (expand-file-name file)) 0 10))

(defun ren--output-file (dir file ext)
  (ren--ensure-output-dirs)
  (expand-file-name
   (format "%s-%s.%s"
           (ren--slugify (file-name-base file))
           (ren--short-hash file)
           ext)
   dir))

(defvar ren/pdf-viewer-processes (make-hash-table :test #'equal))

(defcustom ren/zathura-config-dir
  (expand-file-name "~/.config/zathura/latex")
  "Path to the Zathura config directory used when opening PDFs on non-Windows systems."
  :type 'directory
  :group 'ren)

(defun ren--open-pdf (pdf-file)
  (if (eq system-type 'windows-nt)
      (w32-shell-execute "open" (convert-standard-filename pdf-file))
    (let* ((zath-proc  (gethash pdf-file ren/pdf-viewer-processes))
           (zath-alive (and zath-proc (process-live-p zath-proc))))
      (if zath-alive
          (message "ren: Recompiled successfully: %s." pdf-file)
        (puthash pdf-file
                 (start-process "zathura" nil "zathura"
                                "-c" ren/zathura-config-dir
                                pdf-file)
                 ren/pdf-viewer-processes)))))

(defun ren/latex-compile-and-open ()
  (interactive)
  (unless (buffer-file-name)
    (user-error "ren: Buffer is not visiting a file."))
  (when (buffer-modified-p)
    (save-buffer))
  (let* ((tex-file  (buffer-file-name))
         (tex-dir   (file-name-directory tex-file))
         (jobname   (format "%s-%s"
                            (ren--slugify (file-name-base tex-file))
                            (ren--short-hash tex-file)))
         (pdf-file  (expand-file-name (concat jobname ".pdf") ren/latex-dir))
         (engine    (cond ((executable-find "lualatex") "lualatex")
                          ((executable-find "pdflatex") "pdflatex")
                          (t (user-error "ren: Neither lualatex nor pdflatex found on PATH."))))
         (default-directory tex-dir)
         (proc (make-process
                :name "ren-tex-compile"
                :buffer "*ren-tex-compile*"
                :command (list engine
                               "-interaction=nonstopmode"
                               "-output-directory" ren/latex-dir
                               "-jobname" jobname
                               tex-file)
                :noquery t)))
    (ren--ensure-output-dirs)
    (message "ren: Compiling with %s: %s." engine tex-file)
    (process-put proc 'pdf-file pdf-file)
    (set-process-sentinel
     proc
     (lambda (p _event)
       (let* ((pdf-file   (process-get p 'pdf-file))
              (pdf-exists (file-exists-p pdf-file)))
         (if pdf-exists
             (ren--open-pdf pdf-file)
           (message "ren: Compilation failed. See *ren-tex-compile* for details.")))))))

(defcustom ren/markdown-css
  (lwc/config-path "local" "tools" "render" "github-markdown.css")
  "Path to the Markdown CSS file."
  :type 'file
  :group 'ren)

(defcustom ren/markdown-template
  (lwc/config-path "local" "tools" "render" "github-markdown-template.html")
  "Path to the pandoc HTML template for Markdown rendering."
  :type 'file
  :group 'ren)

(defcustom ren/markdown-highlight-theme
  (lwc/config-path "local" "tools" "render" "github-dark.theme")
  "Path to a pandoc Skylighting JSON theme file for syntax highlighting."
  :type 'file
  :group 'ren)

(defun ren/markdown-compile-and-open ()
  (interactive)
  (unless (buffer-file-name)
    (user-error "ren: Buffer is not visiting a file."))
  (unless (executable-find "pandoc")
    (user-error "ren: pandoc not found on PATH."))
  (unless (file-readable-p ren/markdown-css)
    (user-error "ren: Markdown CSS not found at '%s'. Place the file there or set `ren/markdown-css'."
                ren/markdown-css))
  (unless (file-readable-p ren/markdown-template)
    (user-error "ren: Markdown template not found at '%s'. Place the file there or set `ren/markdown-template'."
                ren/markdown-template))
  (unless (file-readable-p ren/markdown-highlight-theme)
    (user-error "ren: Highlight theme not found at '%s'. Place the file there or set `ren/markdown-highlight-theme'."
                ren/markdown-highlight-theme))
  (when (buffer-modified-p)
    (save-buffer))
  (let* ((md-file   (buffer-file-name))
         (md-dir    (file-name-directory md-file))
         (html-file (ren--output-file ren/markdown-dir md-file "html"))
         (default-directory md-dir))
    (ren--ensure-output-dirs)
    (let ((proc (make-process
                 :name "ren-md-compile"
                 :buffer "*ren-md-compile*"
                 :command (list "pandoc"
                                "--standalone"
                                "--embed-resources"
                                "-f" "gfm"
                                "-t" "html"
                                "--highlight-style" ren/markdown-highlight-theme
                                "--css" ren/markdown-css
                                "--template" ren/markdown-template
                                md-file
                                "-o" html-file)
                 :noquery t)))
      (message "ren: Rendering %s to HTML." md-file)
      (process-put proc 'ren-html-file html-file)
      (set-process-sentinel
       proc
       (lambda (p _event)
         (let ((html-file (process-get p 'ren-html-file)))
           (cond
            ((not (= 0 (process-exit-status p)))
             (message "ren: Pandoc failed (exit %d). See *ren-md-compile* for details."
                      (process-exit-status p)))
            ((not (file-exists-p html-file))
             (message "ren: Pandoc produced no output. See *ren-md-compile* for details."))
            (t
             (browse-url-of-file html-file)
             (message "ren: Opened: %s." html-file)))))))))

(defun ren/compile-and-open ()
  (interactive)
  (cond
   ((derived-mode-p 'latex-mode)
    (cond
     ((eq system-type 'windows-nt) (message "ren: latex rendering is not available for Windows."))
     (t (ren/latex-compile-and-open))))
   ((derived-mode-p 'markdown-mode) (ren/markdown-compile-and-open))
   (t (user-error "ren: %s is unsupported." major-mode))))

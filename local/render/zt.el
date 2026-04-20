(defgroup zt nil
  "Utilities for compiling and opening LaTeX and Markdown buffers."
  :group 'tools)

(defconst zt/root-dir (expand-file-name "zt" (temporary-file-directory)))
(defconst zt/latex-dir (expand-file-name "LaTeX" zt/root-dir))
(defconst zt/markdown-dir (expand-file-name "Markdown" zt/root-dir))

(defun zt--ensure-output-dirs ()
  (dolist (dir (list zt/root-dir zt/latex-dir zt/markdown-dir))
    (unless (file-directory-p dir)
      (make-directory dir t))))

(defun zt--slugify (s)
  (replace-regexp-in-string "[^[:alnum:]._ -]+" "_" s))

(defun zt--short-hash (file)
  (substring (secure-hash 'sha1 (expand-file-name file)) 0 10))

(defun zt--output-file (dir file ext)
  (zt--ensure-output-dirs)
  (expand-file-name
   (format "%s-%s.%s"
           (zt--slugify (file-name-base file))
           (zt--short-hash file)
           ext)
   dir))

(defvar zt/pdf-viewer-processes (make-hash-table :test #'equal))

(defcustom zt/zathura-config-dir
  (expand-file-name "~/.config/zathura/latex")
  "Path to the Zathura config directory used when opening PDFs on non-Windows systems."
  :type 'directory
  :group 'zt)

(defun zt--open-pdf (pdf-file)
  (if (eq system-type 'windows-nt)
      (w32-shell-execute "open" (convert-standard-filename pdf-file))
    (let* ((zath-proc  (gethash pdf-file zt/pdf-viewer-processes))
           (zath-alive (and zath-proc (process-live-p zath-proc))))
      (if zath-alive
          (message "Recompiled successfully: %s." pdf-file)
        (puthash pdf-file
                 (start-process "zathura" nil "zathura"
                                "-c" zt/zathura-config-dir
                                pdf-file)
                 zt/pdf-viewer-processes)))))

(defun zt/latex-compile-and-open ()
  (interactive)
  (unless (buffer-file-name)
    (user-error "Buffer is not visiting a file."))
  (when (buffer-modified-p)
    (save-buffer))
  (let* ((tex-file  (buffer-file-name))
         (tex-dir   (file-name-directory tex-file))
         (jobname   (format "%s-%s"
                            (zt--slugify (file-name-base tex-file))
                            (zt--short-hash tex-file)))
         (pdf-file  (expand-file-name (concat jobname ".pdf") zt/latex-dir))
         (engine    (cond ((executable-find "lualatex") "lualatex")
                          ((executable-find "pdflatex") "pdflatex")
                          (t (user-error "Neither lualatex nor pdflatex found on PATH."))))
         (default-directory tex-dir)
         (proc (make-process
                :name "zt-tex-compile"
                :buffer "*zt-tex-compile*"
                :command (list engine
                               "-interaction=nonstopmode"
                               "-output-directory" zt/latex-dir
                               "-jobname" jobname
                               tex-file)
                :noquery t)))
    (zt--ensure-output-dirs)
    (message "Compiling with %s: %s." engine tex-file)
    (process-put proc 'pdf-file pdf-file)
    (set-process-sentinel
     proc
     (lambda (p _event)
       (let* ((pdf-file   (process-get p 'pdf-file))
              (pdf-exists (file-exists-p pdf-file)))
         (if pdf-exists
             (zt--open-pdf pdf-file)
           (message "Compilation failed. See *zt-tex-compile* for details.")))))))

(defcustom zt/markdown-css
  (expand-file-name "~/.config/emacs/local/render/github-markdown.css")
  "Path to the Markdown CSS file."
  :type 'file
  :group 'zt)

(defcustom zt/markdown-template
  (expand-file-name "~/.config/emacs/local/render/github-markdown-template.html")
  "Path to the pandoc HTML template for Markdown rendering."
  :type 'file
  :group 'zt)

(defcustom zt/markdown-highlight-theme
  (expand-file-name "~/.config/emacs/local/render/github-dark.theme")
  "Path to a pandoc Skylighting JSON theme file for syntax highlighting."
  :type 'file
  :group 'zt)

(defun zt/markdown-compile-and-open ()
  (interactive)
  (unless (buffer-file-name)
    (user-error "Buffer is not visiting a file."))
  (unless (executable-find "pandoc")
    (user-error "pandoc not found on PATH."))
  (unless (file-readable-p zt/markdown-css)
    (user-error "Markdown CSS not found at '%s'. Place the file there or set `zt/markdown-css'."
                zt/markdown-css))
  (unless (file-readable-p zt/markdown-template)
    (user-error "Markdown template not found at '%s'. Place the file there or set `zt/markdown-template'."
                zt/markdown-template))
  (unless (file-readable-p zt/markdown-highlight-theme)
    (user-error "Highlight theme not found at '%s'. Place the file there or set `zt/markdown-highlight-theme'."
                zt/markdown-highlight-theme))
  (when (buffer-modified-p)
    (save-buffer))
  (let* ((md-file   (buffer-file-name))
         (md-dir    (file-name-directory md-file))
         (html-file (zt--output-file zt/markdown-dir md-file "html"))
         (default-directory md-dir))
    (zt--ensure-output-dirs)
    (let ((proc (make-process
                 :name "zt-md-compile"
                 :buffer "*zt-md-compile*"
                 :command (list "pandoc"
                                "--standalone"
                                "--embed-resources"
                                "-f" "gfm"
                                "-t" "html"
                                "--highlight-style" zt/markdown-highlight-theme
                                "--css" zt/markdown-css
                                "--template" zt/markdown-template
                                md-file
                                "-o" html-file)
                 :noquery t)))
      (message "Rendering Markdown to HTML: %s." md-file)
      (process-put proc 'zt-html-file html-file)
      (set-process-sentinel
       proc
       (lambda (p _event)
         (let ((html-file (process-get p 'zt-html-file)))
           (cond
            ((not (= 0 (process-exit-status p)))
             (message "Pandoc failed (exit %d). See *zt-md-compile* for details."
                      (process-exit-status p)))
            ((not (file-exists-p html-file))
             (message "Pandoc produced no output. See *zt-md-compile* for details."))
            (t
             (browse-url-of-file html-file)
             (message "Opened: %s." html-file)))))))))

(defun zt/compile-and-open ()
  (interactive)
  (cond
   ((derived-mode-p 'latex-mode)    (zt/latex-compile-and-open))
   ((derived-mode-p 'markdown-mode) (zt/markdown-compile-and-open))
   (t (user-error "zt: unsupported mode: %s" major-mode))))

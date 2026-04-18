(defvar zt/pdf-viewer-processes (make-hash-table :test #'equal))

(defun zt/latex-compile-and-open ()
  (interactive)
  (unless (buffer-file-name)
    (user-error "Buffer is not visiting a file."))
  (when (buffer-modified-p)
    (save-buffer))
  (let* ((tex-file (buffer-file-name))
         (tex-dir  (file-name-directory tex-file))
         (base     (file-name-sans-extension tex-file))
         (pdf-file (concat base ".pdf"))
         (engine   (cond ((executable-find "lualatex") "lualatex")
                         ((executable-find "pdflatex") "pdflatex")
                         (t (user-error "Neither lualatex nor pdflatex found on PATH."))))
         (cmd      (format "%s -interaction=nonstopmode -output-directory=%s %s"
                           engine
                           (shell-quote-argument tex-dir)
                           (shell-quote-argument tex-file)))
         (proc     (start-process-shell-command
                    "zt-latex-compile" "*zt-latex-compile*" cmd)))
    (message "Compiling with %s: %s." engine tex-file)
    (process-put proc 'pdf-file pdf-file)
    (set-process-sentinel
     proc
     (lambda (p _event)
       (let* ((pdf-file   (process-get p 'pdf-file))
              (pdf-exists (file-exists-p pdf-file))
              (zath-proc  (gethash pdf-file zt/pdf-viewer-processes))
              (zath-alive (and zath-proc (process-live-p zath-proc))))
         (cond
          ((not pdf-exists)
           (message "Compilation failed. See *zt-latex-compile* for details."))
          (zath-alive
           (message "Recompiled successfully: %s." pdf-file))
          (t
           (let ((new-proc (start-process "zathura" nil "zathura" "-c"
                                          (expand-file-name "~/.config/zathura/latex")
                                          pdf-file)))
             (puthash pdf-file new-proc zt/pdf-viewer-processes)))))))))

(defun zt/markdown-compile-and-open ()
  (interactive)
  (unless (buffer-file-name)
    (user-error "Buffer is not visiting a file."))
  (unless (executable-find "pandoc")
    (user-error "pandoc not found on PATH."))
  (when (buffer-modified-p)
    (save-buffer))
  (let* ((md-file  (buffer-file-name))
         (base     (file-name-sans-extension md-file))
         (pdf-file (concat base ".pdf"))
         (cmd      (format "pandoc -f gfm --highlight-style=tango %s -o %s"
                           (shell-quote-argument md-file)
                           (shell-quote-argument pdf-file)))
         (proc     (start-process-shell-command
                    "zt-md-compile" "*zt-md-compile*" cmd)))
    (message "Rendering Markdown with pandoc: %s." md-file)
    (process-put proc 'pdf-file pdf-file)
    (set-process-sentinel
     proc
     (lambda (p _event)
       (let* ((pdf-file   (process-get p 'pdf-file))
              (pdf-exists (file-exists-p pdf-file))
              (zath-proc  (gethash pdf-file zt/pdf-viewer-processes))
              (zath-alive (and zath-proc (process-live-p zath-proc))))
         (cond
          ((not pdf-exists)
           (message "Pandoc failed. See *zt-md-compile* for details."))
          (zath-alive
           (message "Re-rendered successfully: %s." pdf-file))
          (t
           (let ((new-proc (start-process "zathura" nil "zathura" pdf-file)))
             (puthash pdf-file new-proc zt/pdf-viewer-processes)))))))))

(defun zt/compile-and-open ()
  (interactive)
  (cond
   ((derived-mode-p 'latex-mode)    (zt/latex-compile-and-open))
   ((derived-mode-p 'markdown-mode) (zt/markdown-compile-and-open))
   (t (user-error "zt: unsupported mode: %s" major-mode))))

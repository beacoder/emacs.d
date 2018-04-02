;;----------------------------------------------------------------------------
;; Colourise CSS colour literals
;;----------------------------------------------------------------------------
(when (maybe-require-package 'rainbow-mode)
  (dolist (hook '(css-mode-hook html-mode-hook sass-mode-hook))
    (add-hook hook 'rainbow-mode)))


;;; Embedding in html
(require-package 'mmm-mode)
(after-load 'mmm-vars
  (mmm-add-group
   'html-css
   '((css-cdata
      :submode css-mode
      :face mmm-code-submode-face
      :front "<style[^>]*>[ \t\n]*\\(//\\)?<!\\[CDATA\\[[ \t]*\n?"
      :back "[ \t]*\\(//\\)?]]>[ \t\n]*</style>"
      :insert ((?j js-tag nil @ "<style type=\"text/css\">"
                   @ "\n" _ "\n" @ "</style>" @)))
     (css
      :submode css-mode
      :face mmm-code-submode-face
      :front "<style[^>]*>[ \t]*\n?"
      :back "[ \t]*</style>"
      :insert ((?j js-tag nil @ "<style type=\"text/css\">"
                   @ "\n" _ "\n" @ "</style>" @)))
     (css-inline
      :submode css-mode
      :face mmm-code-submode-face
      :front "style=\""
      :back "\"")))
  (dolist (mode (list 'html-mode 'nxml-mode))
    (mmm-add-mode-ext-class mode "\\.r?html\\(\\.erb\\)?\\'" 'html-css)))


;;; SASS and SCSS
(require-package 'sass-mode)
(unless (fboundp 'scss-mode)
  ;; Prefer the scss-mode built into Emacs
  (require-package 'scss-mode))
(setq-default scss-compile-at-save nil)


;;; LESS
(unless (fboundp 'less-css-mode)
  ;; Prefer the scss-mode built into Emacs
  (require-package 'less-css-mode))
(when (maybe-require-package 'skewer-less)
  (add-hook 'less-css-mode-hook 'skewer-less-mode))


;;; Use eldoc for syntax hints
(require-package 'css-eldoc)
(autoload 'turn-on-css-eldoc "css-eldoc")
(add-hook 'css-mode-hook 'turn-on-css-eldoc)


;;; company-css
(after-load 'company
  (add-hook 'nxml-mode-hook (lambda () (sanityinc/local-push-company-backend 'company-css))))


(provide 'init-css)

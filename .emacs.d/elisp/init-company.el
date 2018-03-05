;;----------------------------------------------------------------------------
;; company-mode setting
;;----------------------------------------------------------------------------

(setq tab-always-indent 'complete)
(add-to-list 'completion-styles 'initials t)
(setq completion-cycle-threshold 5
      company-show-numbers t)


(when (maybe-require-package 'company)
  (add-hook 'after-init-hook 'global-company-mode)
  (after-load 'company
    (diminish 'company-mode "CMP")
    ;; (define-key company-mode-map (kbd "M-/") 'company-complete)
    ;; (define-key company-active-map (kbd "M-/") 'company-select-next)
    (setq-default company-backends
                 '((company-capf company-dabbrev-code company-dabbrev)
                   (company-gtags company-etags company-keywords)
                   company-files company-cmake)
                 company-dabbrev-other-buffers 'all
                 company-tooltip-align-annotations t))
  (global-set-key (kbd "\C-c TAB") 'company-complete)
  ;; (when (maybe-require-package 'company-quickhelp)
  ;;  (add-hook 'after-init-hook 'company-quickhelp-mode))

  (defun sanityinc/local-push-company-backend (backend)
    "Add BACKEND to a buffer-local version of `company-backends'."
    (make-local-variable 'company-backends)
    (push backend company-backends)))


;; Suspend page-break-lines-mode while company menu is active
;; (see https://github.com/company-mode/company-mode/issues/416)
(after-load 'company
  (after-load 'page-break-lines
    (defvar sanityinc/page-break-lines-on-p nil)
    (make-variable-buffer-local 'sanityinc/page-break-lines-on-p)

    (defun sanityinc/page-break-lines-disable (&rest ignore)
      (when (setq sanityinc/page-break-lines-on-p (bound-and-true-p page-break-lines-mode))
        (page-break-lines-mode -1)))

    (defun sanityinc/page-break-lines-maybe-reenable (&rest ignore)
      (when sanityinc/page-break-lines-on-p
        (page-break-lines-mode 1)))

    (add-hook 'company-completion-started-hook 'sanityinc/page-break-lines-disable)
    (add-hook 'company-completion-finished-hook 'sanityinc/page-break-lines-maybe-reenable)
    (add-hook 'company-completion-cancelled-hook 'sanityinc/page-break-lines-maybe-reenable)))

(provide 'init-company)

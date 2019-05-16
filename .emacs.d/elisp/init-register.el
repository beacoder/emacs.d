;;; init-register.el --- Register settings -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; <C-x r j b> => open directory "~/backup"
(set-register ?b '(file . "~/backup"))

(set-register ?c '(file . "~/.bashrc"))

(set-register ?e '(file . "~/.emacs.d/elisp"))

(set-register ?h '(file . "~/.bash_history"))

(set-register ?i '(file . "~/.emacs.d/init.el"))

(set-register ?o '(file . "~/.emacs.d/tutorials/org-tutorial.org"))

(set-register ?t '(file . "~/workspace/org/todo.org"))

(set-register ?w '(file . "~/workspace"))


(provide 'init-register)
;;; init-register.el ends here

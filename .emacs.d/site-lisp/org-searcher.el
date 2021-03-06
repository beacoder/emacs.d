;;; org-searcher.el --- Incremental org-search-view -*- lexical-binding: t; -*-

;; Copyright (C) 2021 Huming Chen

;; Author: Huming Chen <chenhuming@gmail.com>
;; URL: https://github.com/beacoder/org-searcher
;; Version: 0.1
;; Created: 2021-03-12
;; Keywords: convenience, tool, org
;; Package-Requires: ((emacs "25.1") (ivy "0.10.0") (org "0.10.0"))

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; Incremental org-search-view
;;
;; Below are commands you can use:
;; `org-searcher-search-view'

;;; Code:

(require 'ivy)
(require 'org-agenda)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Definition
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar org-searcher-index-to-item-alist nil
  "The alist to store mapping from ivy-index to agenda-item.")

(defvar org-searcher-window-configuration nil
  "The window configuration to be restored upon closing the buffer.")

(defvar org-searcher-selected-window nil
  "The currently selected window.")

(defvar org-searcher-created-buffers ()
  "List of newly created buffers.")

(defvar org-searcher-previous-buffers ()
  "List of buffers created before opening org-searcher.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Core Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;###autoload
(defun org-searcher-search-view ()
  "Incremental `org-search-view'."
  (interactive)
  (let ((org-searcher-window-configuration (current-window-configuration))
        (org-searcher-selected-window (frame-selected-window))
        (org-searcher-created-buffers ())
        (org-searcher-previous-buffers (buffer-list)))
    (advice-add 'ivy-previous-line :after #'org-searcher-iterate-action)
    (advice-add 'ivy-next-line :after #'org-searcher-iterate-action)
    (add-hook 'minibuffer-exit-hook #'org-searcher-quit)
    (ivy-read "Org agenda search: " #'org-searcher-agenda-search-function
              :dynamic-collection t
              :caller #'org-searcher-search-view
              :action #'org-searcher-search-action)))

(defun org-searcher-visit-agenda-location (agenda-location)
  "Visit agenda location AGENDA-LOCATION."
  (when-let ((temp-split (split-string agenda-location ":"))
             (file-name (car temp-split))
             (line-nb-str (cadr temp-split))
             (line-nb (string-to-number line-nb-str))
             (is-valid-file (file-exists-p file-name))
             (is-valid-nb (integerp line-nb)))
    (find-file-read-only-other-window file-name)
    (with-no-warnings (goto-line line-nb))
    (unless (member
             (buffer-name (window-buffer))
             (mapcar (function buffer-name) org-searcher-previous-buffers))
      (add-to-list 'org-searcher-created-buffers (window-buffer)))))

(defun org-searcher-search-action (agenda-location)
  "Go to AGENDA-LOCATION."
  (when-let ((location (get-text-property 0 'location agenda-location)))
    (org-searcher-visit-agenda-location location)))

;; modified from org-search-view
(defun org-searcher-agenda-search-function (string)
  "Show all entries in agenda files that contain STRING."
  (or (ivy-more-chars)
      (progn
        ;; use fuzzy matching
        (setq string (replace-regexp-in-string " +" ".*" string))
        (catch 'exit
          (setq files (org-agenda-files))
          ;; Uniquify files.  However, let `org-check-agenda-file' handle non-existent ones.
          (setq files (cl-remove-duplicates
                       (append files org-agenda-text-search-extra-files)
                       :test (lambda (a b)
                               (and (file-exists-p a)
                                    (file-exists-p b)
                                    (file-equal-p a b))))
                rtnall nil
                index 0
                org-searcher-index-to-item-alist nil)
          ;; loop agenda files to find matched one
          (while (setq file (pop files))
            (setq ee nil)
            (catch 'nextfile
              (org-check-agenda-file file)
              ;; search matched text
              (with-temp-buffer
                (insert-file-contents-literally file)
                (org-mode)
                (with-syntax-table (org-search-syntax-table)
                  (let ((case-fold-search t))
                    (widen)
                    (goto-char (point-min))
                    (unless (or (org-at-heading-p)
                                (outline-next-heading))
                      (throw 'nextfile t))
                    (goto-char (max (point-min) (1- (point))))
                    ;; real match happens here
                    (while (re-search-forward string nil t)
                      (org-back-to-heading t)
                      (while (and (not (zerop org-agenda-search-view-max-outline-level))
                                  (> (org-reduced-level (org-outline-level))
                                     org-agenda-search-view-max-outline-level)
                                  (forward-line -1)
                                  (org-back-to-heading t)))
                      (skip-chars-forward "* ")
                      (setq beg (point-at-bol)
                            beg1 (point)
                            end (progn
                                  (outline-next-heading)
                                  (while (and (not (zerop org-agenda-search-view-max-outline-level))
                                              (> (org-reduced-level (org-outline-level))
                                                 org-agenda-search-view-max-outline-level)
                                              (forward-line 1)
                                              (outline-next-heading)))
                                  (point)))
                      (goto-char beg)
                      ;; save found text and its location
                      (setq txt
                            (propertize (buffer-substring-no-properties beg1 (point-at-eol))
                                        'location (format "%s:%d" file (line-number-at-pos beg))))
                      ;; save in map
                      (push (cons index txt) org-searcher-index-to-item-alist)
                      ;; save as return value
                      (push txt ee)
                      (goto-char (1- end))
                      (setq index (1+ index)))))))
            (setq rtn (nreverse ee))
            (setq rtnall (append rtnall rtn)))
          rtnall))))

(defun org-searcher-iterate-action (&optional arg)
  "Preview agenda content while looping agenda, ignore ARG."
  (when-let ((ignore arg)
             (is-map-valid org-searcher-index-to-item-alist)
             (item-found (assoc ivy--index org-searcher-index-to-item-alist))
             (item-content (cdr item-found))
             (location (get-text-property 0 'location item-content)))
    (org-searcher-visit-agenda-location location)
    (when (active-minibuffer-window)
      (select-window (active-minibuffer-window)))))

(defun org-searcher-quit ()
  "Quit `org-searcher'."
  (let ((configuration org-searcher-window-configuration)
        (selected-window org-searcher-selected-window))
    (advice-remove 'ivy-previous-line #'org-searcher-iterate-action)
    (advice-remove 'ivy-next-line #'org-searcher-iterate-action)
    (remove-hook 'minibuffer-exit-hook #'org-searcher-quit)
    (set-window-configuration configuration)
    (select-window selected-window)
    (mapc 'kill-buffer-if-not-modified org-searcher-created-buffers)
    (setq org-searcher-created-buffers ())))


(provide 'org-searcher)

;; Local Variables:
;; coding: utf-8
;; indent-tabs-mode: nil
;; End:

;;; org-searcher.el ends here

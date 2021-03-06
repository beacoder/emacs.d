;;----------------------------------------------------------------------------
;; hydra setting
;;----------------------------------------------------------------------------

;; Major-mode binds to one specific file type
;; Minor-mode shared among all file types
;; Hydra groups related commands together to act like a temporary minor mode
(require-package 'hydra)


;; Don't treat 0-9 as digit-argument.
(with-eval-after-load 'hydra
  (setq hydra-base-map (make-sparse-keymap)))


(defhydra hydra-multiple-cursors (:hint nil)
  "
                 ^Commands^
--------------------------------------------
[_p_]   Previous      [_n_]   Next          [_a_] Match-All
[_P_]   Skip-Prev     [_N_]   Skip-Next     [_e_] Edit-All
[_M-p_] Unmark-Prev   [_M-n_] Unmark-Next   [_q_] Quit
^ ^                   ^ ^
  "
  ("n" mc/mark-next-like-this)
  ("N" mc/skip-to-next-like-this)
  ("M-n" mc/unmark-next-like-this)
  ("p" mc/mark-previous-like-this)
  ("P" mc/skip-to-previous-like-this)
  ("M-p" mc/unmark-previous-like-this)
  ("a" mc/mark-all-like-this)
  ("e" mc/edit-lines)
  ("q" nil))
(global-set-key (kbd "C-x m") #'hydra-multiple-cursors/body)


(defhydra hydra-window (:hint nil)
  "
                 ^Commands^
--------------------------------------------
[_s_] swap-window        [_o_] other-window       [_]_] enlarge-window-horizontally    [_)_] enlarge-window-vertically
[_p_] winner-undo        [_n_] winner-redo        [_[_] shrink-window-horizontally     [_(_] shrink-window-vertically
[_k_] delete-window      [_v_] preview-window     [_d_] dedicate-current-window        [_q_] quit
"
  ("s" transpose-windows)
  ("d" sanityinc/toggle-current-window-dedication)
  ("]" enlarge-window-horizontally)
  (")" enlarge-window-vertically)
  ("p" winner-undo)
  ("n" winner-redo)
  ("[" shrink-window-horizontally)
  ("(" shrink-window-vertically)
  ("v" sanityinc/split-window)
  ("o" other-window)
  ("k" delete-window)
  ("q" nil))
(global-set-key (kbd "C-x w") #'hydra-window/body)


(require 'org-searcher)
(defhydra hydra-quickness (:hint nil)
  "
                 ^Commands^
--------------------------------------------
[_a_] Counsel-Ag         [_g_] Counsel-Git-Grep [_f_] Counsel-Git      [_l_] Counsel-Locate     [_P_] Move-Text-Up
[_u_] Update-GTAGS       [_c_] Mode-Compile     [_C_] Compile          [_r_] Recompile          [_N_] Move-Text-Down
[_w_] Google-Search-Word [_k_] Google-Lucky     [_p_] Previous-Mark    [_n_] Next-Mark          [_j_] Dumb-Jump
[_i_] Pyim               [_s_] Sort-Lines       [_d_] Remove-Duplicate [_S_] Gist-Share-Code    [_L_] Gist-List
[_o_] Org-Search-View    [_t_] Hs-Toggle-Hiding [_q_] Quit
  "
  ("a" smart/counsel-ag :exit t)
  ("g" counsel-git-grep :exit t)
  ("f" counsel-git :exit t)
  ("l" counsel-locate :exit t)
  ("u" ggtags-update-tags :exit t)
  ("c" mode-compile :exit t)
  ("C" compile :exit t)
  ("w" modi/eww-search-words :exit t)
  ("k" eww-im-feeling-lucky :exit t)
  ("r" recompile :exit t)
  ("i" hydra-pyim-start :exit t)
  ("p" pop-to-mark-command)
  ("n" unpop-to-mark-command)
  ("s" sort-lines :exit t)
  ("d" delete-duplicate-lines :exit t)
  ("P" move-text-up)
  ("N" move-text-down)
  ("j" dumb-jump-go :exit t)
  ("S" gist-region-or-buffer-private :exit t)
  ("L" gist-list :exit t)
  ("t" hs-toggle-hiding)
  ("o" org-searcher-search-view :exit t)
  ("q" nil))
(global-set-key (kbd "C-x q") #'hydra-quickness/body)


(defhydra hydra-play (:hint nil)
  "
                 ^Commands^
--------------------------------------------
[_b_] Bongo    [_c_] Calendar    [_k_] Keyfreq
[_s_] Stock    [_w_] Wttrin      [_n_] Newsticker
[_q_] Quit
^ ^             ^ ^
"
  ("b" bongo :exit t)
  ("c" open-calendar :exit t)
  ("k" keyfreq-show :exit t)
  ("n" newsticker-show-news :exit t)
  ("s" stock-tracker-start :exit t)
  ("w" wttrin :exit t)
  ("q" nil))
(global-set-key (kbd "C-x p") #'hydra-play/body)


(provide 'init-hydra)
;;; init-hydra.el ends here

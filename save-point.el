;;  A simple setup for saving a stack of points and then moving back to them later.
;;
;;  Copyright 2011 Paul Rubel <paul at rubels dot net>
;; Permission to use, copy, modify, distribute, and sell this software and its
;; documentation for any purpose is hereby granted without fee, provided that
;; the above copyright notice appear in all copies and that both that
;; copyright notice and this permission notice appear in supporting
;; documentation.  No representations are made about the suitability of this
;; software for any purpose.  It is provided "as is" without express or 
;; implied warranty.

;;; save-point.el move between save points in buffers

;; Author: Paul Rubel (concat "paul" "@" "rubels"." "net")
;; Keywords: tools

;;; Commentary:

;; This will save the position that the cursor is currently at and let
;; you move back to that position. Multiple points are stored on a
;; stack so multiple points can be remembered. 
;;
;;

;;; Thoughts:
;;   Version 0.1 used to save different points for each buffer in buffer
;;  local variables. I took this out and put in a single list for all
;;  the buffers in the system. It seems like a good idea, thanks
;;  Graham. There doesn't seem to be a good way to make the buffer
;;  appear in the same window as before, I've just let emacs do what
;;  it will. 

;; There is a similar facility called bookmarks already in emacs
;; it saves named positions in files. If you want more than one in a 
;; file though you need to give it a name and type it in. This seems 
;; like something good if you need to go to places often but this code
;; is more for temporary distractions that don't get saved. 


;;;  Usage:

;;   Insert into your .emacs file the following line, and eval it for
;;  immediate usage:
;;
;;   (require 'save-point)
;;
;;   Optionally byte compile this file, and change the default
;;  keybinding.

;;   By default the main function, `save-point' is bound to C-v which
;;  kills scroll-up-command, I use page-up, and `pgr::restore-point' is
;;  bound to M-v which kills scroll-down-command, again, I use
;;  pagedown.
;;


;;; History:
;; 
;;  
;;   0.1 : Initial version.
;;   0.2 : One list of points for all buffers that moves from buffer
;;         to buffer instead of a list of points for each buffer.
;;         Checked for deleted buffers
;;   0.3 : Enables swapping of elements on top of the stack.

;;; Code:

(defvar save-point::version "0.3"
  "The version of `pgr::save-point'.")


(defvar save-point::pt nil
  "The points to come and go from")


(defun save-point ()
  "Save the current point so that later you can move right back to
where you were before with restore-point"
  (interactive)
  (progn
    (setq save-point::pt (cons (list (point-marker) 
                                     (current-buffer))
                               save-point::pt))
    (message "point saved")))
  


(defun restore-point ()
  "Take a saved point and move back to it"
  (interactive)
  ( if (not save-point::pt)
      (message "no point saved")
    (if (buffer-name (cadar save-point::pt)) ;; has the buffer been deleted
        (progn
          (set-window-buffer (selected-window) (cadar save-point::pt))
          (goto-char (caar save-point::pt))
          (setq save-point::pt (cdr save-point::pt))
          (message "restored point"))
      (setq save-point::pt (cdr save-point::pt))
      (message "buffer has been deleted"))))

(defun swap-point ()
  "Swap the points on the top of the point stack"
  (interactive)
  (if (< (length save-point::pt) 2 )
      (message "Not enough points to swap")
    (setq save-point::pt ( list (cadr save-point::pt) 
                                (car save-point::pt) 
                                (cddr save-point::pt)))
    (message "Swapped saved positions")))

(defun clear-points () 
  "Remove all points from the list, useful if you've stacked up a bunch and know you won't need them anymore"
  (interactive)
  (setq save-point::pt nil)
  (message "Cleared all saved points"))

(global-set-key "\M-v" 'restore-point)
(global-set-key "\M-V" 'swap-point)
;;why can't I bind to \C-V, it behaves like \C-v???
(global-set-key "\M-\C-v" 'clear-points)
(global-set-key "\C-v" 'save-point)

(provide 'save-point)
;;; save-point.el ends here

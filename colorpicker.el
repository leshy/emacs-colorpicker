;;; colorpicker.el --- ColorPicker

;; Copyright (C) 2015 by Syohei YOSHIDA

;; Author: Syohei YOSHIDA <syohex@gmail.com>
;; URL: https://github.com/syohex/emacs-colorpicker
;; Version: 0.01

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

;;; Code:

(defvar colorpicker--script
  (concat (if load-file-name
              (file-name-directory load-file-name)
            default-directory)
          "script/colorpicker.py"))

(defun colorpicker--pick-color (color)
  (with-temp-buffer
    (let ((ret (if color
                   (process-file colorpicker--script nil '(t nil) nil color)
                 (process-file colorpicker--script nil '(t nil) nil))))
      (unless (zerop ret)
        (error "Can't launch '%s'" colorpicker--script))
      (goto-char (point-min))
      (buffer-substring-no-properties (point) (line-end-position)))))

(defun colorpicker--bounds ()
  (let ((bounds (bounds-of-thing-at-point 'symbol)))
    (when bounds
      (save-excursion
        (goto-char (car bounds))
        (when (= (char-before) ?#)
          (cons (1- (car bounds)) (cdr bounds)))))))

;;;###autoload
(defun colorpicker ()
  (interactive)
  (let ((color (thing-at-point 'symbol))
        (bounds (colorpicker--bounds)))
    (let ((picked-color (colorpicker--pick-color (concat "#" color))))
      (unless (string= "" picked-color)
        (when bounds
          (goto-char (car bounds))
          (delete-region (point) (cdr bounds)))
        (insert picked-color)))))
(defun xah-syntax-color-hex ()
  "Syntax color hex color spec such as 「#ff1100」 in current buffer."
  (interactive)
  (font-lock-add-keywords
   nil
   '(("#[abcdef[:digit:]]\\{6\\}"
      (0 (put-text-property
          (+ (match-beginning 0) 1)
          (match-end 0)
          'face (list :background (match-string-no-properties 0)))))))
  (font-lock-fontify-buffer)
  )


(defun xah-syntax-color-hsl ()
  "Syntax color CSS's HSL color spec ➢ for example: 「hsl(0,90%,41%)」 in current buffer.
URL `http://ergoemacs.org/emacs/emacs_CSS_colors.html'
Version 2015-06-11"
  (interactive)
  (font-lock-add-keywords
   nil
   '(("hsl( *\\([0-9]\\{1,3\\}\\) *, *\\([0-9]\\{1,3\\}\\)% *, *\\([0-9]\\{1,3\\}\\)% *)"
      (0 (put-text-property
          (+ (match-beginning 0) 3)
          (match-end 0)
          'face
          (list
           :background
           (concat
            "#"
            (mapconcat
             'identity
             (mapcar
              (lambda (x) (format "%02x" (round (* x 255))))
              (color-hsl-to-rgb
               (/ (string-to-number (match-string-no-properties 1)) 360.0)
               (/ (string-to-number (match-string-no-properties 2)) 100.0)
               (/ (string-to-number (match-string-no-properties 3)) 100.0)))
             "" )) ;  "#00aa00"
           ))))))
  (font-lock-fontify-buffer))




(defun syntax-color-rgb ()
  "Syntax color CSS's RGB color spec ➢ for example: 「rgb(0,90,41)」 in current buffer."
  (interactive)
  (font-lock-add-keywords
   nil
   '(("rgb( *\\([0-9]\\{1,3\\}\\) *, *\\([0-9]\\{1,3\\}\\) *, *\\([0-9]\\{1,3\\}\\) *)"
      (0 (put-text-property
          (+ (match-beginning 0) 4)
          (match-end 3)
          'face
          (rgb-to-face
           (list
               (string-to-number (match-string-no-properties 1))
               (string-to-number (match-string-no-properties 2))
               (string-to-number (match-string-no-properties 3))
               ))            
          )))))
  (font-lock-fontify-buffer))


(defun xah-syntax-color-rgba ()
  "Syntax color CSS's RGBa color spec ➢ for example: 「rgba(0,90,41,0.2)」 in current buffer."
  (interactive)
  (font-lock-add-keywords
   nil
   '(("rgba( *\\([0-9]\\{1,3\\}\\) *, *\\([0-9]\\{1,3\\}\\) *, *\\([0-9]\\{1,3\\}\\),.*\)"
      (0 (put-text-property
          (+ (match-beginning 0) 5)
          (match-end 3)
          'face
          (rgb-to-face
           (list
               (string-to-number (match-string-no-properties 1))
               (string-to-number (match-string-no-properties 2))
               (string-to-number (match-string-no-properties 3))
               ))            
          )))))
  (font-lock-fontify-buffer))


(defun rgb-to-face (rgb)
    (interactive)
(list
 :background
 (concat "#" (mapconcat 'identity (mapcar (lambda (x) (format "%02x" x)) rgb) "" ))
 :box
 "#0076FC"
; :foreground
; (message (concat "#" (mapconcat 'identity (mapcar (lambda (x) (format "%02x" (- 255 x))) rgb) "" )))
 ))


(defun color-pick-replace (startpoint endpoint color)
  (let ((newcolor (color-pick color)))
    (if (> (length newcolor) 0)
        (progn 
          (delete-region startpoint endpoint)
          (goto-char startpoint)

          (insert newcolor))))
      )
  
(defun color-pick (color)
  (with-temp-buffer
    (progn
      (if (stringp color) (setq color (list color)))
      (apply `process-file colorpicker--script (append (list nil '(t nil) nil) color))
      (goto-char (point-min))
      (buffer-substring-no-properties (point) (line-end-position)))))

(defun picky ()
  (interactive)
  (let (startpoint)
    (save-excursion
    
    (skip-chars-backward "-a-z0-9,(#")
    (setq startpoint (point))
    
    (if
        (re-search-forward
         "rgb( *\\([0-9]\\{1,3\\}\\) *, *\\([0-9]\\{1,3\\}\\) *, *\\([0-9]\\{1,3\\}\\) *)"
         (+ (point) 20) t)

        (progn
         (color-pick-replace (+ startpoint 4) (- (point) 1) (list
                             (match-string-no-properties 1)
                             (match-string-no-properties 2)
                             (match-string-no-properties 3)))))
    
    (if
        (re-search-forward
         "rgba( *\\([0-9]\\{1,3\\}\\) *, *\\([0-9]\\{1,3\\}\\) *, *\\([0-9]\\{1,3\\}\\),.*\)"
         (+ (point) 20) t)

        (progn
         (color-pick-replace (+ startpoint 5) (match-end 3) (list
                             (match-string-no-properties 1)
                             (match-string-no-properties 2)
                             (match-string-no-properties 3)))))
    
    (if
        (re-search-forward
         "#[abcdef[:digit:]]\\{6\\}"
         (+ (point) 8) t)
        
        (progn
          (color-pick-replace startpoint (point) (match-string-no-properties 0))))
    
    )))

(defun pickerhook ()
  (interactive)
  (color-colors))



(define-minor-mode color-picker-mode
  "Syntax color css colors and provide a color picker."
  nil " colorPick" nil
  (xah-syntax-color-rgba)
  (xah-syntax-color-rgb)
  (xah-syntax-color-hex)
  (xah-syntax-color-hsl)
  (local-set-key (kbd "C-p") 'picky)
  )

(provide 'colorpicker)

;;; colorpicker.el ends here

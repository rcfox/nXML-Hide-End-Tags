(setq hidden-end-tags-overlays '())
(defun hide-all-end-tags ()
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "</" nil t)
      (let ((overlay-start (- (point) 2)))
        (re-search-forward ">" nil t)
        (hide-end-tag overlay-start (point))))))

(defun unhide-end-tags ()
  (interactive)
  (dolist (o hidden-end-tags-overlays)
    (delete-overlay o)))

(defun hidden-tag-modified (overlay after start end &optional len)
  (if (not (null after))
      (delete-overlay overlay)))

(defun hide-end-tag (start end)
  (let* ((hidden (mapcar (lambda (x)
                           (eq 'hidden-tag (overlay-get x 'category)))
                         (overlays-in start end)))
         (hidden (delq nil hidden)))
    (if (null hidden)
        (let ((overlay (make-overlay start end)))
          (overlay-put overlay 'category 'hidden-tag)
          (overlay-put overlay 'invisible t)
          (overlay-put overlay 'evaporate t)
          (overlay-put overlay 'isearch-open-invisible t)
          (overlay-put overlay 'after-string "_")
          (overlay-put overlay 'modification-hooks '(hidden-tag-modified))
          (push overlay hidden-end-tags-overlays)))))

(defun hide-end-tags-on-the-fly (start end len)
  (interactive)
  (if (char-equal (char-before) ?>)
      (let ((end-point (point)))
        (save-excursion
          (backward-sexp)
          (if (not (null (re-search-forward "</" end t)))
              (let ((start-point (- (point) 2)))
                (hide-end-tag start-point end-point)))))))

(add-hook 'nxml-mode-hook
          'hide-all-end-tags)
(add-hook 'nxml-mode-hook
          (lambda ()
            (add-hook 'after-change-functions 'hide-end-tags-on-the-fly t t)))

(provide 'nxml-hide-end-tags)

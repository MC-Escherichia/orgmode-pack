;;; orgmode-pack.el --- org-mode configuration

;;; Commentary:

;;; Code:

(install-packs '(org
                 ac-math))

(require 'org)

;; (require 'org-trello)
;; (add-hook 'org-mode-hook
;;           (lambda () (if org-trello-mode (auto-complete-mode 0))))

;; Some org-mode setup

;; org-mode for the .org file

(add-to-list 'auto-mode-alist '("\.org$"  . org-mode))
(add-to-list 'auto-mode-alist '("\.todo$" . org-mode))
(add-to-list 'auto-mode-alist '("\.note$" . org-mode))

(column-number-mode)

(setq org-directory "~/org")

(setq org-startup-indented t)

(setq org-log-done 'time)

(setq org-default-notes-file (concat org-directory "/notes.org"))

;; export options
(setq org-export-with-toc t)
(setq org-export-headline-levels 4)

;; metadata tags for the task at end
(setq org-tag-alist '(("howto"       . ?h)
                      ("tech"        . ?t)
                      ("emacs"       . ?e)
                      ("orgmode"     . ?o)
                      ("faq"         . ?F)
                      ("linux"       . ?l)
                      ("dev"         . ?d)
                      ("clojure"     . ?c)
                      ("elisp"       . ?E)
                      ("common-lisp" . ?C)
                      ("haskell"     . ?H)
                      ("scala"       . ?s)
                      ("devops"      . ?d)))

;; keywords sequence for org-mode
(setq org-todo-keywords
   '((sequence "TODO(t)" "IN-PROGRESS(i)" "PENDING(p)" "|"  "DONE(d)" "FAIL(f)" "DELEGATED(e)" "CANCELLED(c)")))

;; modifying the colonr for the different keywords
(setq org-todo-keyword-faces
      '(("TODO"        . (:foreground "firebrick2" :weight bold))
        ("IN-PROGRESS" . (:foreground "olivedrab" :weight bold))
        ("PENDING"     . (:foreground "sienna" :weight bold))
        ("DONE"        . (:foreground "forestgreen" :weight bold))
        ("DELEGATED"   . (:foreground "dimgrey" :weight bold))
        ("FAILED"      . (:foreground "steelblue" :weight bold))
        ("CANCELLED"   . shadow)))

;; babel

(org-babel-do-load-languages
 'org-babel-load-languages
 '((haskell    . t)
   (emacs-lisp . t)
   (sh         . t)
   (clojure    . t)
   (java       . t)
   (ruby       . t)
   (perl       . t)
   (python     . t)
   (R          . t)
   (ditaa      . t)
   (lilypond   . t)))

(setq org-fontify-done-headline t)
(custom-set-faces
 '(org-done ((t (:foreground "PaleGreen"
                 :weight normal
                 :strike-through t))))
 '(org-headline-done
            ((((class color) (min-colors 16) (background dark))
              (:foreground "LightSalmon" :strike-through t)))))

;; Be able to reactivate the touchpad for an export html (as my touchpad is deactivated when in emacs)

(defun run-shl (&rest cmd)
  "A simpler command to run-shell-command with multiple params"
  (shell-command-to-string (apply #'concatenate 'string cmd)))

(defun toggle-touchpad-manual (status)
  "Activate/Deactivate the touchpad depending on the status parameter (0/1)."
  (run-shl "toggle-touchpad-manual.sh " status))

(add-hook 'org-export-html-final-hook
          (lambda () (toggle-touchpad-manual "1")))

(defun myorg-update-parent-cookie ()
  (when (equal major-mode 'org-mode)
    (save-excursion
      (ignore-errors
        (org-back-to-heading)
        (org-update-parent-todo-statistics)))))

(defadvice org-kill-line (after fix-cookies activate)
  (myorg-update-parent-cookie))

(defadvice kill-whole-line (after fix-cookies activate)
  (myorg-update-parent-cookie))

;; deactivate git-gutter-mode if git-gutter activated in org-mode
(add-hook 'org-mode-hook (lambda () (and (fboundp 'git-gutter-mode)
                                         git-gutter-mode
                                         (git-gutter-mode 0))))

;;;;;;;;; Math setup

;; there is trouble with the standard install so I use directly emacs-live's native api
(require 'ac-math)

;; adding the auto-complete mode to org
(add-to-list 'ac-modes 'org-mode)

(defun ac-latex-mode-setup ()         ; add ac-sources to default ac-sources
  (setq ac-sources
        (append '(ac-source-math-unicode ac-source-math-latex ac-source-latex-commands)
                ac-sources)))

(add-hook 'org-mode-hook 'ac-latex-mode-setup)

(add-hook 'org-mode-hook
          (lambda ()
            (define-key org-mode-map (kbd "C-c c") 'org-capture)
            (define-key org-mode-map (kbd "C-c l") 'org-store-link)
            (define-key org-mode-map (kbd "C-c a") 'org-agenda)
            (org-defkey org-mode-map (kbd "C-c t") 'org-todo)
            ;;(define-key org-mode-map (kbd "C-c b") 'org-iswitchb)

            ;; org-mode
            (define-key org-mode-map (kbd "C-M-f") 'org-metadown)
            (define-key org-mode-map (kbd "C-M-b") 'org-metaup)
            (define-key org-mode-map (kbd "C-M-l") 'org-shiftright)
            (define-key org-mode-map (kbd "C-M-j") 'org-shiftleft)
            (define-key org-mode-map (kbd "C-M-i") 'org-shiftup)
            (define-key org-mode-map (kbd "C-M-k") 'org-shiftdown)))

;;; orgmode-pack ends here

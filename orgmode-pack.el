;;; orgmode-pack.el --- org-mode configuration (todo with org, slide presentation, etc...)

;;; Commentary:

;;; Code:

(require 'install-packages-pack)
(install-packages-pack/install-packs '(org
                                       ac-math
                                       smartscan
                                       toc-org))

(require 'ert)
(eval-after-load "toc-org-autoloads"
  '(progn
     (if (require 'toc-org nil t)
         (add-hook 'org-mode-hook 'toc-org-enable)
       (warn "toc-org not found"))))

(require 'smartscan)
(add-hook 'org-mode-hook (lambda () (smartscan-mode)))

(require 'org)

;; Some org-mode setup

;; org-mode for the .org file

(add-to-list 'auto-mode-alist '("\.org$"  . org-mode))
(add-to-list 'auto-mode-alist '("\.todo$" . org-mode))
(add-to-list 'auto-mode-alist '("\.note$" . org-mode))

(column-number-mode)

(setq org-directory "~/Dropbox/org")
(setq org-agenda-files (directory-files org-directory 'absolute-names ".org$" 'nosort))

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
                      ("devops"      . ?d)
                      ("TOC"         . ?T))) ;; for org-toc

;; keywords sequence for org-mode
(setq org-todo-keywords
      '((sequence "TODO(t)" "IN-PROGRESS(i)" "PENDING(p)" "|"  "DONE(d)" "FAILED(f)" "DELEGATED(e)" "CANCELLED(c)")))

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


;; (org-babel-do-load-languages
;;  'org-babel-load-languages
;;  '((haskell    . t)
;;    (emacs-lisp . t)
;;    (sh         . t)
;;    (clojure    . t)
;;    (java       . t)
;;    (ruby       . t)
;;    (perl       . t)
;;    (python     . t)
;;    (R          . t)
;;    (ditaa      . t)
;;    (lilypond   . t)))

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
  "A simpler command CMD to run-shell-command with multiple params."
  (shell-command-to-string (apply #'concatenate 'string cmd)))

(defun toggle-touchpad-manual (status)
  "Activate/Deactivate the touchpad depending on the STATUS parameter (0/1)."
  (run-shl "toggle-touchpad-manual.sh " status))

(add-hook 'org-export-html-final-hook
          (lambda () (toggle-touchpad-manual "1")))

(defun myorg-update-parent-cookie ()
  "Update Org-mode statistics."
  (when (equal major-mode 'org-mode)
    (save-excursion
      (ignore-errors
        (org-back-to-heading)
        (org-update-parent-todo-statistics)))))

(defadvice org-kill-line (after fix-cookies activate)
  "Add advice around the org-kill-line method."
  (myorg-update-parent-cookie))

(defadvice kill-whole-line (after fix-cookies activate)
  "Same for `kill-whole-line`.
AFTER killing whole line, update the org-mode's current statistics.
FIX-COOKIES.
ACTIVATE."
  (myorg-update-parent-cookie))

;;;;;;;;; Math setup

;; there is trouble with the standard install so I use directly emacs-live's native api
(require 'ac-math)

;; adding the auto-complete mode to org
(add-to-list 'ac-modes 'org-mode)

(defun ac-latex-mode-setup ()
  "Add ac-sources to default ac-sources."
  (setq ac-sources
        (append '(ac-source-math-unicode ac-source-math-latex ac-source-latex-commands)
                ac-sources)))

(add-hook 'org-mode-hook 'ac-latex-mode-setup)

(add-hook 'org-mode-hook
          (lambda ()
            (global-unset-key (kbd "C-c o"))
            (global-unset-key (kbd "C-c t"))
            (global-unset-key (kbd "C-c o c"))
            (global-unset-key (kbd "C-c o l"))
            (global-unset-key (kbd "C-c o a"))
            (global-unset-key (kbd "C-c o t"))

            (define-key org-mode-map (kbd "C-c o c") 'org-capture)
            (define-key org-mode-map (kbd "C-c o l") 'org-store-link)
            (define-key org-mode-map (kbd "C-c o a") 'org-agenda)
            (define-key org-mode-map (kbd "C-c o t") 'org-todo)
            (define-key org-mode-map (kbd "C-c o b") 'org-iswitchb)

            ;; org-mode
            (define-key org-mode-map (kbd "C-M-f") 'org-metadown)
            (define-key org-mode-map (kbd "C-M-b") 'org-metaup)
            (define-key org-mode-map (kbd "C-M-l") 'org-shiftright)
            (define-key org-mode-map (kbd "C-M-j") 'org-shiftleft)
            (define-key org-mode-map (kbd "C-M-i") 'org-shiftup)
            (define-key org-mode-map (kbd "C-M-k") 'org-shiftdown)))

(add-hook 'org-mode-hook
          (lambda ()
            ;; deactivate whitespace mode on org buffer
            (and (fboundp 'whitespace-mode) (whitespace-mode -1))))

(when (require 'org-trello nil t)
  (add-hook 'org-trello-mode-hook (lambda ()
                                    (let ((prefix-binding "C-c z"))
                                      (orgtrello-setup/install-local-prefix-mode-keybinding! prefix-binding)
                                      (define-key org-trello-mode-map (kbd (format "%s%s" prefix-binding " r")) 'org-trello/dev-load-namespaces))))
  (custom-set-variables '(org-trello-files
                          (directory-files (file-name-directory "/home/matt/Dropbox/org/gtd/") 't ".*\.org"))))




(provide 'orgmode-pack)
;;; orgmode-pack ends here

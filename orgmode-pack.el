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
(require 'seq)

(setq org-directory "~/Dropbox/org")
(setq org-agenda-files (seq-filter
                        (lambda (x) (string-match-p "gtd/[^\.\#]+\.org$"   x))
                        (directory-files (s-append "/gtd/" org-directory) 'absolute-names "" 'nosort)))



(setq org-startup-indented t)

(setq org-log-done 'time)

(setq org-default-notes-file (concat org-directory "/notes.org"))

(setq org-capture-templates
      '(("t" "Todo" entry (file (concat org-directory  "/gtd/gtd.org") )
         "* TODO %?\n  %i\n  %a" :prepend t)
        ("j" "Journal" entry (file+datetree (concat org-directory "/journal.org"))
         "* %?\nEntered on %U\n  %i\n  %a")))

(define-key global-map "\C-cc" 'org-capture)

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
(require 'ob)
(org-babel-do-load-languages
 'org-babel-load-languages
 '( ;; (haskell    . t)
   (emacs-lisp . t)
   (sh         . t)
   (clojure    . t)
   (org . t)
   (mongo . t)
   ;; (java       . t)
   ;; (ruby       . t)
   ;; (perl       . t)
   ;; (python     . t)
   ;; (R          . t)
   (ditaa      . t)
   (latex      . t)
   ;; (lilypond   . t)
   ))

(defun my-org-confirm-babel-evaluate (script-lang body)
  (let ((trusted-langs '("ditaa" "mongo" "latex")))
    (not (-some 'identity (mapc (lambda (lang) (string= script-lang lang))
                                trusted-langs))))) ; don't ask for ditaa
(setq org-confirm-babel-evaluate 'my-org-confirm-babel-evaluate)


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

;;; ox-latex
(defun org-export-latex-no-toc (depth)
  (when depth
    (format "%% Org-mode is exporting headings to %s levels.\n"
            depth)))
(setq org-export-latex-format-toc-function 'org-export-latex-no-toc)


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
  (custom-set-variables '(org-trello-files
                          (directory-files (file-name-directory "/home/matt/Dropbox/org/gtd/") 't ".*\.org"))))


(require 'hydra)
(defhydra hydra-org-template (:color blue :hint nil)
  "
_c_enter  _q_uote    _L_aTeX:
_l_atex   _e_xample  _i_ndex:
_a_scii   _v_erse    _I_NCLUDE:
_s_rc     ^ ^        _H_TML:
_h_tml    ^ ^        _A_SCII:
"
  ("s" (hot-expand "<s"))
  ("e" (hot-expand "<e"))
  ("q" (hot-expand "<q"))
  ("v" (hot-expand "<v"))
  ("c" (hot-expand "<c"))
  ("l" (hot-expand "<l"))
  ("h" (hot-expand "<h"))
  ("a" (hot-expand "<a"))
  ("L" (hot-expand "<L"))
  ("i" (hot-expand "<i"))
  ("I" (hot-expand "<I"))
  ("H" (hot-expand "<H"))
  ("A" (hot-expand "<A"))
  ("<" self-insert-command "ins")
  ("o" nil "quit"))

(defun hot-expand (str)
  "Expand org template."
  (insert str)
  (org-try-structure-completion))

(define-key org-mode-map "<"
  (lambda () (interactive)
    (if (looking-back "^")
        (hydra-org-template/body)
      (self-insert-command 1))))


(set 'org-src-fontify-natively t)

(add-hook 'org-capture-mode-hook
          (lambda ()
            (auto-fill-mode)
            (writeroom-mode 1)
            (visual-line-mode)
            (company-mode 0)))

;; ox-koma-letter
(require 'ox-koma-letter)
(add-to-list 'org-latex-classes
             '("my-letter"
               "\\documentclass\[DIV=15,fontsize=10pt,foldmarks=h,subject=untitled\]\{scrlttr2\}
     \\usepackage[english]{babel}
     \\setkomavar{frombank}{(1234)\\,567\\,890}
     \[DEFAULT-PACKAGES]
     \[PACKAGES]
     \[EXTRA]") nil (lambda (e1 e2) (string= (car e1)
                                        (car e2))))


(setq org-koma-letter-default-class "my-letter")


;; org latex
(require 'ox-latex)
(setq org-latex-listings t)
(mapc
 (lambda (e) (add-to-list 'org-latex-packages-alist e))
 '(("" "longtable" t)
   ("" "tabu" t)
					;("AUTO" "babel" t)
   ))



(add-to-list 'org-latex-classes
             '("koma-article"
               "\\documentclass\[%
               DIV=14
               fontsize=10pt
               subject=untitled\]{scrartcl}
               [NO-DEFAULT-PACKAGES]
               [EXTRA]"
               ("\\section{%s}" . "\\section*{%s}")
               ("\\subsection{%s}" . "\\subsection*{%s}")
               ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
               ("\\paragraph{%s}" . "\\paragraph*{%s}")
               ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))


(org-babel-lob-ingest "./mfc_lob.org")

(provide 'orgmode-pack)

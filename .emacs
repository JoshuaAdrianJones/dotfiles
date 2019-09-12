
;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes (quote (misterioso)))
 '(org-agenda-files
   (quote
    ("~/Notes/org-Notes/week37.org" "~/Notes/org-Notes/week36.org" "~/Notes/org-Notes/readinglist.org")))
 '(package-selected-packages (quote (org-pomodoro))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(add-to-list 'load-path "~/.emacs.d/lisp")
(require 'org-bullets)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

(when (version<= "26.0.50" emacs-version )
  (global-display-line-numbers-mode))


(add-to-list 'package-archives
               '("melpa" . "https://melpa.org/packages/") t)

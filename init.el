;;; init.el --- Personal Emacs Configuration
;;
;; Author: Joshua Jones
;; URL: https://github.com/JoshuaAdrianJones/dotfiles
;; Keywords: emacs, evil, org-mode, nord-theme
;;
;; This file is NOT part of GNU Emacs.
;;
;;; Commentary:
;;
;; Minimal Emacs configuration focused on:
;; - Evil mode (Vim keybindings) with leader key ","
;; - Org mode for notes and task management
;; - Nord theme for visual consistency
;; - Magit for Git integration
;; - Writeroom mode for distraction-free writing
;;
;; Primary use: Org mode and writing (VSCode for coding)
;;
;;; Code:

;;; BASIC SETTINGS

(setq visible-bell t)  ; Use visual bell instead of audible bell
(global-visual-line-mode t)
(setq-default global-visual-line-mode 1)
(global-display-line-numbers-mode)
(setq initial-major-mode 'org-mode)

;; F7: Quick access to init file for editing
(global-set-key [f7] (lambda () (interactive) (find-file user-init-file)))

;; F8: Toggle Treemacs file browser
(global-set-key [f8] 'treemacs)

;; Set user directory (macOS default)
(setq user-emacs-directory "~/.emacs.d/")

;;; PACKAGE MANAGEMENT

;; Initialize package management
(require 'package)

;; Add MELPA repository
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)

;; Initialize package.el
(package-initialize)

;; Make sure 'use-package' is installed
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; Load and configure the 'use-package' macro
(eval-when-compile
  (require 'use-package))
(setq use-package-always-ensure t)

;;; ORG MODE CONFIGURATION

;; Log timestamps when completing org-mode tasks
(setq org-log-done 'time)
(use-package org-superstar
  :ensure t
  :after org
  :hook (org-mode . org-superstar-mode)
  :config
  (setq org-superstar-special-todo-items t) ; Display special todo symbols
  )

;; Install and set up org-mode
(use-package org
  :ensure t
  :config
  ;; Your org-mode configuration goes here
  ;; For example, you can set keybindings, file paths, etc.
)

;;; GIT INTEGRATION (MAGIT)
(use-package magit
  :ensure t
  :config
  ;; Your magit configuration goes here
  ;; For example, you can set keybindings, display options, etc.
)

;;; DISTRACTION-FREE WRITING

;; Dependency for writeroom mode
(use-package visual-fill-column
  :ensure t
  :config

  )

;; Writeroom mode: Distraction-free writing environment
(use-package writeroom-mode
  :ensure t
  :config
  (setq writeroom-width 120)  ; 120 character width for comfortable reading
  )

;; When turning on writeroom-mode, also wrap lines
(add-hook 'writeroom-mode-hook 'visual-line-mode)

;;; THEME

;; Install and load the Nord theme
(use-package nord-theme
  :ensure t
  :config
  (load-theme 'nord t))

;;; EVIL MODE (VIM KEYBINDINGS)

;; Evil: Vim emulation layer with "," as leader key
(use-package evil
  :ensure t
  :init
  (setq evil-want-integration t
        evil-want-keybinding nil
        evil-leader/leader ",") ; Set the leader key to ,
  :config
  (evil-mode 1))

;; Evil leader: Leader key bindings with ","
;; All leader commands start with "," (comma)
(use-package evil-leader
  :ensure t
  :config
  (global-evil-leader-mode)
  ;; Leader key bindings (press "," followed by these keys)
  (evil-leader/set-key "ff" 'find-file
                        "bb" 'switch-to-buffer
                        "bd" 'kill-buffer
			"lf" 'load-file
			"ft" 'treemacs
			"t"  'treemacs-select-window  ; put focus on treemacs window
			"qf" 'kill-buffer-and-window  ; File close
			"bc" 'kill-this-buffer        ; Buffer close
			"wc" 'kill-this-buffer        ; Buffer close
			"ko" 'delete-other-windows    ; Close all other buffers kill-other
			"ww" 'widen                   ; Widen buffer
			"wb" 'balance-windows         ; Make buffers equal size
			"fs" 'save-buffer             ; Save buffer		
			"aa" 'org-agenda-file-to-front; Add file to org-agenda
			"oa" 'org-agenda              ; Show org-agenda view
			;; Add more bindings as needed
			"gs" 'magit-status            ; Open magit status
			"gc" 'magit-commit            ; Commit changes
			"gp" 'magit-push              ; Push changes
			"gP" 'magit-pull              ; Pull changes
			"gb" 'magit-branch            ; Manage branches
			"gr" 'magit-rebase            ; Rebase
			"wr" 'writeroom-mode          ; Writroom mode
			"rl" '(load-file user-init-file) ; Re-Load Config
                        ))
(use-package evil-collection
  :ensure t
)

;;; FILE NAVIGATION

(use-package treemacs
  :ensure t
  :config
  (setq treemacs-width 25) ; Set the width of the treemacs window
  (setq treemacs-follow-after-init t) ; Automatically show treemacs on startup
  (setq treemacs-is-never-other-window t) ; Prevent treemacs from taking up the whole frame
  )

(use-package treemacs-evil
  :ensure t
  :after (treemacs evil)
  )
;; Optional: Keybinding to toggle treemacs
(global-set-key (kbd "C-x t") 'treemacs)


;; add consult package
(use-package consult
  :ensure t)

;; Keybinding for 'consult-buffer'
(global-set-key (kbd "C-x b") 'consult-buffer)

;; Enable rich annotations using the Marginalia package
(use-package marginalia
  ;; Bind `marginalia-cycle' locally in the minibuffer.  To make the binding
  ;; available in the *Completions* buffer, add it to the
  ;; `completion-list-mode-map'.
  :bind (:map minibuffer-local-map
         ("M-A" . marginalia-cycle))
  ;; The :init section is always executed.
  :init
  ;; Marginalia must be activated in the :init section of use-package such that
  ;; the mode gets enabled right away. Note that this forces loading the
  ;; package.
  (marginalia-mode))

(use-package evil-org
  :ensure t
  :after org
  :hook (org-mode . (lambda () evil-org-mode))
  :config
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))
(evil-collection-init 'magit)

;;; CUSTOM SETTINGS

;; Org todo keyword configuration
(setq org-todo-keywords
      '((sequence "MAYBE" "TODO" "DOING" "WAITING" "DONE")))

(setq org-todo-keyword-faces
'(
("MAYBE" . "#dc752f")
("TODO" . "#dc752f")
("DOING" . "#4f97d7")
("WAITING" . "#f2241f")
("DONE" . "#86dc2f")
)
)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-agenda-files '("~/notes/logs-and-notes/log.org"))
 '(package-selected-packages
   '(writeroom-mode visual-fill-column evil-collection magit org-superstar popup marginalia consult neotree use-package nord-theme evil-leader))
 '(writeroom-width 120))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

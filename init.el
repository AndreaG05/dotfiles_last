;;; init.el --- Emacs Configuration
;;; Code:

;; ============================================================
;; Init
;; ============================================================

(setq vterm-shell "/bin/bash --login")

(setq env/terminal-path (replace-regexp-in-string "\n$" "" (shell-command-to-string "which bash")))
(setq env/dotemacs-path "~/dotfile/emacs/device/framework.org")
(setq env/tool-path "~/dotfile/emacs/custom/tool.org")

;; do not ask to follow symlinks
(setq vc-follow-symlinks t)

;; Hide these buffers
(setq display-buffer-alist
      '(;; no window
	("*Shell Command Output*"
	 (display-buffer-no-window)
	 (allow-no-window . t)
	 )
	("*Async Shell Command*"
	 (display-buffer-no-window)
	 (allow-no-window . t)
	 )
	("*commands-history*"
	 (display-buffer-no-window)
	 (allow-no-window . t)
	 )
	))

;; ============================================================
;; Package Management
;; ============================================================

;; Initialize package.el
(require 'package)

(add-hook 'vterm-mode-hook
          (lambda ()
            (display-line-numbers-mode -1)))
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'org-mode-hook (lambda () (display-line-numbers-mode -1)))

;; Set priorities of using melpa-stable.
;; The higher the number, the higher the priority.
(setq package-archive-priorities
      '(("melpa-stable" . 2)
        ("melpa" . 1)
        ("gnu" . 0)))

;; Add package archives
(setq package-archives
      '(("melpa-stable" . "https://stable.melpa.org/packages/")
        ("melpa" . "https://melpa.org/packages/")
        ("gnu" . "https://elpa.gnu.org/packages/")))

;; ze package system
(package-initialize)

;; Refresh package contents if needed
(unless package-archive-contents
  (package-refresh-contents))

;; Install use-package if not already installed
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; ============================================================
;; Org
;; ============================================================

(use-package org
  :config
  (require 'org-tempo)
  (setq org-adapt-indentation t)

  (setq org-todo-keyword-faces
	'(("TODO" . "BlueViolet")
          ("DONE" . "LawnGreen")
          ("PREPARE" . "DarkOrange")
          ("RECORD" . "red")
          ("UPLOAD" . "LawnGreen")
          ))

  ;; do not show things such as #+TITLE, as that is distracting.
  (setq org-hidden-keywords '())
  (setq org-hide-leading-stars t)
  (setq org-hide-emphasis-markers t)

  ;; do not a for confirmation when evaulating org-babel block.
  (setq org-confirm-babel-evaluate nil)

  ;; hide all blocks when opening a new org-mode buffer.
  (setq org-startup-folded 'showall)
  (add-hook 'org-mode-hook
            (lambda ()
              ;; Hide blocks by default, except for specific files
              ;; Uncomment and add your specific files here:
              ;; (unless (and buffer-file-name
              ;;              (member buffer-file-name
              ;;                      '("~/work/project1/meta.org"
              ;;                        "~/work/project2/meta.org")))
              ;;   (org-hide-block-all))
              (org-hide-block-all)))
  )

;; LaTeX previewing
(setq org-preview-latex-default-process 'dvipng) ;; dvisvgm
(setq org-format-latex-options
      (plist-put org-format-latex-options :scale 4.0))

(use-package denote
  :ensure t
  :config
  (setq denote-directory (expand-file-name "~/notes/denote"))

  (setq denote-save-buffers nil)
  (setq denote-known-keywords
	'("emacs" "projects" "programming"
	  "books" "math" "activities" "life" "activities"
	  "writing" "network" "movie" "tv"
	  "security" "system" "tool"
	  )
	)

  (setq denote-infer-keywords t)
  (setq denote-sort-keywords t)
  (setq denote-file-type nil) ; Org is the default, set others here
  (setq denote-prompts '(title keywords))
  (setq denote-excluded-directories-regexp nil)
  (setq denote-excluded-keywords-regexp nil)
  (setq denote-rename-confirmations '(rewrite-front-matter modify-file-name))

  (denote-rename-buffer-mode 1)
  (add-hook 'dired-mode-hook #'denote-dired-mode-in-directories)
  )

;; Used for blogging
(use-package ox-hugo
  :ensure t
  :after ox
  )

;; ox-zola needs to be installed manually or via straight.el
;; Commenting out for now
;; (use-package ox-zola
;;   :ensure t)

;; Prettify symbols in org-mode
;; (defun my/org-prettify-symbols ()
;;   (mapc (apply-partially 'add-to-list 'prettify-symbols-alist)
;;         (cl-reduce 'append
;;                    (mapcar (lambda (x) (list x (cons (upcase (car x)) (cdr x))))
;;                            `(("#+begin_src" . ?λ) ;; ➤ 🖝 ➟ ➤ ✎ ⏹
;;                              ("#+end_src"   . "")
;;                              ("#+begin_example" . ?∷)
;;                              ("#+end_example"   . "")
;;                              ("#+begin_quote" . ?»)
;;                              ("#+end_quote" . ?«)
;;                              ;; ("#+header:" . ?☰)
;;                              )
;;                            )))
;;   (turn-on-prettify-symbols-mode)
;;   )

;; (setq org-ellipsis " ▼")
;; (add-hook 'org-mode-hook #'my/org-prettify-symbols)

;; ============================================================
;; Style
;; ============================================================

(use-package standard-themes
  :ensure t
  :config
  ;; purple style modeline
  (setq modus-themes-common-palette-overrides
        '((bg-mode-line-active bg-lavender)
          (fg-mode-line-active fg-main)
          (border-mode-line-active bg-magenta-intense)))
  )

;; (use-package spacemacs-theme
;;   :ensure t
;;   :init
;;   (setq spacemacs-theme-comment-bg nil)
;;   )

(use-package ef-themes
  :ensure t
  )

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :config

  ;; At some point it kept giving me the following error
  ;;
  ;; Error during redisplay: (eval (doom-modeline-segment--time)) signaled (error "Invalid image type 'svg'") [7 times]
  ;;
  ;; I fixed it by following the tip from
  ;; https://emacs.stackexchange.com/questions/74289/emacs-28-2-error-in-macos-ventura-image-type-invalid-image-type-svg
  (add-to-list 'image-types 'svg)
  )

;; ============================================================
;; Buffers
;; ============================================================

(use-package ibuffer
  :config
  ;; don't ask for confirmation of "dangerous" operations such as
  ;; deleting buffers
  (setq ibuffer-expert t)

  ;; define a group-organized view where buffers are organized into
  ;; groups depending on whether they match a given regex pattern or
  ;; not. This structure is dynamically modified by the function
  ;; 'work/compute-ibuffer-group' using information taken from the
  ;; list of currently active buffers.
  (setq default-ibuffer-saved-filter-groups
  	(quote (("default"
  		 ("org" (mode . org-mode))
  		 ("vterminal" (name . "^\\*vterminal"))
  		 ("emacs" (or
  			   (name . "^\\*scratch\\*$")
  			   (name . "^\\*Messages\\*$")))
  		 ("dired" (mode . dired-mode))
  		 ))))

  ;; items for each group are sorted alphabetically using the buffer name
  (setq ibuffer-default-sorting-mode 'alphabetic)

  (setq ibuffer-saved-filter-groups default-ibuffer-saved-filter-groups)

  ;; as soon as you enter or refresh ibuffer, switch to a
  ;; group-organized view using a group configuration computed on the
  ;; fly depending on currently open buffers.
  (add-hook 'ibuffer-hook (lambda () (ibuffer-switch-to-saved-filter-groups "default")))
  )

;; ============================================================
;; Windows
;; ============================================================

(use-package beacon
  :ensure t
  :config
  (setq beacon-size 10)
  (beacon-mode 1))

(use-package popwin
  :ensure t
  :config
  (popwin-mode 1)
  )

;; ============================================================
;; Terminal
;; ============================================================

(use-package better-shell
  :ensure t)

(use-package eterm-256color
  :ensure t
  :hook (term-mode . eterm-256color-mode))

(use-package vterm
  :ensure t
  :bind* (:map vterm-mode-map
               ("C-x C-k" . vterm-copy-mode)
               ("C-q" . my/tool)
               :map vterm-copy-mode-map
               ("C-x C-k" . vterm-copy-mode)
               ("C-q" . my/tool))
  :config
  (setq vterm-clear-scrollback t)
  (setq vterm-max-scrollback 100000)
  (setq vterm-directory-tracking-mode t))

(use-package multi-vterm
  :ensure t
  :after vterm
  :bind (("C-c l" . multi-vterm)))


(use-package ivy
  :ensure t
  :config
  (ivy-mode 1)

  (setq ivy-re-builders-alist
        '((swiper . ivy--regex-plus)
          (t      . ivy--regex-fuzzy)))

  ;; useful when using ivy-posframe to make sure that long lines are
  ;; still visible.
  (setq ivy-truncate-lines nil)
  )


(use-package ivy-posframe
  :ensure t
  :config
  (setq ivy-posframe-display-functions-alist '((t . ivy-posframe-display)))
  (setq ivy-posframe-border-width 2)
  ;;
  ;; (setq ivy-posframe-parameters
  ;; 	'((left-fringe . 5)
  ;;         (right-fringe . 5)))
  ;;
  ;; inherit stile from default one, this is useful so that later when
  ;; we apply the spacemacs theme it also gets applied to ivy-posframe
  ;; buffer
  (put 'ivy-posframe 'face-alias 'default)
  (ivy-posframe-mode 1)
  )

(use-package expand-region
  :ensure t
  )
(require 'expand-region)

;; Company (commented out)
;; (use-package company
;;   :ensure t
;;   :config
;;   ;; Now delay in showing suggestions
;;   (setq company-idle-delay 0)
;;   ;; Show suggestions after entering one character
;;   (setq company-minimum-prefix-length 3)
;;   ;; Wrap around after finishing suggestions
;;   (setq company-selection-wrap-around t)
;;   (setq company-quickhelp-color-background "#4F4F4F")
;;   (setq company-quickhelp-color-foreground "#DCDCCC")
;;   )

;; Corfu
(use-package corfu
  :ensure t
  :config
  (setq corfu-auto t
        corfu-quit-no-match 'separator)
  ;; (add-hook 'mu4e-compose-mode-hook 'corfu-mode)
  )

;; Snippets
(use-package yasnippet
  :ensure t
  :hook (org-mode . yas-minor-mode)
  :config
  (yas-reload-all)
  )

;; ============================================================
;; Development
;; ============================================================

(use-package magit
  :ensure t)

;; ============================================================
;; Multimedia
;; ============================================================


;; RSS feed
(use-package elfeed
  :ensure t
  :bind (("C-c e" . elfeed)
         :map elfeed-search-mode-map
         ("e" . elfeed-update)
         ("w" . my/elfeed-watch-with-mpv)
         )
  :config
  ;; Your RSS feeds
  (setq elfeed-feeds '())
  (setq elfeed-search-keep-old-entries t)
  (setq elfeed-search-filter "@6-months-ago -junk")
  (add-hook 'elfeed-new-entry-hook 'my/elfeed-filter-shorts)
  )

(defun my/elfeed-watch-with-mpv (entry)
  "Opens mpv with the URL associated to the current elfeed entry. This is
useful for example when watching YouTube videos."
  (interactive (list (elfeed-search-selected :single)))
  (let ((url (elfeed-entry-link entry)))
    (when url
      (elfeed-untag entry 'unread)
      (elfeed-search-update-entry entry)
      ;; Remember to deatch process so we can quit Emacs without quitting the video itself.
      ;; Remember to save ition on quit.
      (call-process "sh" nil 0 nil "-c"  (format "mpv --autofit=70%% --save-position-on-quit '%s' &" url))
      )))

(defun my/elfeed-filter-shorts (entry)
  "Filter out YouTube Shorts from elfeed entries."
  (let ((url (elfeed-entry-link entry)))
    (when (and url (string-match-p "/shorts/" url))
      (elfeed-untag entry 'unread)
      (elfeed-tag entry 'junk))))

;; Exporting in LaTeX to PDF
(with-eval-after-load 'ox-latex
  (setq org-latex-default-packages-alist
        (remove '("normalem" "ulem" t) org-latex-default-packages-alist)))

(setq org-latex-src-block-backend 'listings)

;; ============================================================
;; Project
;; ============================================================

(use-package projectile
  :ensure t
  :config (projectile-mode)
  :bind-keymap
  ;; all projectile-related keybinds start from the same root.
  ("C-c p" . projectile-command-map)
  :init
  (setq projectile-project-search-path
	'("~/programming/"
          "~/.emacs.d/snippets/"
          "~/dotfile/"
          "~/tool/"
	  )
	)
  ;; the first thing we want to do when switching project is to open
  ;; the dired buffer within the project folder.
  (setq projectile-switch-project-action #'projectile-dired)
  )

;; ============================================================
;; General
;; ============================================================

(setq confirm-kill-processes nil)

;; Set global value for paragraph width
(setq-default fill-column 70)

;; Stop emacs from losing informations.
(setq undo-limit 20000000)
(setq undo-strong-limit 40000000)

;; Smooth scroll
(setq scroll-step 3)
(setq line-number-mode t)
(setq inhibit-startup-screen t)
(setq ring-bell-function (quote ignore))

;; add column number in the main bar
(column-number-mode)
(global-visual-line-mode)

(setq next-line-add-newlines nil)
(setq-default truncate-lines t)
(setq truncate-partial-width-windows nil)

;; split vertically when doing switch-to-buffer-other-window
(setq split-width-threshold nil)

;; Modeline stuff
(setq display-time-default-load-average nil)

;; Various UI stuff
(display-time)
(scroll-bar-mode -1)
(menu-bar-mode -1)
(tool-bar-mode 0) ;; Turn off the toolbar

;; Fringe
(fringe-mode 0)

;; Set prefer coding system
(prefer-coding-system 'utf-8-unix)

;; Simple type 'y' for 'yes' and 'n' for 'no'.
(defalias 'yes-or-no-p 'y-or-n-p)

;; Font & stuff
(eval-after-load "dired-aux"
  '(add-to-list 'dired-compress-file-suffixes
		'("\\.zip\\'" ".zip" "unzip")))

;; Set font to be used
(add-to-list 'default-frame-alist '(font . "Liberation Mono"))
(set-face-attribute 'default t :font "Liberation Mono")

(setq resize-mini-windows 'grow-only)

;; When using authentication, do not ask if I want to save credentials
(setq auth-source-save-behavior nil)

;; Grep command
(setq grep-command "grep --color=auto -nrH --null")

;; use chromium for the browser
(setq browse-url-browser-function 'browse-url-chromium)

;; trailing whitespaces
;; (add-hook 'before-save-hook 'delete-trailing-whitespace)
(setq-default show-trailing-whitespace nil)

;; Indentiation
;; nil value means 'do not set tabs, ever!'
(setq-default tab-stop-list nil)
(setq-default indent-tabs-mode nil)
(setq-default standard-indent 2)

(setq org-src-preserve-indentation 't)

;; Backups
(unless (file-exists-p "~/.emacs.d/.auto_saves/")
  (make-directory "~/.emacs.d/.auto_saves/")
  )

(setq make-backup-files nil
      auto-save-default t
      auto-save-timeout 1
      auto-save-interval 300
      auto-save-file-name-transforms '((".*" "~/.emacs.d/.auto_saves/" t))
      create-lockfiles nil)

;; Avoid "file name too long" when creating a copy of a file that is
;; too long by compusing the hash of its full path.
(advice-add 'make-auto-save-file-name :around
            #'my/shorten-auto-save-file-name)
(defun my/shorten-auto-save-file-name (&rest args)
  (let ((buffer-file-name
         (when buffer-file-name (sha1 buffer-file-name))))
    (apply args)))

;; ============================================================
;; Custom Functions (stubs)
;; ============================================================

(defun my/tool ()
  "Custom tool function - to be implemented."
  (interactive)
  (message "my/tool: not yet implemented"))

(defun refresh-current-file ()
  "Refresh current file - to be implemented."
  (interactive)
  (message "refresh-current-file: not yet implemented"))

(defun compress-lines ()
  "Compress lines - to be implemented."
  (interactive)
  (message "compress-lines: not yet implemented"))


(defun my/vterm-window-split ()
  "Apre un buffer vterm in una finestra sotto quella corrente."
  (interactive)
  (let ((buf (generate-new-buffer-name "*vterm*")))
    (split-window-below -10)  ; -15 significa 15 righe dal basso
    (other-window 1)
    (vterm buf)))

(defun my/open-browser ()
  "Menu per aprire Chromium in diverse modalità."
  (interactive)
  (let ((choice (completing-read "Select browser mode: "
                                  '("anon" "admin" "proxy")
                                  nil t)))
    (cond
     ((string= choice "anon")
      (start-process "chromium-anon" nil "chromium" "--incognito"))
     
     ((string= choice "admin")
      (start-process "chromium-admin" nil "chromium"))
     
     ((string= choice "proxy")
      (let ((proxy-addr (read-string "Proxy address (host:port): " "127.0.0.1:8080")))
        (start-process "chromium-proxy" nil "chromium"
                       "--incognito"
                       (format "--proxy-server=%s" proxy-addr)))))))

(global-set-key (kbd "C-c b") 'my/open-browser)

(defun my/vterm-copy-command ()
  "Copy vterm command - to be implemented."
  (interactive)
  (message "my/vterm-copy-command: not yet implemented"))

;; ============================================================
;; Keybindings
;; ============================================================

(setq my/keybinds
      '(
        ;; emacs built-in
        ("C-c m" . comment-region)
        ("C-c n" . uncomment-region)
        ("s-q" . quoted-insert)

        ;; new packages
        ( "C-x C-b" . ibuffer)
        ("C-x g" . magit-status)
        ( "C-=" . er/expand-region)

        ;; custom keybinds
        ("C-q" . my/tool)
        ("C-c a" . refresh-current-file)
        ("C-c q" . query-replace)
        ("C-c w" . compress-lines)
        
        ("C-c v" . my/vterm-window-split)
        ("C-c o" . my/vterm-copy-command)
        ;; ("C-c t" . mu4e)  ;; Uncomment if you install mu4e
        )
      )

(defun my/text-bigger ()
  "Aumenta la dimensione del testo."
  (interactive)
  (text-scale-increase 1)
  (message "enlarged text"))

(defun my/text-smaller ()
  "Diminuisce la dimensione del testo."
  (interactive)
  (text-scale-decrease 1)
  (message "reduced text"))

;; Text
(global-set-key (kbd "C-+") 'my/text-bigger)
(global-set-key (kbd "C--") 'my/text-smaller)

(dolist (data my/keybinds)
  (let* ((keybind (car data))
         (fun (cdr data))
         )
    (if (fboundp fun)
        (global-set-key (kbd keybind) fun)
      (display-warning 'custom-config (format "Keybind not set for: %s" fun) :warning)
      )
    )
  )

;; ============================================================
;; End - Theme and Startup
;; ============================================================

;; load choosen theme
;; (modus-themes-load-theme 'standard-dark)
;; (modus-themes-load-theme 'modus-vivendi)
;; (set-face-background 'fringe "black")

;; Load initial buffers
(when (file-exists-p env/dotemacs-path)
  (find-file env/dotemacs-path))
(when (file-exists-p env/tool-path)
  (find-file env/tool-path))

;; Startup buffer with term
;; (DISABLED: multi-vterm caused autoload error)
;;  (switch-to-buffer "*scratch*")
;; (multi-vterm)
;;  (setq display-line-numbers nil)
  

(provide 'init)
;;; init.el ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(spacemacs-dark))
 '(custom-safe-themes
   '("02f57ef0a20b7f61adce51445b68b2a7e832648ce2e7efb19d217b6454c1b644"
     "bffa9739ce0752a37d9b1eee78fc00ba159748f50dc328af4be661484848e476"
     "5259cf3d5062ea1b0de4f5a3c550b55e2c4a347b19fa874c8522e6171e6a4840"
     default))
 '(package-selected-packages
   '(beacon better-shell corfu denote doom-modeline ef-themes elfeed
            eterm-256color expand-region gruber-darker-theme
            ivy-posframe ivy-prescient jupyter magit multi-vterm
            ox-hugo popwin projectile spacemacs-theme standard-themes
            yasnippet)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(add-hook 'emacs-startup-hook
          (lambda ()
            (vterm)))

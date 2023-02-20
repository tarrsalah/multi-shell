;;; multi-shell.el --- Like multi-term.el and multi-vterm but for shell -*- lexical-binding: t; -*-
;;
;; Authors: Salah Eddine Taouririt <tarrsalah@gmail.com>
;; URL: https://github.com/tarrsalah/multi-shell
;; Version: 0.1
;; Package-Requires: ((emacs 28.2) (project "0.8.1"))
;; Keywords: terminals, shell

;; This file is not part of GNU Emacs

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; For a full copy of the GNU General Public License
;; see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; Managing multiple shell buffers in Emacs. This package is inspired by
;; multi-vterm.el


;;; Code:
(require 'project)
(require 'shell)

(defgroup multi-shell nil
  "Multi shell customization group"
  :group 'shell)

(defcustom multi-shell-buffer-name "shell"
  "The shell buffer name."
  :type 'string
  :group 'multi-shell)

(defun multi-shell-format-buffer-name (name)
  "Format shell buffer name."
  (format "*%s - %s*" multi-shell-buffer-name name))

(defun multi-shell-project-root ()
  "Get projectile using projectile or project.el."
  (if (fboundp 'projectile-project-root)
      (projectile-project-root)
    (project-root
     (or (project-current) `(transient . ,default-directory)))))

(defun multi-shell-project-buffer-name ()
  "Get project buffer name"
  (multi-shell-format-buffer-name (multi-shell-project-root)))

(defun multi-shell-buffer (&optional dedicated-window)
  "Get shell buffer"
  (with-temp-buffer
    (let ((buffer-name))
      (cond ((eq dedicated-window 'project)
             (progn
               (setq default-directory (multi-shell-project-root))
               (setq buffer-name (multi-shell-project-buffer-name))))
            (t (setq buffer-name "*multi-shell*")))
      (let ((buffer (get-buffer buffer-name)))
        (if buffer buffer
          (let ((buffer (generate-new-buffer buffer-name)))
            (set-buffer buffer)
            (shell buffer)
            buffer))))))

;;;###autoload
(defun multi-shell-project ()
  "Open shell buffer for project"
  (interactive)
  (if (multi-shell-project-root)
      (if (buffer-live-p (get-buffer (multi-shell-project-buffer-name)))
          (if (string-equal (buffer-name (current-buffer)) (multi-shell-project-buffer-name))
              (delete-window (selected-window))
            (switch-to-buffer-other-window (multi-shell-project-buffer-name)))
        (progn
           (split-window-vertically)
           (other-window 1)
          (multi-shell-buffer 'project)))
    (message "This file is not in a project")))

(provide 'multi-shell)
;;; multi-shell.el ends here

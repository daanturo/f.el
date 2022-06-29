;;; f.el --- Modern API for working with files and directories -*- lexical-binding: t; -*-

;; Copyright (C) 2013 Johan Andersson

;; Author: Johan Andersson <johan.rejeep@gmail.com>
;; Maintainer: Lucien Cartier-Tilet <lucien@phundrak.com>
;; Version: 0.20.0
;; Package-Requires: ((emacs "24.1") (s "1.7.0") (dash "2.2.0"))
;; Keywords: files, directories
;; Homepage: http://github.com/rejeep/f.el

;; This file is NOT part of GNU Emacs.

;;; License:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Code:



(require 's)
(require 'dash)

(when (version<= "28.1" emacs-version)
  (unless (fboundp 'define-short-documentation-group)
    (require 'shortdoc))

  (define-short-documentation-group f
    "Paths"
    (f-join
     :eval (f-join "path")
     :eval (f-join "path" "to")
     :eval (f-join "/" "path" "to" "heaven")
     :eval (f-join "path" "/to" "file"))

    (f-split
     :eval (f-split "path")
     :eval (f-split "path/to")
     :eval (f-split "/path/to/heaven")
     :eval (f-split "~/back/to/earth"))

    (f-expand
     :no-eval (f-expand "name")
     :result-string "/default/directory/name"
     :no-eval (f-expand "name" "other/directory")
     :result-string "other/directory/name")

    (f-filename
     :eval (f-filename "path/to/file.ext")
     :eval (f-filename "path/to/directory"))

    (f-dirname
     :eval (f-dirname "path/to/file.ext")
     :eval (f-dirname "path/to/directory")
     :eval (f-dirname "/"))

    (f-common-parent
     :eval (f-common-parent '("foo/bar/baz" "foo/bar/qux" "foo/bar/mux"))
     :eval (f-common-parent '("/foo/bar/baz" "/foo/bar/qux" "/foo/bax/mux"))
     :eval (f-common-parent '("foo/bar/baz" "quack/bar/qux" "lack/bar/mux")))

    (f-ext
     :eval (f-ext "path/to/file")
     :eval (f-ext "path/to/file.txt")
     :eval (f-ext "path/to/file.txt.org"))

    (f-no-ext
     :eval (f-no-ext "path/to/file")
     :eval (f-no-ext "path/to/file.txt")
     :eval (f-no-ext "path/to/file.txt.org"))

    (f-swap-ext
     :eval (f-swap-ext "path/to/file.ext" "org"))

    (f-base
     :eval (f-base "path/to/file.ext")
     :eval (f-base "path/to/directory"))

    (f-relative
     :eval (f-relative "/some/path/relative/to/my/file.txt" "/some/path/")
     :eval (f-relative "/default/directory/my/file.txt"))

    (f-short
     :no-eval (f-short "/Users/foo/Code/on/macOS")
     :result-string "~/Code/on/macOS"
     :no-eval (f-short "/home/foo/Code/on/linux")
     :result-string "~/Code/on/linux"
     :eval (f-short "/path/to/Code/bar"))

    (f-long
     :eval (f-long "~/Code/bar")
     :eval (f-long "/path/to/Code/bar"))

    (f-canonical
     :eval (f-canonical "/path/to/real/file")
     :no-eval (f-canonical "/link/to/file")
     :result-string "/path/to/real/file")

    (f-slash
     :no-eval (f-slash "/path/to/file")
     :result-string "/path/to/file"
     :no-eval (f-slash "/path/to/dir")
     :result-string "/path/to/dir/"
     :no-eval (f-slash "/path/to/dir/")
     :result-string "/path/to/dir/")

    (f-full
     :eval (f-full "~/path/to/file")
     :eval (f-full "~/path/to/dir")
     :eval (f-full "~/path/to/dir/"))

    (f-uniquify
     :eval (f-uniquify '("/foo/bar" "/foo/baz" "/foo/quux"))
     :eval (f-uniquify '("/foo/bar" "/www/bar" "/foo/quux"))
     :eval (f-uniquify '("/foo/bar" "/www/bar" "/www/bar/quux"))
     :eval (f-uniquify '("/foo/bar" "/foo/baz" "/home/www/bar" "/home/www/baz" "/var/foo" "/opt/foo/www/baz")))

    (f-uniquify-alist
     :eval (f-uniquify-alist '("/foo/bar" "/foo/baz" "/foo/quux"))
     :eval (f-uniquify-alist '("/foo/bar" "/www/bar" "/foo/quux"))
     :eval (f-uniquify-alist '("/foo/bar" "/www/bar" "/www/bar/quux"))
     :eval (f-uniquify-alist '("/foo/bar" "/foo/baz" "/home/www/bar" "/home/www/baz" "/var/foo" "/opt/foo/www/baz")))

    "I/O"
    (f-read-bytes
     :no-eval* (f-read-bytes "path/to/binary/data"))

    (f-write-bytes
     :no-eval* (f-write-bytes (unibyte-string 72 101 108 108 111 32 119 111 114 108 100) "path/to/binary/data"))

    (f-append-bytes
     :no-eval* (f-append-bytes "path/to/file" (unibyte-string 72 101 108 108 111 32 119 111 114 108 100)))

    (f-read-text
     :no-eval* (f-read-text "path/to/file.txt" 'utf-8)
     :no-eval* (f-read "path/to/file.txt" 'utf-8))

    (f-write-text
     :no-eval* (f-write-text "Hello world" 'utf-8 "path/to/file.txt")
     :no-eval* (f-write "Hello world" 'utf-8 "path/to/file.txt"))

    (f-append-text
     :no-eval* (f-append-text "Hello world" 'utf-8 "path/to/file.txt")
     :no-eval* (f-append "Hello world" 'utf-8 "path/to/file.txt"))

    "Destructive"
    (f-mkdir
     :no-eval (f-mkdir "dir")
     :result-string "creates /default/directory/dir"
     :no-eval (f-mkdir "other" "dir")
     :result-string "creates /default/directory/other/dir"
     :no-eval (f-mkdir "/" "some" "path")
     :result-string "creates /some/path"
     :no-eval (f-mkdir "~" "yet" "another" "dir")
     :result-string "creates ~/yet/another/dir")

    (f-mkdir-full-path
     :no-eval (f-mkdir-full-path "dir")
     :result-string "creates /default/directory/dir"
     :no-eval (f-mkdir-full-path "other/dir")
     :result-string "creates /default/directory/other/dir"
     :no-eval (f-mkdir-full-path "/some/path")
     :result-string "creates /some/path"
     :no-eval (f-mkdir-full-path "~/yet/another/dir")
     :result-string "creates ~/yet/another/dir")

    (f-delete
     :no-eval* (f-delete "dir")
     :no-eval* (f-delete "other/dir" t)
     :no-eval* (f-delete "path/to/file.txt"))

    (f-symlink
     :no-eval* (f-symlink "path/to/source" "path/to/link"))

    (f-move
     :no-eval* (f-move "path/to/file.txt" "new-file.txt")
     :no-eval* (f-move "path/to/file.txt" "other/path"))

    (f-copy
     :no-eval* (f-copy "path/to/file.txt" "new-file.txt")
     :no-eval* (f-copy "path/to/dir" "other/dir"))

    (f-copy-contents
     :no-eval* (f-copy-contents "path/to/dir" "path/to/other/dir"))

    (f-touch
     :no-eval* (f-touch "path/to/existing/file.txt")
     :no-eval* (f-touch "path/to/non/existing/file.txt"))

    "Predicates"
    (f-exists-p
     :no-eval* (f-exists-p "path/to/file.txt")
     :no-eval* (f-exists-p "path/to/dir"))

    (f-directory-p
     :no-eval* (f-directory-p "path/to/file.txt")
     :no-eval* (f-directory-p "path/to/dir"))

    (f-file-p
     :no-eval* (f-file-p "path/to/file.txt")
     :no-eval* (f-file-p "path/to/dir"))

    (f-symlink-p
     :no-eval* (f-symlink-p "path/to/file.txt")
     :no-eval* (f-symlink-p "path/to/dir")
     :no-eval* (f-symlink-p "path/to/link"))

    (f-readable-p
     :no-eval* (f-readable-p "path/to/file.txt")
     :no-eval* (f-readable-p "path/to/dir"))

    (f-writable-p
     :no-eval* (f-writable-p "path/to/file.txt")
     :no-eval* (f-writable-p "path/to/dir"))

    (f-executable-p
     :no-eval* (f-executable-p "path/to/file.txt")
     :no-eval* (f-executable-p "path/to/dir"))

    (f-absolute-p
     :eval (f-absolute-p "path/to/dir")
     :eval (f-absolute-p "/full/path/to/dir"))

    (f-relative-p
     :eval (f-relative-p "path/to/dir")
     :eval (f-relative-p "/full/path/to/dir"))

    (f-root-p
     :eval (f-root-p "/")
     :eval (f-root-p "/not/root"))

    (f-ext-p
     :eval (f-ext-p "path/to/file.el" "el")
     :eval (f-ext-p "path/to/file.el" "txt")
     :eval (f-ext-p "path/to/file.el")
     :eval (f-ext-p "path/to/file"))

    (f-same-p
     :eval (f-same-p "foo.txt" "foo.txt")
     :eval (f-same-p "foo/bar/../baz" "foo/baz")
     :eval (f-same-p "/path/to/foo.txt" "/path/to/bar.txt"))

    (f-parent-of-p
     :no-eval (f-parent-of-p "/path/to" "/path/to/dir")
     :result t
     :no-eval (f-parent-of-p "/path/to/dir" "/path/to")
     :result nil
     :no-eval (f-parent-of-p "/path/to" "/path/to")
     :result nil)

    (f-child-of-p
     :no-eval (f-child-of-p "/path/to" "/path/to/dir")
     :result nil
     :no-eval (f-child-of-p "/path/to/dir" "/path/to")
     :result t
     :no-eval (f-child-of-p "/path/to" "/path/to")
     :result nil)

    (f-ancestor-of-p
     :no-eval (f-ancestor-of-p "/path/to" "/path/to/dir")
     :result t
     :no-eval (f-ancestor-of-p "/path" "/path/to/dir")
     :result t
     :no-eval (f-ancestor-of-p "/path/to/dir" "/path/to")
     :result nil
     :no-eval (f-ancestor-of-p "/path/to" "/path/to")
     :result nil)

    (f-descendant-of-p
     :no-eval (f-descendant-of-p "/path/to/dir" "/path/to")
     :result t
     :no-eval (f-descendant-of-p "/path/to/dir" "/path")
     :result t
     :no-eval (f-descendant-of-p "/path/to" "/path/to/dir")
     :result nil
     :no-eval (f-descendant-of-p "/path/to" "/path/to")
     :result nil)

    (f-hidden-p
     :no-eval (f-hidden-p "/path/to/foo")
     :result nil
     :no-eval (f-hidden-p "/path/to/.foo")
     :result t)

    (f-empty-p
     :no-eval (f-empty-p "/path/to/empty-file")
     :result t
     :no-eval (f-empty-p "/path/to/file-with-contents")
     :result nil
     :no-eval (f-empty-p "/path/to/empty-dir/")
     :result t
     :no-eval (f-empty-p "/path/to/dir-with-contents/")
     :result nil)

    "Stats"
    (f-size
     :no-eval* (f-size "path/to/file.txt")
     :no-eval* (f-size "path/to/dir"))

    (f-depth
     :eval (f-depth "/")
     :eval (f-depth "/var/")
     :eval (f-depth "/usr/local/bin"))

    (f-change-time
     :no-eval* (f-change-time "path/to/file.txt")
     :no-eval* (f-change-time "path/to/dir"))

    (f-modification-time
     :no-eval* (f-modification-time "path/to/file.txt")
     :no-eval* (f-modification-time "path/to/dir"))

    (f-access-time
     :no-eval* (f-access-time "path/to/file.txt")
     :no-eval* (f-access-time "path/to/dir"))

    "Misc"
    (f-this-file
     :no-eval* (f-this-file))

    (f-path-separator
     :eval (f-path-separator))

    (f-glob
     :noeval* (f-glob "path/to/*.el")
     :noeval* (f-glob "*.el" "path/to"))

    (f-entries
     :no-eval* (f-entries "path/to/dir")
     :no-eval* (f-entries "path/to/dir" (lambda (file) (s-matches? "test" file)))
     :no-eval* (f-entries "path/to/dir" nil t)
     :no-eval* (f--entries "path/to/dir" (s-matches? "test" it)))

    (f-directories
     :no-eval* (f-directories "path/to/dir")
     :no-eval* (f-directories "path/to/dir" (lambda (dir) (equal (f-filename dir) "test")))
     :no-eval* (f-directories "path/to/dir" nil t)
     :no-eval* (f--directories "path/to/dir" (equal (f-filename it) "test")))

    (f-files
     :no-eval* (f-files "path/to/dir")
     :no-eval* (f-files "path/to/dir" (lambda (file) (equal (f-ext file) "el")))
     :no-eval* (f-files "path/to/dir" nil t)
     :no-eval* (f--files "path/to/dir" (equal (f-ext it) "el")))

    (f-root
     :eval (f-root))

    (f-traverse-upwards
     :no-eval* (f-traverse-upwards
                (lambda (path)
                  (f-exists? (f-expand ".git" path)))
                start-path)

     :no-eval* (f--traverse-upwards (f-exists? (f-expand ".git" it)) start-path))

    (f-with-sandbox
     :no-eval (f-with-sandbox foo-path
                (f-touch (f-expand "foo" foo-path)))
     :no-eval (f-with-sandbox (list foo-path bar-path)
                (f-touch (f-expand "foo" foo-path))
                (f-touch (f-expand "bar" bar-path)))
     :no-eval (f-with-sandbox foo-path
                (f-touch (f-expand "bar" bar-path)))))) ;; "Destructive operation outside sandbox"


(put 'f-guard-error 'error-conditions '(error f-guard-error))
(put 'f-guard-error 'error-message "Destructive operation outside sandbox")

(defvar f--guard-paths nil
  "List of allowed paths to modify when guarded.

Do not modify this variable.")

(defmacro f--destructive (path &rest body)
  "If PATH is allowed to be modified, yield BODY.

If PATH is not allowed to be modified, throw error."
  (declare (indent 1))
  `(if f--guard-paths
       (if (--any? (or (f-same-p it ,path)
                       (f-ancestor-of-p it ,path)) f--guard-paths)
           (progn ,@body)
         (signal 'f-guard-error (list ,path f--guard-paths)))
     ,@body))


;;;; Paths

(defun f-join (&rest args)
  "Join ARGS to a single path.

Be aware if one of the arguments is an absolute path, `f-join'
will discard all the preceeding arguments and make this absolute
path the new root of the generated path."
  (let (path
        (relative (f-relative-p (car args))))
    (-map
     (lambda (arg)
       (setq path (cond ((not path) arg)
                        ((f-absolute-p arg)
                         (progn
                           (setq relative nil)
                           arg))
                        (t (f-expand arg path)))))
     args)
    (if relative (f-relative path) path)))

(defun f-split (path)
  "Split PATH and return list containing parts."
  (let ((parts (split-string path (f-path-separator) 'omit-nulls)))
    (if (string= (s-left 1 path) (f-path-separator))
        (push (f-path-separator) parts)
      parts)))

(defun f-expand (path &optional dir)
  "Expand PATH relative to DIR (or `default-directory').
PATH and DIR can be either a directory names or directory file
names.  Return a directory name if PATH is a directory name, and
a directory file name otherwise.  File name handlers are
ignored."
  (let (file-name-handler-alist)
    (expand-file-name path dir)))

(defun f-filename (path)
  "Return the name of PATH."
  (file-name-nondirectory (directory-file-name path)))

(defalias 'f-parent 'f-dirname)

(defun f-dirname (path)
  "Return the parent directory to PATH."
  (let ((parent (file-name-directory
                 (directory-file-name (f-expand path default-directory)))))
    (unless (f-same-p path parent)
      (if (f-relative-p path)
          (f-relative parent)
        (directory-file-name parent)))))

(defun f-common-parent (paths)
  "Return the deepest common parent directory of PATHS."
  (cond
   ((not paths) nil)
   ((not (cdr paths)) (f-parent (car paths)))
   (:otherwise
    (let* ((paths (-map 'f-split paths))
           (common (caar paths))
           (re nil))
      (while (and (not (null (car paths))) (--all? (equal (car it) common) paths))
        (setq paths (-map 'cdr paths))
        (push common re)
        (setq common (caar paths)))
      (cond
       ((null re) "")
       ((and (= (length re) 1) (f-root-p (car re)))
        (f-root))
       (:otherwise
        (concat (apply 'f-join (nreverse re)) "/")))))))

(defalias 'f-ext 'file-name-extension)

(defalias 'f-no-ext 'file-name-sans-extension)

(defun f-swap-ext (path ext)
  "Return PATH but with EXT as the new extension.
EXT must not be nil or empty."
  (if (s-blank-p ext)
      (error "Extension cannot be empty or nil")
    (concat (f-no-ext path) "." ext)))

(defun f-base (path)
  "Return the name of PATH, excluding the extension of file."
  (f-no-ext (f-filename path)))

(defalias 'f-relative 'file-relative-name)

(defalias 'f-short 'abbreviate-file-name)
(defalias 'f-abbrev 'abbreviate-file-name)

(defun f-long (path)
  "Return long version of PATH."
  (f-expand path))

(defalias 'f-canonical 'file-truename)

(defun f-slash (path)
  "Append slash to PATH unless one already.

Some functions, such as `call-process' requires there to be an
ending slash."
  (if (f-dir-p path)
      (file-name-as-directory path)
    path))

(defun f-full (path)
  "Return absolute path to PATH, with ending slash."
  (f-slash (f-long path)))

(defun f--uniquify (paths)
  "Helper for `f-uniquify' and `f-uniquify-alist'."
  (let* ((files-length (length paths))
         (uniq-filenames (--map (cons it (f-filename it)) paths))
         (uniq-filenames-next (-group-by 'cdr uniq-filenames)))
    (while (/= files-length (length uniq-filenames-next))
      (setq uniq-filenames-next
            (-group-by 'cdr
                       (--mapcat
                        (let ((conf-files (cdr it)))
                          (if (> (length conf-files) 1)
                              (--map (cons
                                      (car it)
                                      (concat
                                       (f-filename (s-chop-suffix (cdr it)
                                                                  (car it)))
                                       (f-path-separator) (cdr it)))
                                     conf-files)
                            conf-files))
                        uniq-filenames-next))))
    uniq-filenames-next))

(defun f-uniquify (files)
  "Return unique suffixes of FILES.

This function expects no duplicate paths."
  (-map 'car (f--uniquify files)))

(defun f-uniquify-alist (files)
  "Return alist mapping FILES to unique suffixes of FILES.

This function expects no duplicate paths."
  (-map 'cadr (f--uniquify files)))


;;;; I/O

(defun f-read-bytes (path &optional beg end)
  "Read binary data from PATH.

Return the binary data as unibyte string. The optional second and
third arguments BEG and END specify what portion of the file to
read."
  (with-temp-buffer
    (set-buffer-multibyte nil)
    (setq buffer-file-coding-system 'binary)
    (insert-file-contents-literally path nil beg end)
    (buffer-substring-no-properties (point-min) (point-max))))

(defalias 'f-read 'f-read-text)
(defun f-read-text (path &optional coding)
  "Read text with PATH, using CODING.

CODING defaults to `utf-8'.

Return the decoded text as multibyte string."
  (decode-coding-string (f-read-bytes path) (or coding 'utf-8)))

(defalias 'f-write 'f-write-text)
(defun f-write-text (text coding path)
  "Write TEXT with CODING to PATH.

TEXT is a multibyte string.  CODING is a coding system to encode
TEXT with.  PATH is a file name to write to."
  (f-write-bytes (encode-coding-string text coding) path))

(defun f-unibyte-string-p (s)
  "Determine whether S is a unibyte string."
  (not (multibyte-string-p s)))

(defun f-write-bytes (data path)
  "Write binary DATA to PATH.

DATA is a unibyte string.  PATH is a file name to write to."
  (f--write-bytes data path nil))

(defalias 'f-append 'f-append-text)
(defun f-append-text (text coding path)
  "Append TEXT with CODING to PATH.

If PATH does not exist, it is created."
  (f-append-bytes (encode-coding-string text coding) path))

(defun f-append-bytes (data path)
  "Append binary DATA to PATH.

If PATH does not exist, it is created."
  (f--write-bytes data path :append))

(defun f--write-bytes (data filename append)
  "Write binary DATA to FILENAME.
If APPEND is non-nil, append the DATA to the existing contents."
  (f--destructive filename
    (unless (f-unibyte-string-p data)
      (signal 'wrong-type-argument (list 'f-unibyte-string-p data)))
    (let ((coding-system-for-write 'binary)
          (write-region-annotate-functions nil)
          (write-region-post-annotation-function nil))
      (write-region data nil filename append :silent)
      nil)))


;;;; Destructive

(defun f-mkdir (&rest dirs)
  "Create directories DIRS.

DIRS should be a successive list of directories forming together
a full path. The easiest way to call this function with a fully
formed path is using `f-split' alongside it:

    (apply #'f-mkdir (f-split \"path/to/file\"))

Although it works sometimes, it is not recommended to use fully
formed paths in the function. In this case, it is recommended to
use `f-mkdir-full-path' instead."
  (let (path)
    (-each
        dirs
      (lambda (dir)
        (setq path (f-expand dir path))
        (unless (f-directory-p path)
          (f--destructive path (make-directory path)))))))

(defun f-mkdir-full-path (dir)
  "Create DIR from a full path.

This function is similar to `f-mkdir' except it can accept a full
path instead of requiring several successive directory names."
  (apply #'f-mkdir (f-split dir)))

(defun f-delete (path &optional force)
  "Delete PATH, which can be file or directory.

If FORCE is t, a directory will be deleted recursively."
  (f--destructive path
    (if (or (f-file-p path) (f-symlink-p path))
        (delete-file path)
      (delete-directory path force))))

(defun f-symlink (source path)
  "Create a symlink to SOURCE from PATH."
  (f--destructive path (make-symbolic-link source path)))

(defun f-move (from to)
  "Move or rename FROM to TO.
If TO is a directory name, move FROM into TO."
  (f--destructive to (rename-file from to t)))

(defun f-copy (from to)
  "Copy file or directory FROM to TO.
If FROM names a directory and TO is a directory name, copy FROM
into TO as a subdirectory."
  (f--destructive to
    (if (f-file-p from)
        (copy-file from to)
      ;; The behavior of `copy-directory' differs between Emacs 23 and
      ;; 24 in that in Emacs 23, the contents of `from' is copied to
      ;; `to', while in Emacs 24 the directory `from' is copied to
      ;; `to'. We want the Emacs 24 behavior.
      (if (> emacs-major-version 23)
          (copy-directory from to)
        (if (f-dir-p to)
            (progn
              (apply 'f-mkdir (f-split to))
              (let ((new-to (f-expand (f-filename from) to)))
                (copy-directory from new-to)))
          (copy-directory from to))))))

(defun f-copy-contents (from to)
  "Copy contents in directory FROM, to directory TO."
  (unless (f-exists-p to)
    (error "Cannot copy contents to non existing directory %s" to))
  (unless (f-dir-p from)
    (error "Cannot copy contents as %s is a file" from))
  (--each (f-entries from)
    (f-copy it (file-name-as-directory to))))

(defun f-touch (path)
  "Update PATH last modification date or create if it does not exist."
  (f--destructive path
    (if (f-file-p path)
        (set-file-times path)
      (f-write-bytes "" path))))


;;;; Predicates

(defalias 'f-exists-p 'file-exists-p)
(defalias 'f-exists? 'file-exists-p)

(defalias 'f-directory-p 'file-directory-p)
(defalias 'f-directory? 'file-directory-p)
(defalias 'f-dir-p 'file-directory-p)
(defalias 'f-dir? 'file-directory-p)


(defalias 'f-file-p 'file-regular-p)
(defalias 'f-file? 'file-regular-p)

(defun f-symlink-p (path)
  "Return t if PATH is symlink, false otherwise."
  (not (not (file-symlink-p path))))

(defalias 'f-symlink? 'f-symlink-p)

(defalias 'f-readable-p 'file-readable-p)
(defalias 'f-readable? 'file-readable-p)

(defalias 'f-writable-p 'file-writable-p)
(defalias 'f-writable? 'file-writable-p)

(defalias 'f-executable-p 'file-executable-p)
(defalias 'f-executable? 'file-executable-p)

(defalias 'f-absolute-p 'file-name-absolute-p)
(defalias 'f-absolute? 'file-name-absolute-p)

(defun f-relative-p (path)
  "Return t if PATH is relative, false otherwise."
  (not (f-absolute-p path)))

(defalias 'f-relative? 'f-relative-p)

(defun f-root-p (path)
  "Return t if PATH is root directory, false otherwise."
  (not (f-parent path)))

(defalias 'f-root? 'f-root-p)

(defun f-ext-p (path &optional ext)
  "Return t if extension of PATH is EXT, false otherwise.

If EXT is nil or omitted, return t if PATH has any extension,
false otherwise.

The extension, in a file name, is the part that follows the last
'.', excluding version numbers and backup suffixes."
  (if ext
      (string= (f-ext path) ext)
    (not (eq (f-ext path) nil))))

(defalias 'f-ext? 'f-ext-p)

(defalias 'f-equal-p 'f-same-p)
(defalias 'f-equal? 'f-same-p)

(defun f-same-p (path-a path-b)
  "Return t if PATH-A and PATH-B are references to same file."
  (equal
   (f-canonical (directory-file-name (f-expand path-a)))
   (f-canonical (directory-file-name (f-expand path-b)))))

(defalias 'f-same? 'f-same-p)

(defun f-parent-of-p (path-a path-b)
  "Return t if PATH-A is parent of PATH-B."
  (--when-let (f-parent path-b)
    (f-same-p path-a it)))

(defalias 'f-parent-of? 'f-parent-of-p)

(defun f-child-of-p (path-a path-b)
  "Return t if PATH-A is child of PATH-B."
  (--when-let (f-parent path-a)
    (f-same-p it path-b)))

(defalias 'f-child-of? 'f-child-of-p)

(defun f-ancestor-of-p (path-a path-b)
  "Return t if PATH-A is ancestor of PATH-B."
  (unless (f-same-p path-a path-b)
    (string-prefix-p (f-full path-a)
                     (f-full path-b))))

(defalias 'f-ancestor-of? 'f-ancestor-of-p)

(defun f-descendant-of-p (path-a path-b)
  "Return t if PATH-A is desendant of PATH-B."
  (unless (f-same-p path-a path-b)
    (string-prefix-p (f-full path-b)
                     (f-full path-a))))

(defalias 'f-descendant-of? 'f-descendant-of-p)

(defun f-hidden-p (path)
  "Return t if PATH is hidden, nil otherwise."
  (unless (f-exists-p path)
    (error "Path does not exist: %s" path))
  (string= (substring path 0 1) "."))

(defalias 'f-hidden? 'f-hidden-p)

(defun f-empty-p (path)
  "If PATH is a file, return t if the file in PATH is empty, nil otherwise.
If PATH is directory, return t if directory has no files, nil otherwise."
  (if (f-directory-p path)
      (equal (f-files path nil t) nil)
    (= (f-size path) 0)))

(defalias 'f-empty? 'f-empty-p)


;;;; Stats

(defun f-size (path)
  "Return size of PATH.

If PATH is a file, return size of that file.  If PATH is
directory, return sum of all files in PATH."
  (if (f-directory-p path)
      (-sum (-map 'f-size (f-files path nil t)))
    (nth 7 (file-attributes path))))

(defun f-depth (path)
  "Return the depth of PATH.

At first, PATH is expanded with `f-expand'.  Then the full path is used to
detect the depth.
'/' will be zero depth,  '/usr' will be one depth.  And so on."
  (- (length (f-split (f-expand path))) 1))

(defun f-change-time (path)
  "Return the last status change time of PATH.

The status change time (ctime) of PATH in the same format as
`current-time'. See `file-attributes' for technical details."
  (nth 6 (file-attributes path)))

(defun f-modification-time (path)
  "Return the last modification time of PATH.

The modification time (mtime) of PATH in the same format as
`current-time'. See `file-attributes' for technical details."
  (nth 5 (file-attributes path)))

(defun f-access-time (path)
  "Return the last access time of PATH.

The access time (atime) of PATH is in the same format as
`current-time'. See `file-attributes' for technical details."
  (nth 4 (file-attributes path)))


;;;; Misc

(defun f-this-file ()
  "Return path to this file."
  (cond
   (load-in-progress load-file-name)
   ((and (boundp 'byte-compile-current-file) byte-compile-current-file)
    byte-compile-current-file)
   (:else (buffer-file-name))))

(defvar f--path-separator nil
  "A variable to cache result of `f-path-separator'.")

(defun f-path-separator ()
  "Return path separator."
  (or f--path-separator
      (setq f--path-separator (substring (f-join "x" "y") 1 2))))

(defun f-glob (pattern &optional path)
  "Find PATTERN in PATH."
  (file-expand-wildcards
   (f-join (or path default-directory) pattern)))

(defun f--collect-entries (path recursive)
  (let (result
        (entries
         (-reject
          (lambda (file)
            (member (f-filename file) '("." "..")))
          (directory-files path t))))
    (cond (recursive
           (-map
            (lambda (entry)
              (if (f-file-p entry)
                  (setq result (cons entry result))
                (when (f-directory-p entry)
                  (setq result (cons entry result))
                  (if (f-readable-p entry)
                      (setq result (append result (f--collect-entries entry recursive)))
                    result))))
            entries))
          (t (setq result entries)))
    result))

(defmacro f--entries (path body &optional recursive)
  "Anaphoric version of `f-entries'."
  `(f-entries
    ,path
    (lambda (path)
      (let ((it path))
        ,body))
    ,recursive))

(defun f-entries (path &optional fn recursive)
  "Find all files and directories in PATH.

FN - called for each found file and directory.  If FN returns a thruthy
value, file or directory will be included.
RECURSIVE - Search for files and directories recursive."
  (let ((entries (f--collect-entries path recursive)))
    (if fn (-select fn entries) entries)))

(defmacro f--directories (path body &optional recursive)
  "Anaphoric version of `f-directories'."
  `(f-directories
    ,path
    (lambda (path)
      (let ((it path))
        ,body))
    ,recursive))

(defun f-directories (path &optional fn recursive)
  "Find all directories in PATH.  See `f-entries'."
  (let ((directories (-select 'f-directory-p (f--collect-entries path recursive))))
    (if fn (-select fn directories) directories)))

(defmacro f--files (path body &optional recursive)
  "Anaphoric version of `f-files'."
  `(f-files
    ,path
    (lambda (path)
      (let ((it path))
        ,body))
    ,recursive))

(defun f-files (path &optional fn recursive)
  "Find all files in PATH.  See `f-entries'."
  (let ((files (-select 'f-file-p (f--collect-entries path recursive))))
    (if fn (-select fn files) files)))

(defmacro f--traverse-upwards (body &optional path)
  "Anaphoric version of `f-traverse-upwards'."
  `(f-traverse-upwards
    (lambda (dir)
      (let ((it dir))
        ,body))
    ,path))

(defun f-traverse-upwards (fn &optional path)
  "Traverse up as long as FN return nil, starting at PATH.

If FN returns a non-nil value, the path sent as argument to FN is
returned.  If no function callback return a non-nil value, nil is
returned."
  (unless path
    (setq path default-directory))
  (when (f-relative-p path)
    (setq path (f-expand path)))
  (if (funcall fn path)
      path
    (unless (f-root-p path)
      (f-traverse-upwards fn (f-parent path)))))

(defun f-root ()
  "Return absolute root."
  (f-traverse-upwards 'f-root-p))

(defmacro f-with-sandbox (path-or-paths &rest body)
  "Only allow PATH-OR-PATHS and descendants to be modified in BODY."
  (declare (indent 1))
  `(let ((paths (if (listp ,path-or-paths)
                    ,path-or-paths
                  (list ,path-or-paths))))
     (unwind-protect
         (let ((f--guard-paths paths))
           ,@body)
       (setq f--guard-paths nil))))

(provide 'f)

;;; f.el ends here

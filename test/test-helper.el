(require 'cl)
(require 'el-mock)

(defvar f-sandbox-path
  (expand-file-name "sandbox" (file-name-directory load-file-name)))

(defmacro with-default-directory (&rest body)
  `(let ((default-directory "/default/directory")) ,@body))

(defmacro with-sandbox (&rest body)
  `(let ((default-directory f-sandbox-path))
     (mapc
      (lambda (file)
        (if (file-directory-p file)
            (delete-directory file t)
          (delete-file file nil)))
      (directory-files f-sandbox-path t "^[^\\.\\.?]"))
     ,@body))

(defmacro with-no-messages (&rest body)
  `(let ((messages))
     (flet ((message
             (format-string &rest args)
             (add-to-list 'messages (format format-string args) t)))
       ,@body
       (should-not messages))))

(defun should-exist (filename &optional content)
  (let ((path (expand-file-name filename f-sandbox-path)))
    (should (file-exists-p path))
    (when content
      (with-temp-buffer
        (insert-file-contents-literally path)
        (should (equal (buffer-string) content))))))

(defun should-not-exist (filename)
  (let ((path (expand-file-name filename f-sandbox-path)))
    (should-not (file-exists-p path))))
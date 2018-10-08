((markdown-mode . ((markdown-toc-user-toc-structure-manipulation-fn . (lambda (toc-structure)
                                                                        (->> toc-structure
                                                                             (remove-if (lambda (e) (zerop (car e))))
                                                                             (mapcar (lambda (e) (cons (1- (car e)) (cdr e))))))))))

;;;; cl-mpdclient.lisp

(in-package #:cl-mpdclient)

(defparameter *async* nil)

(defparameter *pad-size* 51)
(defparameter *pad-display-size* 9)

(defun matching-artists (artists term)
  (remove-if-not #'(lambda (x)
                     (search term x)) artists))

(defun main (argv)
  (princ argv)
  (sb-ext:disable-debugger)
  (floclient))

(defun fetch-artists (mpdconn)
  (mapcar #'(lambda (x) (subseq x 8)) 
          (list-metadata mpdconn 'artist)))

(defun floclient () 
  (initscr)
  (let* ((mpdconn (connect))
         (cursor-line 0)
         (scroll-index 0)
         (lines (1- *LINES*))
         (artists-width (floor (/ *COLS* 3)))
         (stdout nil)
         (artists (fetch-artists mpdconn))
         (pad (newpad (length artists) 30))
         (searching nil)
         (term (make-array 5 :fill-pointer 0 :adjustable t :element-type 'character)))
    (nodelay pad (if *async* TRUE FALSE))
    (halfdelay 10)
    (cl-ncurses:clear)
    (noecho)
    (loop for artist in artists
          for i from 0
          do (mvwaddstr pad i 0 artist))
    (cl-ncurses:move cursor-line 0)
    (printw "j/k to navigate, P to pause MPD, c to clear, [Enter] to play first song of artist, q to quit. You may need to press j now to see anything.")
    (prefresh pad scroll-index 0 1 0 lines artists-width)
    (refresh)
    (loop for input = (getch) 
          for status = (status mpdconn)
          do (progn
               ;;print duration
               (mvprintw 3 50 (format nil "~a/~a" (first (duration status))
                                      (second (duration status))))
               ;;print term
               (mvprintw 4 50 (format nil "~a" term))
               (unless (eql ERR input)
                 (prefresh pad scroll-index 0 1 0 lines artists-width)
                 (when *async* (sb-unix:nanosleep 0 100))
                 ;;if in search: append char to search term
                 (if searching
                   (case (code-char input)
                     (#\Esc
                      (progn
                        (setf searching nil)
                        (loop while (> (length term) 0) do (vector-pop term))))
                     (#\Rubout (if (> (length term) 0) 
                                    (vector-pop term)
                                    (setf searching nil)))
                     (otherwise (vector-push-extend (code-char input) term)))
                   (case (code-char input)
                     (#\q (return))
                     ;;limit on lower bound
                     (#\j (if (= cursor-line lines)       
                            (incf scroll-index)
                            (cl-ncurses:move (1+ (incf cursor-line)) 0)))
                     (#\k (if (zerop cursor-line)       
                            (decf scroll-index)
                            (cl-ncurses:move (1+ (decf cursor-line)) 0)))
                     (#\P (pause mpdconn))
                     (#\t
                      (progn 
                        (setf scroll-index 0)
                        (prefresh pad scroll-index 0 1 0 lines artists-width)
                        (cl-ncurses:move (setf cursor-line 1) 0))  
                      )
                     (#\c (mpd:clear mpdconn))
                     (#\G (progn ;;TODO
                            (cl-ncurses:move (setf cursor-line (length artists)) 0)
                            ;;(setf scroll-index *max-artists*)
                            ))
                     (#\Newline 
                      (let ((selected (nth cursor-line artists)))
                        (format stdout "Selected ~a~%" selected)
                        (mpd:clear mpdconn)
                        ;;works for some
                        ;;(add mpdconn selected) 
                        (add mpdconn (first (find-tracks mpdconn :artist selected)))
                        (play mpdconn)))
                     (#\/ (setf searching t))
                     (otherwise (format t "'~a'~%" input)))))))
    (delwin pad)
    (disconnect mpdconn))
  (endwin))

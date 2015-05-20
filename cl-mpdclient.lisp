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

(defun floclient () 
  (initscr)
  (let* ((mpdconn (connect))
         (cursor-line 0)
         (scroll-index 0)
         (lines (- *LINES* 1))
         (artists-width (floor (/ *COLS* 3)))
         (stdout nil)
         (artists (mapcar #'(lambda (x) (subseq x 8)) 
                          (list-metadata mpdconn 'artist)))
         (pad (newpad (length artists) 30)))
    ;;    (scrollok *stdscr* TRUE)
    ;;   (idlok *stdscr* TRUE)
    ;;(setscrreg 0 100)
    (nodelay pad (if *async* TRUE FALSE))
    ;;   (cbreak)
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
          while (not (eql (char-code #\q) input))
          do (progn
               (prefresh pad scroll-index 0 1 0 lines artists-width)
               (when *async* (sb-unix:nanosleep 0 100))
               (case (code-char input)
                 ;;limit on lower bound
                 (#\j (if (= cursor-line lines)       
                        (incf scroll-index)
                        (cl-ncurses:move (incf cursor-line) 0)))
                 (#\k (if (zerop cursor-line)       
                        (decf scroll-index)
                        (cl-ncurses:move (decf cursor-line) 0)))
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
                 (#\s (progn 
                        (format stdout "Type to search...~%")
                        (loop for c = (code-char (getch))
                              ;; resizable string
                              with term = (make-array 5 :fill-pointer 0 :adjustable t :element-type 'character)
                              while (not (eql #\q c))
                              ;; escape on \Esc
                              do (progn
                                   (vector-push-extend c term)
                                   (format stdout "Matching ~a~%" term)
                                   (format stdout "~a~%" (matching-artists artists term))))
                        (format stdout "End of search~%")))
                 (otherwise (format stdout "'~a'~%" input)))
               (ping mpdconn)))
    (delwin pad)
    (disconnect mpdconn))
  (endwin))

;;;; cl-mpdclient.lisp

(in-package #:cl-mpdclient)
(defparameter *max-artists* 300)

(defparameter *async* nil)

(defparameter *pad-size* 51)
(defparameter *pad-display-size* 9)

(defun matching-artists (artists term)
  (remove-if-not #'(lambda (x)
                     (search term x)) artists)
  )


(defun floclient (&optional argv) 
  (initscr)
  (let* ((mpdconn (connect))
         (cursor-line 0)
         (scroll-index 0)
         (pad (newpad *pad-size* *pad-size*))
         (artists (subseq (list-metadata mpdconn 'artist) 0 *max-artists*)))
    ;;    (scrollok *stdscr* TRUE)
    ;;   (idlok *stdscr* TRUE)
    ;;(setscrreg 0 100)
    (nodelay pad (if *async* TRUE FALSE))
    ;;   (cbreak)
    (cl-ncurses:clear)
    (noecho)
    (loop for artist in artists
          for i from 0
          do 
          ;;(printw (format nil "~a~%" i))
          ;;(mvprintw i 0 (format nil "~a" i))
          (mvwaddstr pad i 0 (subseq artist 8))
          )
    (cl-ncurses:move cursor-line 0)
    (loop for input = (getch) 
          for i from 0
          while (not (eql (char-code #\q) input))
          do (progn
               (prefresh pad scroll-index 0 0 0 *pad-display-size* *pad-display-size*)
               (when *async* (sb-unix:nanosleep 0 100))
               (case (code-char input)
                 (#\j (if (= cursor-line *pad-display-size*)       
                        (incf scroll-index)
                        (cl-ncurses:move (incf cursor-line) 0)))
                 (#\k (if (zerop cursor-line)       
                        (decf scroll-index)
                        (cl-ncurses:move (decf cursor-line) 0)))
                 (#\P (pause mpdconn))
                 (#\s (progn 
                        (format t "Type to search...~%")
                        (loop for c = (code-char (getch))
                              ;; resizable string
                              with term = (make-array 5 :fill-pointer 0 :adjustable t :element-type 'character)
                              while (not (eql #\q c))
                              do (progn
                                   (vector-push-extend c term)
                                   (format t "Matching ~a~%" term)
                                   (format t "~a~%" (matching-artists artists term)))
                              )
                        (format t "End of search~%")
                        ))
                 (otherwise (format t "'~a'~%" input))
                 )
               (ping mpdconn)
               )
          )
    (delwin pad)
    (disconnect mpdconn)
    )
  (endwin)
  )

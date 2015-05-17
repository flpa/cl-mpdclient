;;;; cl-mpdclient.lisp

(in-package #:cl-mpdclient)

(defparameter *conn* (connect))
(disconnect *conn*)

(now-playing *conn*)
;;(play *conn*)
;;(pause *conn*)
(status *conn*)

(ping *conn*)

;; returns list of strings like ("Artist: Amon Amarth" "Artist: Wither") ...
(list-metadata *conn* 'artist)
(length (list-metadata *conn* 'artist))

(list-metadata *conn* 'genre)
(playlist-info *conn*)
(tag-types *conn*)
(search-tracks *conn* :artist "Amon Amarth")

(defparameter *max-artists* 300)

(defparameter *async* nil)

(defparameter *pad-size* 51)
(defparameter *pad-display-size* 9)

(defun matching-artists (artists term)
  (remove-if-not #'(lambda (x)
                     (search term x)) artists)
  )


(defun floclient () 
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

(defun curse-test () 
  (let ((scr (initscr))
        (win1 (newwin 20 20 20 20)))
    (nodelay scr TRUE)
    (erase)
    (cbreak)
    (noecho)
    (mvwaddstr scr 10 2 "Type any thing to exit.")
    (mvwaddstr win1 0 0 "The window.")
    (wrefresh scr)
    (wrefresh win1)
    (delwin win1)
    (delwin scr)
    (endwin)
    ))

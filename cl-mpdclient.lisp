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

(defparameter *pad-size* 50)

(defun floclient () 
  (initscr)
  (let ((mpdconn (connect))
        (cursor-line 0)
        (scroll-index 0)
        (pad (newpad *pad-size* *pad-size*)))
    ;;    (scrollok *stdscr* TRUE)
    ;;   (idlok *stdscr* TRUE)
    ;;(setscrreg 0 100)
    (nodelay pad (if *async* TRUE FALSE))
    ;;   (cbreak)
    (cl-ncurses:clear)
    (noecho)
    (loop for artist in (subseq (list-metadata mpdconn 'artist) 0 *max-artists*)
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
               (prefresh pad scroll-index 0 3 3 14 14)
               (when *async* (sb-unix:nanosleep 0 100))
               (case (code-char input)
                 (#\j (cl-ncurses:move (incf cursor-line) 0))
                 (#\k (cl-ncurses:move (decf cursor-line) 0))
                 (#\P (pause mpdconn))
                 (otherwise (format t "'~a'~%" input))
                 )
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

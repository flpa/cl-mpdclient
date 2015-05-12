;;;; cl-mpdclient.lisp

(in-package #:cl-mpdclient)

(defparameter *conn* (connect))
(disconnect *conn*)

(now-playing *conn*)
;;(play *conn*)
;;(pause *conn*)
(status *conn*)

(ping *conn*)

;; returns list of strings like ("Amon Amarth" "Wither") ...
(list-metadata *conn* 'artist)
;;returns niL?
(mpd::parse-list (list-metadata *conn* 'artist))

(list-metadata *conn* 'genre)
(playlist-info *conn*)
(tag-types *conn*)
(search-tracks *conn* :artist "Amon Amarth")


(defun curse-test () 
  (let ((scr (initscr))
        (win1 (newwin 10 10 10 10)))
    (nodelay scr TRUE)
    (erase)
    (cbreak)
    (noecho)
    (mvwaddstr scr 10 2 "Type any thing to exit.")
    (mvwaddstr win1 0 0 "The window.")
    (wrefresh scr)
    (wrefresh win1)
    (loop for input = (getch) 
          while (not (eql (char-code #\q) input))
          do (sb-unix:nanosleep 0 100)
          if (not (eql ERR input))
          do (format t "'~a'~%" input))
    (delwin win1)
    (delwin scr)
    (endwin)
    (refresh)
    ))

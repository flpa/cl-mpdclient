;;;; cl-mpdclient.lisp

(in-package #:cl-mpdclient)

(defun firstn (list n)
  (if (< (length list) n)
    list
    (butlast list (- (length list) n))))

(defparameter *conn* (connect))
(disconnect *conn*)

(now-playing *conn*)
;;(play *conn*)
;;(pause *conn*)
(status *conn*)

(ping *conn*)

;; returns list of strings like ("Amon Amarth" "Wither") ...


(list-metadata *conn* 'artist)
(length (list-metadata *conn* 'artist))
;;returns niL?
(mpd::parse-list (list-metadata *conn* 'artist))

(list-metadata *conn* 'genre)
(playlist-info *conn*)
(tag-types *conn*)
(search-tracks *conn* :artist "Amon Amarth")

(defparameter *max-artists* 40)

(defun floclient () 
  (let ((scr (initscr))
        (mpdconn (connect)))
    (nodelay scr TRUE)
    (cbreak)
    (noecho)
    (loop for artist in (firstn (list-metadata mpdconn 'artist) *max-artists*)
          for i from 10
          do 
          (mvwaddstr scr i 2 artist))
    (loop for input = (getch) 
          while (not (eql (char-code #\q) input))
          do (sb-unix:nanosleep 0 100)
          if (not (eql ERR input))
          do (format t "'~a'~%" input))
    (wrefresh scr)
    (endwin)
    (disconnect mpdconn)
    ))

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

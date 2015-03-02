;;;; cl-mpdclient.lisp

(in-package #:cl-mpdclient)

(defparameter *conn* (connect))

;; caused error related to keyword :albumartist?
(now-playing *conn*)
(play *conn*)
(pause *conn*)

(let ((scr (initscr))
      (win1 (newwin 18 13 4 19)))
  (nodelay scr FALSE)
  (erase)
  (cbreak)
  (noecho)
  (mvwaddstr scr 23 2 "Type any thing to exit.")
  (getch)
  (wrefresh scr)
  (delwin win1)
  (endwin)
  )




;;;; package.lisp

(defpackage #:cl-mpdclient
  (:use #:cl
        #:mpd
        #:cl-ncurses)
  (:shadowing-import-from #:cl-ncurses :clear :move))

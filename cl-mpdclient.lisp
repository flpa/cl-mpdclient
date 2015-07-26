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

(defun fetch-albums (artist mpdconn)
  (mapcar #'(lambda (x) (subseq x 7)) (list-metadata mpdconn 'album 'artist artist)))

(defun fetch-now-playing (conn)
  (let ((track (now-playing conn)))
    (if (title track)
      (format nil "~a by ~a" (title track) (artist track))
      ;;TODO: remove directory name(s)
      (format nil "~a" (file track)))))

(defun update-albums (mpdconn pad artist)
  (wclear pad)
  (loop for album in (fetch-albums artist mpdconn)
        for i from 0
        do (mvwaddstr pad i 0 album)))

(defun floclient () 
  (initscr)
  (let* ((mpdconn (connect))
         (cursor-line 0)
         (scroll-index 0)
         (lines (- *LINES* 4))
         (artists-width (floor (/ *COLS* 3)))
         (stdout nil)
         (artists (fetch-artists mpdconn))
         (pad (newpad (length artists) 30))
         ;;no more than 20 albums
         (albumpad (newpad 20 30))
         (searching nil)
         (term (make-array 5 :fill-pointer 0 :adjustable t :element-type 'character)))
    (nodelay pad (if *async* TRUE FALSE))
    (halfdelay 10)
    (cl-ncurses:clear)
    (noecho)
    ;;(curs-set 0) ;; hide cursor
    (loop for artist in artists
          for i from 0
          do (mvwaddstr pad i 0 artist))
    (dotimes (i 10)
      (mvwaddstr albumpad i 0 "abc") 
      )
    ;;(attroff A_REVERSE)
    ;;(wattron pad A_REVERSE)
    ;;(mvwaddstr pad cursor-line 0 "abc")
    ;;(wattroff pad A_REVERSE)
    (cl-ncurses:move cursor-line 0)
    (printw "j/k to navigate, P to pause MPD, c to clear, [Enter] to play first song of artist, q to quit. You may need to press j now to see anything.")
    (prefresh pad scroll-index 0 1 0 lines artists-width)
    (refresh)
    (loop for input = (getch) 
          for status = (status mpdconn)
          for song-elapsed = (first (duration status))
          for song-duration = (second (duration status))
          for artist = (nth (1+ cursor-line) artists)
          do (progn
               ;;print duration
               (dotimes (i *COLS*)
                 (mvprintw (- *LINES* 3) i "-"))
               (attron A_BOLD)
               (dotimes (i (floor (* *COLS* (/ song-elapsed
                                               song-duration))))
                 (mvprintw (- *LINES* 3) i "="))
               (mvprintw (- *LINES* 2) 0 "Playing: "); should say pause
               (attroff A_BOLD)
               ;;           width of 'playing'
               (mvprintw (- *LINES* 2) 9 (format nil "~a    ~a/~a" 
                                                 (fetch-now-playing mpdconn)
                                                 song-elapsed
                                                 song-duration))
               ;;print search term
               (mvprintw (- *LINES* 1) 0 (format nil "~a" term))
               (cl-ncurses:move cursor-line 0)
               ;;change attributes of line, not available?
               ;;(chgat cursor-line 0)
               (unless (eql ERR input)
                 (prefresh pad scroll-index 0 1 0 lines artists-width)
                 (prefresh albumpad 0 0 1 artists-width lines (* 2 artists-width))
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
                     (#\Newline
                      ;;do it!
                      )
                     (otherwise (vector-push-extend (code-char input) term)))
                   (case (code-char input)
                     (#\q (return))
                     ;;limit on lower bound
                     (#\j (progn
                            (if (= cursor-line lines)       
                              (incf scroll-index)
                              (cl-ncurses:move (1+ (incf cursor-line)) 0)))
                      (update-albums mpdconn albumpad (nth (1+ cursor-line) artists)))
                     (#\k (progn
                            (if (zerop cursor-line)       
                              (decf scroll-index)
                              (cl-ncurses:move (1+ (decf cursor-line)) 0)))
                      (update-albums mpdconn albumpad (nth (1+ cursor-line) artists)))
                     (#\P (pause mpdconn))
                     (#\t ;; should be 'gg'
                      (progn 
                        (setf scroll-index 0)
                        (prefresh pad scroll-index 0 1 0 lines artists-width)
                        (cl-ncurses:move (setf cursor-line 1) 0)))
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
    (delwin albumpad)
    (disconnect mpdconn))
  (endwin))

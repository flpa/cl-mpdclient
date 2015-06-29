(defparameter *conn* (connect))
(disconnect *conn*)

(artist (now-playing *conn*))
(title (now-playing *conn*))
(file (now-playing *conn*))



;;(play *conn*)
;;(pause *conn*)
(duration (status *conn*))
(song (status *conn*))
(songid (status *conn*))
(playlist-version (status *conn*))

(ping *conn*)

(mpd:clear *conn*)

(add *conn* "Amon Amarth")

;; returns list of strings like ("Artist: Amon Amarth" "Artist: Wither") ...
(list-metadata *conn* 'artist)
(list-metadata *conn* 'album 'artist "Death")
;; doesn't like blanks?
(list-metadata *conn* 'album 'artist "Blind Guardian")
(length (list-metadata *conn* 'artist))

(list-metadata *conn* 'genre)
(playlist-info *conn*)
(tag-types *conn*)
(search-tracks *conn* :artist "Amon Amarth")
(search-tracks *conn* :artist "Death")
(find-tracks *conn* :artist "Death")
(add *conn* (first (search-tracks *conn* :artist "Amon Amarth")))




(defparameter *conn* (connect))
(disconnect *conn*)

(now-playing *conn*)
;;(play *conn*)
;;(pause *conn*)
(duration (status *conn*))

(ping *conn*)

(mpd:clear *conn*)

(add *conn* "Amon Amarth")

;; returns list of strings like ("Artist: Amon Amarth" "Artist: Wither") ...
(list-metadata *conn* 'artist)
(length (list-metadata *conn* 'artist))

(list-metadata *conn* 'genre)
(playlist-info *conn*)
(tag-types *conn*)
(search-tracks *conn* :artist "Amon Amarth")
(search-tracks *conn* :artist "Death")
(find-tracks *conn* :artist "Death")
(add *conn* (first (search-tracks *conn* :artist "Amon Amarth")))


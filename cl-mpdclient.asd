;;;; cl-mpdclient.asd

(asdf:defsystem #:cl-mpdclient
  :serial t
  :description "Describe cl-mpdclient here"
  :author "Florian Patzl"
  :license "BSD"
  :depends-on (#:mpd)
  :components ((:file "package")
               (:file "cl-mpdclient")))


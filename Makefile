all: .quicklisp-manifest.txt
	/usr/local/bin/buildapp --manifest-file .quicklisp-manifest.txt --load-system cl-mpdclient --load cl-mpdclient.lisp --entry cl-mpdclient:floclient --output eminempp

.quicklisp-manifest.txt:
	sbcl --no-userinit --no-sysinit --non-interactive --load ~/quicklisp/setup.lisp --eval '(ql:quickload "drakma")' --eval '(ql:write-asdf-manifest-file ".quicklisp-manifest.txt")'	

EXECUTABLE=eminempp

all: .quicklisp-manifest.txt
	/usr/local/bin/buildapp --manifest-file .quicklisp-manifest.txt --asdf-path . --load-system cl-mpdclient --load cl-mpdclient.lisp --entry cl-mpdclient:main --output ${EXECUTABLE}

run: all
	./${EXECUTABLE}

.quicklisp-manifest.txt:
	sbcl --no-userinit --no-sysinit --non-interactive --load ~/quicklisp/setup.lisp --eval '(ql:quickload "cl-ncurses")' --eval '(ql:quickload "mpd")' --eval '(ql:write-asdf-manifest-file ".quicklisp-manifest.txt")'	

clean:
	rm -f .quicklisp-manifest.txt

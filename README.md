# cl-mpdclient
An attempt at partially reimplementing *ncmcpp* in Common Lisp, while also adapting some aspects to my own preferences:
- More Vim-like keybindings (e.g. changing colums in the media library using h/l)
- Incremental search behaviour like in Vim
- Being able to escape search and similar via ESC
    
To some extent it's also an experiment how to build terminal applications using Common Lisp.

## Status
cl-mpdclient is far from being a useful mpdclient. 
Some basic features are kind of working: 
A list of artists is displayed, scrolling them via j/k fetches a list of albums. 
Playback can be paused via 'P', the current song and progress is shown at the bottom.
A Makefile is used to build the application, but there are some dependencies which require fiddling around a bit.

NAME=bibget
PREFIX?=/usr/local
INSTALL?=install

.PHONY: all install

all:
	perl -c $(NAME).pl

install:
	install $(NAME).pl $(PREFIX)/bin/$(NAME)

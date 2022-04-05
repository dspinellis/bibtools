BIBGET=bibget
BIBTAGS=bibtags

PREFIX?=/usr/local
INSTALL?=install

.PHONY: all install

all:
	perl -c $(BIBGET).pl
	sh -n $(BIBTAGS).sh

install:
	install $(BIBGET).pl $(PREFIX)/bin/$(BIBGET)
	install $(BIBTAGS).sh $(PREFIX)/bin/$(BIBTAGS)

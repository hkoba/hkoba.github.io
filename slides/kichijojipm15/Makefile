GENERATOR := ../../scripts/gen-revealjs.pl

HTMLS := $(patsubst %.md,%.html,$(wildcard *.md))

all: $(HTMLS)

loop:
	while inotifywait index.md; do make; done

%.html: %.md
	$(GENERATOR) -r -o $@ $^

GENERATOR := ../../scripts/gen-revealjs.pl

HTMLS := $(patsubst %.md,%.html,$(wildcard *.md))

all: $(HTMLS)

%.html: %.md
	$(GENERATOR) -r -o $@ $^

loop:
	while inotifywait .; do make; done

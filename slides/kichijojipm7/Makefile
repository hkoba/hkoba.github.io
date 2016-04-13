GENERATOR := ../../scripts/genreval.pl

HTMLS := $(patsubst %.md,%.html,$(wildcard *.md))

all: $(HTMLS)

%.html: %.md
	$(GENERATOR) -o $@ $^

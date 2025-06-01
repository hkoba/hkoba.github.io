GENERATOR := marp

HTMLS := $(patsubst %.md,%.html,$(wildcard *.md))
PDFS := $(patsubst %.md,%.pdf,$(wildcard *.md))
JPGS := $(patsubst %.md,%.jpg,$(wildcard *.md))

all: $(HTMLS) $(PDFS) $(JPGS)

loop:
	while inotifywait index.md; do make; done

%.html: %.md
	$(GENERATOR) --allow-local-files -o $@ $^

%.pdf: %.md
	$(GENERATOR) --allow-local-files -o $@ $^

%.jpg: %.md
	$(GENERATOR) --image=jpg --allow-local-files -o $@ $^

%.png: %.md
	$(GENERATOR) --image=png --allow-local-files -o $@ $^

server:
	marp -p --server --allow-local-files .

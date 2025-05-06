GENERATOR := marp

PDFS := $(patsubst %.md,%.pdf,$(wildcard *.md))

all: $(PDFS)

loop:
	while inotifywait index.md; do make; done

%.pdf: %.md
	$(GENERATOR) --allow-local-files -o $@ $^

%.png: %.md
	$(GENERATOR) --image=png --allow-local-files -o $@ $^

server:
	marp -p --server --allow-local-files .

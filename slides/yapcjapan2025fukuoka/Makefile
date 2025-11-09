GENERATOR := marp

HTMLS := $(patsubst %.md,%.html,$(wildcard *.md))

all: $(HTMLS)

loop:
	while inotifywait index.md; do make; done

%.html: %.md
	$(GENERATOR) -o $@ $^

%.png: %.md
	$(GENERATOR) --image=png --allow-local-files -o $@ $^

server:
	marp -p --server --allow-local-files .

#!/bin/zsh

emulate -L zsh

set -e

binDir=$(cd $0:h && print $PWD)

siteDir=$binDir:h
siteName=$siteDir:t

thisLoc=${PWD##$siteDir}
url=https://$siteName$thisLoc/

function tsv {
    print -- ${(j/\t/)argv}
}

function read_title {
    local fn=$1
    perl -ne '
       last if /^[-_]{3,}/;
       s/^\#+\s*// or next;
       s/<[^>]+>//g;
       chomp;
       print;
   ' $fn
}

{
    tsv type article
    tsv url $url
    tsv title "$(read_title index.md)"
    tsv image $url
    tsv description ''
} | tee index.og.tsv


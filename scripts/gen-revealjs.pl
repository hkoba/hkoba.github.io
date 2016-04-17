#!/usr/bin/env perl
use strict;
use warnings;
use autodie;
use Carp;

use Getopt::Long;

sub section (&@);
sub md_section (&);

sub usage {
  die <<END;
Usage: $0 slide.md
END
}

{
  GetOptions("r|revealup-compat", \ (my $o_revealup_compat)
	     , "o=s", \ (my $o_outfn)
	   )
    or usage();

  usage() unless @ARGV;

  my $template = do {local $/; <DATA>};
  $template =~ s/&yatt:theme;/beige/;
  my ($top, $bottom) = split /__SUBST__/, $template, 2;

  my ($sect, $subsect) = do {
    if ($o_revealup_compat) {
      qw(--- ___);
    } else {
      qw(==== ----);
    }
  };

  my $tmpfn = "$o_outfn.tmp$$";
  if ($o_outfn) {
    open STDOUT, '>', $tmpfn;
  }

  local $/;
  print $top;
  while (<>) {
    foreach (split /\n\n+$sect*\n\n+/) {
      my @subsects = split /\n\n+$subsect*\n\n+/;
      if (@subsects >= 2) {
	section {
	  md_section { ensure_nl(); print } for @subsects;
	};
      } else {
	md_section { ensure_nl(); print };
      }
    }
  }
  print $bottom;

  if ($o_outfn) {
    rename $tmpfn, $o_outfn;
  }
}

sub section (&@) {
  my ($code, @atts) = @_;
  print "<section",join("",map {" $_"} @atts).">\n";
  $code->();
  print "</section>\n";
}

sub md_section (&) {
  my ($code) = @_;
  section {
    print "<script type='text/template'>\n";
    $code->();
    print "</script>\n";
  } "data-markdown";
}

sub ensure_nl {
  s/\n*\z/\n/;
}

__END__
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <link rel="stylesheet" href="/revealjs/css/reveal.css">
    <link rel="stylesheet" href="/revealjs/css/theme/&yatt:theme;.css" id="theme">
    <link rel="stylesheet" href="/revealjs/lib/css/zenburn.css">
    <!-- If the query includes 'print-pdf', use the PDF print sheet -->
    <script>
      document.write( '<link rel="stylesheet" href="/revealjs/css/print/' + ( window.location.search.match( /print-pdf/gi ) ? 'pdf' : 'paper' ) + '.css" type="text/css" media="print">' );
    </script>
    <!--[if lt IE 9]>
      <script src="/revealjs/lib/js/html5shiv.js"></script>
    <![endif]-->
    <style>
    .reveal h2, .reveal h3, .reveal h4, .reveal h5 {text-transform: none;}
    .reveal a {color: #BB1515;}
    .reveal a:hover {color: #0a8624;}
    .reveal section img {border-width: 0px;}
       .reveal li { margin-bottom: .5ex; }
       .reveal code {
           background: #0e1560;
           color: #32f33b;
           padding: 0 .5ex;
           border-radius: .3ex;
	   text-transform: none;
	 }
         .reveal h2 code { font-size: 60%; }
    </style>
  </head>

  <body>
    <div class="reveal">
      <div class="slides">
__SUBST__
      </div>
    </div>

    <script src="/revealjs/lib/js/head.min.js"></script>
    <script src="/revealjs/js/reveal.js"></script>

    <script>
      Reveal.initialize({
        width: 960,
        height: 700,
        controls: true,
        progress: true,
        history: true,
        center: true,
        theme: Reveal.getQueryHash().theme, // available themes are in /css/theme
        transition: Reveal.getQueryHash().transition || 'default', // default/cube/page/concave/zoom/linear/fade/none
        // Optional libraries used to extend on reveal.js
        dependencies: [
          { src: '/revealjs/lib/js/classList.js', condition: function() { return !document.body.classList; } },
          { src: '/revealjs/plugin/markdown/marked.js', condition: function() { return !!document.querySelector( '[data-markdown]' ); } },
          { src: '/revealjs/plugin/markdown/markdown.js', condition: function() { return !!document.querySelector( '[data-markdown]' ); } },
          { src: '/revealjs/plugin/highlight/highlight.js', async: true, callback: function() { hljs.initHighlightingOnLoad(); } },
          { src: '/revealjs/plugin/zoom-js/zoom.js', async: true, condition: function() { return !!document.body.classList; } },
          { src: '/revealjs/plugin/notes/notes.js', async: true, condition: function() { return !!document.body.classList; } }
        ]
      });
    </script>
  </body>
</html>


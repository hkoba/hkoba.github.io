#!/usr/bin/env perl
use strict;
package Cat {

   use fields qw/name birth_year/; # field declaration

   sub new {
      my Cat $self = fields::new(shift); #  my TYPE $sport.
      $self->{name}       = shift; # Checked!
      $self->{birth_year} = shift  # Checked!
         // $self->_this_year;
      $self;
   }

   sub age {
      my Cat $self = shift;
      return $self->_this_year
                - $self->{birth_year}; # Checked!
   }

   sub _this_year { (localtime)[5] + 1900 }
};

my @cats = map {Cat->new(split ":", $_, 2)} @ARGV ? @ARGV : qw/Daisy:2010/;

foreach my Cat $cat (@cats) {

   print $cat->{name}, ": ", $cat->age, "\n";

   # print $cat->{namae}, "\n"; # Compilation error!
}

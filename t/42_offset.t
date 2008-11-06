#!/usr/bin/perl

# 2003-04-09 Tels: test the offset method from 0.94

use Test::More 'no_plan';
use strict;
use File::Spec;

use POSIX 'SEEK_SET';
my $file = "tf$$.txt";

BEGIN
  {
  $| = 1;
  if ($ENV{PERL_CORE})
    {
    # testing with the core distribution
    @INC = ( File::Spec->catdir(File::Spec->updir, 't', 'lib') );
    }
  unshift @INC, File::Spec->catdir(File::Spec->updir, 'lib');
  chdir 't' if -d 't';
  print "# INC = @INC\n";
  }

SKIP: {

eval {require Tie::File::FixedRecLen};
skip "cannot use Tie::File::FixedRecLen with your version of Tie::File"
    if $@;

$/ = "#";	# avoid problems with \n\r vs. \n

my @a;
my $o = tie @a, 'Tie::File::FixedRecLen', $file, record_length => 10, pad_char => '.', autodefer => 0;

is (ref($o), 'Tie::File::FixedRecLen');

is ($o->offset(0), 0, 'first one always there');
is ($o->offset(1), undef, 'no offsets yet');

$a[0] = 'Bourbon';
is ($o->offset(0), 0, 'first is ok');
is ($o->offset(1), 11, 'and second ok');
is ($o->offset(2), undef, 'third undef');

$a[1] = 'makes';
is ($o->offset(0), 0, 'first is ok');
is ($o->offset(1), 11, 'and second ok');
is ($o->offset(2), 22, 'and third ok');
is ($o->offset(3), undef, 'fourth undef');

$a[2] = 'the baby';
is ($o->offset(0), 0, 'first is ok');
is ($o->offset(1), 11, 'and second ok');
is ($o->offset(2), 22, 'and third ok');
is ($o->offset(3), 33, 'and fourth ok');
is ($o->offset(4), undef, 'fourth undef');

$a[3] = 'grin';
is ($o->offset(0), 0, 'first is ok');
is ($o->offset(1), 11, 'and second ok');
is ($o->offset(2), 22, 'and third ok');
is ($o->offset(3), 33, 'and fourth ok');
is ($o->offset(4), 44, 'and fifth ok');

$a[4] = '!';
is ($o->offset(5), 55, 'and fifth ok');
$a[3] = 'water';
is ($o->offset(4), 44, 'and fourth changed ok');
is ($o->offset(5), 55, 'and fifth ok');


END {
  undef $o;
  untie @a;
  1 while unlink $file;
}
}

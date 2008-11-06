#!/usr/bin/perl
#
# Unit tests of _twrite function
#
# _twrite($self, $data, $pos, $len)
#
# 't' here is for 'tail'.  This writes $data at absolute position $pos
# in the file, overwriting exactly $len of the bytes at that position.
# Everything else is moved down or up, dependong on whether
# length($data) > $len or length($data) < $len.
# $len == 0 is a pure insert; $len == length($data) is a simple overwrite.
#

my $file = "tf$$.txt";

print "1..181\n";

my $N = 1;
BEGIN {
    eval {require Tie::File::FixedRecLen};

    if ($@) {
      print "1..0 # skipped... cannot use Tie::File::FixedRecLen with your version of Tie::File
";
      exit;
    }
}

print "ok $N\n"; $N++;

$: = Tie::File::_default_recsep();

# (2) Peter Scott sent this one.  It fails in 0.51 and works in 0.90
# <4.3.2.7.2.20020331102819.00b913d0@shell2.webquarry.com>
#
# The problem was premature termination in the inner loop
# because you had $more_data scoped *inside* the block instead of outside.
# 20020331
open F, "> $file" or die "Couldn't open $file: $!";
binmode F;
for (1 .. 100) {
  print F 'a'x150, $: ;
}
close F;
# The file is now 15100 characters long on Unix, 15200 on Win32
die -s $file unless -s $file == 15000 + 100 * length($:);

tie my @lines, 'Tie::File::FixedRecLen', $file, record_length => 150, pad_char => '.' or die $!;
push @lines, "1001 ".('a' x 100);
splice @lines, 0, 1;
untie @lines;

my $s = -s $file;
my $x = 15000 + 100 * length($:);
print $s == $x
  ? "ok $N\n" : "not ok $N # expected $x, got $s\n";
$N++;

my @subtests = qw(x <x x> x><x <x> <x><x x><x> <x><x> <x><x><x> 0);

# (3-73) These were generated by 'gentests.pl' to cover all possible cases
# (I hope)
# Legend:
#         x: data is entirely contained within one block
#        x>: data runs from the middle to the end of the block
#        <x: data runs from the start to the middle of the block
#       <x>: data occupies precisely one block
#      x><x: data overlaps one block boundary
#     <x><x: data runs from the start of one block into the middle of the next
#     x><x>: data runs from the middle of one block to the end of the next
#    <x><x>: data occupies two blocks exactly
# <x><x><x>: data occupies three blocks exactly
#         0: data is null
#
# For each possible alignment of the old and new data, we investigate
# up to three situations: old data is shorter, old and new data are the
# same length, and new data is shorter.
#
# try($pos, $old, $new) means to run a test where the data starts at 
# position $pos, the old data has length $old,
# and the new data has length $new.
try( 9659,  6635,  6691);  # old=x        , new=x        ; old < new
try( 8605,  2394,  2394);  # old=x        , new=x        ; old = new
try( 9768,  1361,   664);  # old=x        , new=x        ; old > new
try( 9955,  6429,  6429);  # old=x>       , new=x        ; old = new
try(10550,  5834,  4123);  # old=x>       , new=x        ; old > new
try(14580,  6158,   851);  # old=x><x     , new=x        ; old > new
try(13442, 11134,  1572);  # old=x><x>    , new=x        ; old > new
try( 8394,     0,  5742);  # old=0        , new=x        ; old < new
try( 8192,  2819,  6738);  # old=<x       , new=<x       ; old < new
try( 8192,   514,   514);  # old=<x       , new=<x       ; old = new
try( 8192,  2196,   858);  # old=<x       , new=<x       ; old > new
try( 8192,  8192,  8192);  # old=<x>      , new=<x       ; old = new
try( 8192,  8192,  1290);  # old=<x>      , new=<x       ; old > new
try( 8192, 10575,  6644);  # old=<x><x    , new=<x       ; old > new
try( 8192, 16384,  5616);  # old=<x><x>   , new=<x       ; old > new
try( 8192, 24576,  6253);  # old=<x><x><x>, new=<x       ; old > new
try( 8192,     0,  6870);  # old=0        , new=<x       ; old < new
try( 8478,  6259,  7906);  # old=x        , new=x>       ; old < new
try( 9965,  6419,  6419);  # old=x>       , new=x>       ; old = new
try(16059,  6102,   325);  # old=x><x     , new=x>       ; old > new
try( 9503, 15073,  6881);  # old=x><x>    , new=x>       ; old > new
try( 9759,     0,  6625);  # old=0        , new=x>       ; old < new
try( 8525,  2081,  8534);  # old=x        , new=x><x     ; old < new
try(15550,   834,  1428);  # old=x>       , new=x><x     ; old < new
try(14966,  1668,  3479);  # old=x><x     , new=x><x     ; old < new
try(16316,  1605,  1605);  # old=x><x     , new=x><x     ; old = new
try(16093,  4074,   993);  # old=x><x     , new=x><x     ; old > new
try(14739,  9837,  9837);  # old=x><x>    , new=x><x     ; old = new
try(14071, 10505,  7344);  # old=x><x>    , new=x><x     ; old > new
try(12602,     0,  8354);  # old=0        , new=x><x     ; old < new
try( 8192,  2767,  8192);  # old=<x       , new=<x>      ; old < new
try( 8192,  8192,  8192);  # old=<x>      , new=<x>      ; old = new
try( 8192, 14817,  8192);  # old=<x><x    , new=<x>      ; old > new
try( 8192, 16384,  8192);  # old=<x><x>   , new=<x>      ; old > new
try( 8192, 24576,  8192);  # old=<x><x><x>, new=<x>      ; old > new
try( 8192,     0,  8192);  # old=0        , new=<x>      ; old < new
try( 8192,  6532, 10882);  # old=<x       , new=<x><x    ; old < new
try( 8192,  8192, 16044);  # old=<x>      , new=<x><x    ; old < new
try( 8192,  9555, 11020);  # old=<x><x    , new=<x><x    ; old < new
try( 8192,  9001,  9001);  # old=<x><x    , new=<x><x    ; old = new
try( 8192, 11760, 10274);  # old=<x><x    , new=<x><x    ; old > new
try( 8192, 16384, 10781);  # old=<x><x>   , new=<x><x    ; old > new
try( 8192, 24576,  9284);  # old=<x><x><x>, new=<x><x    ; old > new
try( 8192,     0, 12488);  # old=0        , new=<x><x    ; old < new
try( 8222,  6385, 16354);  # old=x        , new=x><x>    ; old < new
try(13500,  2884, 11076);  # old=x>       , new=x><x>    ; old < new
try(14069,  4334, 10507);  # old=x><x     , new=x><x>    ; old < new
try(14761,  9815,  9815);  # old=x><x>    , new=x><x>    ; old = new
try(10469,     0, 14107);  # old=0        , new=x><x>    ; old < new
try( 8192,  4181, 16384);  # old=<x       , new=<x><x>   ; old < new
try( 8192,  8192, 16384);  # old=<x>      , new=<x><x>   ; old < new
try( 8192, 12087, 16384);  # old=<x><x    , new=<x><x>   ; old < new
try( 8192, 16384, 16384);  # old=<x><x>   , new=<x><x>   ; old = new
try( 8192, 24576, 16384);  # old=<x><x><x>, new=<x><x>   ; old > new
try( 8192,     0, 16384);  # old=0        , new=<x><x>   ; old < new
try( 8192,  4968, 24576);  # old=<x       , new=<x><x><x>; old < new
try( 8192,  8192, 24576);  # old=<x>      , new=<x><x><x>; old < new
try( 8192, 14163, 24576);  # old=<x><x    , new=<x><x><x>; old < new
try( 8192, 16384, 24576);  # old=<x><x>   , new=<x><x><x>; old < new
try( 8192, 24576, 24576);  # old=<x><x><x>, new=<x><x><x>; old = new
try( 8192,     0, 24576);  # old=0        , new=<x><x><x>; old < new
try( 8771,   776,     0);  # old=x        , new=0        ; old > new
try( 8192,  2813,     0);  # old=<x       , new=0        ; old > new
try(13945,  2439,     0);  # old=x>       , new=0        ; old > new
try(14493,  6090,     0);  # old=x><x     , new=0        ; old > new
try( 8192,  8192,     0);  # old=<x>      , new=0        ; old > new
try( 8192, 10030,     0);  # old=<x><x    , new=0        ; old > new
try(14983,  9593,     0);  # old=x><x>    , new=0        ; old > new
try( 8192, 16384,     0);  # old=<x><x>   , new=0        ; old > new
try( 8192, 24576,     0);  # old=<x><x><x>, new=0        ; old > new
try(10489,     0,     0);  # old=0        , new=0        ; old = new

# (74-114)
# These tests all take place at the start of the file
try(    0,   771,  1593);  # old=<x       , new=<x       ; old < new
try(    0,  4868,  4868);  # old=<x       , new=<x       ; old = new
try(    0,   147,   118);  # old=<x       , new=<x       ; old > new
try(    0,  8192,  8192);  # old=<x>      , new=<x       ; old = new
try(    0,  8192,  4574);  # old=<x>      , new=<x       ; old > new
try(    0, 11891,  1917);  # old=<x><x    , new=<x       ; old > new
try(    0, 16384,  5155);  # old=<x><x>   , new=<x       ; old > new
try(    0, 24576,  2953);  # old=<x><x><x>, new=<x       ; old > new
try(    0,     0,  1317);  # old=0        , new=<x       ; old < new
try(    0,  5609,  8192);  # old=<x       , new=<x>      ; old < new
try(    0,  8192,  8192);  # old=<x>      , new=<x>      ; old = new
try(    0, 11083,  8192);  # old=<x><x    , new=<x>      ; old > new
try(    0, 16384,  8192);  # old=<x><x>   , new=<x>      ; old > new
try(    0, 24576,  8192);  # old=<x><x><x>, new=<x>      ; old > new
try(    0,     0,  8192);  # old=0        , new=<x>      ; old < new
try(    0,  6265,  9991);  # old=<x       , new=<x><x    ; old < new
try(    0,  8192, 16119);  # old=<x>      , new=<x><x    ; old < new
try(    0, 10218, 11888);  # old=<x><x    , new=<x><x    ; old < new
try(    0, 14126, 14126);  # old=<x><x    , new=<x><x    ; old = new
try(    0, 12002,  9034);  # old=<x><x    , new=<x><x    ; old > new
try(    0, 16384, 13258);  # old=<x><x>   , new=<x><x    ; old > new
try(    0, 24576, 14367);  # old=<x><x><x>, new=<x><x    ; old > new
try(    0,     0, 10881);  # old=0        , new=<x><x    ; old < new
try(    0,  6448, 16384);  # old=<x       , new=<x><x>   ; old < new
try(    0,  8192, 16384);  # old=<x>      , new=<x><x>   ; old < new
try(    0, 15082, 16384);  # old=<x><x    , new=<x><x>   ; old < new
try(    0, 16384, 16384);  # old=<x><x>   , new=<x><x>   ; old = new
try(    0, 24576, 16384);  # old=<x><x><x>, new=<x><x>   ; old > new
try(    0,     0, 16384);  # old=0        , new=<x><x>   ; old < new
try(    0,  2421, 24576);  # old=<x       , new=<x><x><x>; old < new
try(    0,  8192, 24576);  # old=<x>      , new=<x><x><x>; old < new
try(    0, 11655, 24576);  # old=<x><x    , new=<x><x><x>; old < new
try(    0, 16384, 24576);  # old=<x><x>   , new=<x><x><x>; old < new
try(    0, 24576, 24576);  # old=<x><x><x>, new=<x><x><x>; old = new
try(    0,     0, 24576);  # old=0        , new=<x><x><x>; old < new
try(    0,  6530,     0);  # old=<x       , new=0        ; old > new
try(    0,  8192,     0);  # old=<x>      , new=0        ; old > new
try(    0, 14707,     0);  # old=<x><x    , new=0        ; old > new
try(    0, 16384,     0);  # old=<x><x>   , new=0        ; old > new
try(    0, 24576,     0);  # old=<x><x><x>, new=0        ; old > new
try(    0,     0,     0);  # old=0        , new=0        ; old = new

# (115-141)
# These tests all take place at the end of the file
$FLEN = 40960;  # Force the file to be exactly 40960 bytes long
try(32768,  8192,  8192);  # old=<x>      , new=<x       ; old = new
try(32768,  8192,  4026);  # old=<x>      , new=<x       ; old > new
try(24576, 16384,  1917);  # old=<x><x>   , new=<x       ; old > new
try(16384, 24576,  3818);  # old=<x><x><x>, new=<x       ; old > new
try(40960,     0,  2779);  # old=0        , new=<x       ; old < new
try(32768,  8192,  8192);  # old=<x>      , new=<x>      ; old = new
try(24576, 16384,  8192);  # old=<x><x>   , new=<x>      ; old > new
try(16384, 24576,  8192);  # old=<x><x><x>, new=<x>      ; old > new
try(40960,     0,  8192);  # old=0        , new=<x>      ; old < new
try(32768,  8192, 10724);  # old=<x>      , new=<x><x    ; old < new
try(24576, 16384, 12221);  # old=<x><x>   , new=<x><x    ; old > new
try(16384, 24576, 15030);  # old=<x><x><x>, new=<x><x    ; old > new
try(40960,     0, 11752);  # old=0        , new=<x><x    ; old < new
try(32768,  8192, 16384);  # old=<x>      , new=<x><x>   ; old < new
try(24576, 16384, 16384);  # old=<x><x>   , new=<x><x>   ; old = new
try(16384, 24576, 16384);  # old=<x><x><x>, new=<x><x>   ; old > new
try(40960,     0, 16384);  # old=0        , new=<x><x>   ; old < new
try(32768,  8192, 24576);  # old=<x>      , new=<x><x><x>; old < new
try(24576, 16384, 24576);  # old=<x><x>   , new=<x><x><x>; old < new
try(16384, 24576, 24576);  # old=<x><x><x>, new=<x><x><x>; old = new
try(40960,     0, 24576);  # old=0        , new=<x><x><x>; old < new
try(35973,  4987,     0);  # old=x>       , new=0        ; old > new
try(32768,  8192,     0);  # old=<x>      , new=0        ; old > new
try(29932, 11028,     0);  # old=x><x>    , new=0        ; old > new
try(24576, 16384,     0);  # old=<x><x>   , new=0        ; old > new
try(16384, 24576,     0);  # old=<x><x><x>, new=0        ; old > new
try(40960,     0,     0);  # old=0        , new=0        ; old = new

# (142-181)
# These tests all take place at the end of the file
$FLEN = 42000;  # Force the file to be exactly 42000 bytes long
try(41275,   725,  4059);  # old=x        , new=x        ; old < new
try(41683,   317,   317);  # old=x        , new=x        ; old = new
try(41225,   775,   405);  # old=x        , new=x        ; old > new
try(35709,  6291,   284);  # old=x><x     , new=x        ; old > new
try(42000,     0,  2434);  # old=0        , new=x        ; old < new
try(40960,  1040,  1608);  # old=<x       , new=<x       ; old < new
try(40960,  1040,  1040);  # old=<x       , new=<x       ; old = new
try(40960,  1040,   378);  # old=<x       , new=<x       ; old > new
try(32768,  9232,  5604);  # old=<x><x    , new=<x       ; old > new
try(42000,     0,  6637);  # old=0        , new=<x       ; old < new
try(41022,   978,  8130);  # old=x        , new=x>       ; old < new
try(39994,  2006,   966);  # old=x><x     , new=x>       ; old > new
try(42000,     0,  7152);  # old=0        , new=x>       ; old < new
try(41613,   387, 10601);  # old=x        , new=x><x     ; old < new
try(38460,  3540,  3938);  # old=x><x     , new=x><x     ; old < new
try(36725,  5275,  5275);  # old=x><x     , new=x><x     ; old = new
try(37990,  4010,  3199);  # old=x><x     , new=x><x     ; old > new
try(42000,     0,  9189);  # old=0        , new=x><x     ; old < new
try(40960,  1040,  8192);  # old=<x       , new=<x>      ; old < new
try(32768,  9232,  8192);  # old=<x><x    , new=<x>      ; old > new
try(42000,     0,  8192);  # old=0        , new=<x>      ; old < new
try(40960,  1040, 11778);  # old=<x       , new=<x><x    ; old < new
try(32768,  9232, 13792);  # old=<x><x    , new=<x><x    ; old < new
try(32768,  9232,  9232);  # old=<x><x    , new=<x><x    ; old = new
try(32768,  9232,  8795);  # old=<x><x    , new=<x><x    ; old > new
try(42000,     0,  8578);  # old=0        , new=<x><x    ; old < new
try(41531,   469, 15813);  # old=x        , new=x><x>    ; old < new
try(39618,  2382,  9534);  # old=x><x     , new=x><x>    ; old < new
try(42000,     0, 15344);  # old=0        , new=x><x>    ; old < new
try(40960,  1040, 16384);  # old=<x       , new=<x><x>   ; old < new
try(32768,  9232, 16384);  # old=<x><x    , new=<x><x>   ; old < new
try(42000,     0, 16384);  # old=0        , new=<x><x>   ; old < new
try(40960,  1040, 24576);  # old=<x       , new=<x><x><x>; old < new
try(32768,  9232, 24576);  # old=<x><x    , new=<x><x><x>; old < new
try(42000,     0, 24576);  # old=0        , new=<x><x><x>; old < new
try(41500,   500,     0);  # old=x        , new=0        ; old > new
try(40960,  1040,     0);  # old=<x       , new=0        ; old > new
try(35272,  6728,     0);  # old=x><x     , new=0        ; old > new
try(32768,  9232,     0);  # old=<x><x    , new=0        ; old > new
try(42000,     0,     0);  # old=0        , new=0        ; old = new

sub try {
  my ($pos, $len, $newlen) = @_;
  open F, "> $file" or die "Couldn't open file $file: $!";
  binmode F;

  # The record has exactly 17 characters.  This will help ensure that
  # even if _twrite screws up, the data doesn't coincidentally
  # look good because the remainder accidentally lines up.
  my $d = substr("0123456789abcdef$:", -17);
  my $recs = defined($FLEN) ?
    int($FLEN/length($d))+1 : # enough to make up at least $FLEN
    int(8192*5/length($d))+1; # at least 5 blocks' worth
  my $oldfile = $d x $recs;
  my $flen = defined($FLEN) ? $FLEN : $recs * 17;
  substr($oldfile, $FLEN) = "" if defined $FLEN;  # truncate
  print F $oldfile;
  close F;

  die "wrong length!" unless -s $file == $flen;

  my $newdata = "-" x $newlen;
  my $expected = $oldfile;
  substr($expected, $pos, $len) = $newdata;

  my $o = tie my @lines, 'Tie::File::FixedRecLen', $file, record_length => 10, pad_char => '.' or die $!;
  $o->_twrite($newdata, $pos, $len);
  undef $o; untie @lines;

  open F, "< $file" or die "Couldn't open file $file: $!";
  binmode F;
  my $actual;
  { local $/;
    $actual = <F>;
  }
  close F;

  my ($alen, $xlen) = (length $actual, length $expected);
  unless ($alen == $xlen) {
    print "# try(@_) expected file length $xlen, actual $alen!\n";
  }
  print $actual eq $expected ? "ok $N\n" : "not ok $N\n";
  $N++;
}



use POSIX 'SEEK_SET';
sub check_contents {
  my @c = @_;
  my $x = join $:, @c, '';
  local *FH = $o->{fh};
  seek FH, 0, SEEK_SET;
#  my $open = open FH, "< $file";
  my $a;
  { local $/; $a = <FH> }
  $a = "" unless defined $a;
  if ($a eq $x) {
    print "ok $N\n";
  } else {
    ctrlfix($a, $x);
    print "not ok $N\n# expected <$x>, got <$a>\n";
  }
  $N++;

  # now check FETCH:
  my $good = 1;
  my $msg;
  for (0.. $#c) {
    my $aa = $a[$_];
    unless ($aa eq "$c[$_]$:") {
      $msg = "expected <$c[$_]$:>, got <$aa>";
      ctrlfix($msg);
      $good = 0;
    }
  }
  print $good ? "ok $N\n" : "not ok $N # $msg\n";
  $N++;

  print $o->_check_integrity($file, $ENV{INTEGRITY}) 
      ? "ok $N\n" : "not ok $N\n";
  $N++;
}

sub ctrlfix {
  for (@_) {
    s/\n/\\n/g;
    s/\r/\\r/g;
  }
}

END {
  undef $o;
  untie @a;
  1 while unlink $file;
}


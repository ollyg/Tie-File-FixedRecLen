#!/usr/bin/perl
#
# Check SPLICE function's return value
# (04_splice.t checks its effect on the file)
#

my $file = "tf$$.txt";
my $data = "rec0blahrec1blahrec2blah";
my $data2 = "......rec0blah......rec1blah......rec2blah";

print "1..50\n";

my $N = 1;
BEGIN {
    eval {require Tie::File::FixedRecLen};

    if ($@) {
      print "1..0 # skipped... cannot use Tie::File::FixedRecLen with your version of Tie::File
";
      exit;
    }
}

print "ok $N\n"; $N++;  # partial credit just for showing up

init_file($data2);

my $o = tie @a, 'Tie::File::FixedRecLen', $file, record_length => 10, pad_char => '.', autochomp => 0, recsep => 'blah';
print $o ? "ok $N\n" : "not ok $N\n";
$N++;

my $n;

# (3-12) splicing at the beginning
@r = splice(@a, 0, 0, "rec4");
check_result();
@r = splice(@a, 0, 1, "rec5");       # same length
check_result("rec4");
@r = splice(@a, 0, 1, "record5");    # longer
check_result("rec5");

@r = splice(@a, 0, 1, "r5");         # shorter
check_result("record5");
@r = splice(@a, 0, 1);               # removal
check_result("r5");
@r = splice(@a, 0, 0);               # no-op
check_result();
@r = splice(@a, 0, 0, 'r7', 'rec8'); # insert more than one
check_result();
@r = splice(@a, 0, 2, 'rec7', 'record8', 'rec9'); # insert more than delete
check_result('r7', 'rec8');

@r = splice(@a, 0, 3, 'record9', 'rec10'); # delete more than insert
check_result('rec7', 'record8', 'rec9');
@r = splice(@a, 0, 2);               # delete more than one
check_result('record9', 'rec10');


# (13-22) splicing in the middle
@r = splice(@a, 1, 0, "rec4");
check_result();
@r = splice(@a, 1, 1, "rec5");       # same length
check_result('rec4');
@r = splice(@a, 1, 1, "record5");    # longer
check_result('rec5');

@r = splice(@a, 1, 1, "r5");         # shorter
check_result("record5");
@r = splice(@a, 1, 1);               # removal
check_result("r5");
@r = splice(@a, 1, 0);               # no-op
check_result();
@r = splice(@a, 1, 0, 'r7', 'rec8'); # insert more than one
check_result();
@r = splice(@a, 1, 2, 'rec7', 'record8', 'rec9'); # insert more than delete
check_result('r7', 'rec8');

@r = splice(@a, 1, 3, 'record9', 'rec10'); # delete more than insert
check_result('rec7', 'record8', 'rec9');
@r = splice(@a, 1, 2);               # delete more than one
check_result('record9','rec10');

# (23-32) splicing at the end
@r = splice(@a, 3, 0, "rec4");
check_result();
@r = splice(@a, 3, 1, "rec5");       # same length
check_result('rec4');
@r = splice(@a, 3, 1, "record5");    # longer
check_result('rec5');

@r = splice(@a, 3, 1, "r5");         # shorter
check_result('record5');
@r = splice(@a, 3, 1);               # removal
check_result('r5');
@r = splice(@a, 3, 0);               # no-op
check_result();
@r = splice(@a, 3, 0, 'r7', 'rec8'); # insert more than one
check_result();
@r = splice(@a, 3, 2, 'rec7', 'record8', 'rec9'); # insert more than delete
check_result('r7', 'rec8');

@r = splice(@a, 3, 3, 'record9', 'rec10'); # delete more than insert
check_result('rec7', 'record8', 'rec9');
@r = splice(@a, 3, 2);               # delete more than one
check_result('record9', 'rec10');

# (33-42) splicing with negative subscript
@r = splice(@a, -1, 0, "rec4");
check_result();
@r = splice(@a, -1, 1, "rec5");       # same length
check_result('rec2');
@r = splice(@a, -1, 1, "record5");    # longer
check_result("rec5");

@r = splice(@a, -1, 1, "r5");         # shorter
check_result("record5");
@r = splice(@a, -1, 1);               # removal
check_result("r5");
@r = splice(@a, -1, 0);               # no-op  
check_result();
@r = splice(@a, -1, 0, 'r7', 'rec8'); # insert more than one
check_result();
@r = splice(@a, -1, 2, 'rec7', 'record8', 'rec9'); # insert more than delete
check_result('rec4');

@r = splice(@a, -3, 3, 'record9', 'rec10'); # delete more than insert
check_result('rec7', 'record8', 'rec9');
@r = splice(@a, -4, 3);               # delete more than one
check_result('r7', 'rec8', 'record9');

# (43) scrub it all out
@r = splice(@a, 0, 3);
check_result('rec0', 'rec1', 'rec10');

# (44) put some back in
@r = splice(@a, 0, 0, "rec0", "rec1");
check_result();

# (45) what if we remove too many records?
@r = splice(@a, 0, 17);
check_result('rec0', 'rec1');

# (46-48) Now check the scalar context return
splice(@a, 0, 0, qw(I like pie));
my $r;
$r = splice(@a, 0, 0);
print !defined($r) ? "ok $N\n" : "not ok $N \# return should have been undef\n";
$N++;

$r = splice(@a, 2, 1);
print $r eq "pieblah" ? "ok $N\n" : "not ok $N \# return should have been 'pie'\n";
$N++;

$r = splice(@a, 0, 2);
print $r eq "likeblah" ? "ok $N\n" : "not ok $N \# return should have been 'like'\n";
$N++;

# (49-50) Test default arguments
splice @a, 0, 0, (0..11);
@r = splice @a, 4;
check_result(4..11);
@r = splice @a;
check_result(0..3);

sub init_file {
  my $data = shift;
  open F, "> $file" or die $!;
  binmode F;
  print F $data;
  close F;
}

# actual results are in @r.
# expected results are in @_
sub check_result {
  my @x = @_;
  s/blah$// for @r;
  my $good = 1;

  $good = 0 unless @r == @x;
  for my $i (0 .. $#r) {
    $good = 0 unless $r[$i] eq $x[$i];
  }
  print $good ? "ok $N\n" : "not ok $N \# was (@r); should be (@x)\n";
  $N++;
}

END {
  undef $o;
  untie @a;
  1 while unlink $file;
}


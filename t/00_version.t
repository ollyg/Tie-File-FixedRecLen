#!/usr/bin/perl

print "1..1\n";

my $testversion = "1.01";

BEGIN {
    eval {require Tie::File::FixedRecLen};

    if ($@) {
      print "1..0 # skipped... cannot use Tie::File::FixedRecLen with your version of Tie::File\n";
      exit;
    }
}

if ($Tie::File::FixedRecLen::VERSION ne $testversion) {
  print STDERR "

*** WHOA THERE!!! ***

You seem to be running version $Tie::File::FixedRecLen::VERSION of the module
against version $testversion of the test suite!

None of the other test results will be reliable.
";
  exit 1;
}

print "ok 1\n";


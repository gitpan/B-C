#!./perl
my $keep_pl       = 0;	# set it to keep the src pl files
my $keep_plc      = 0;	# set it to keep the bytecode files
my $keep_plc_fail = 1;	# set it to keep the bytecode files on failures
use Config;

BEGIN {
    if ($^O eq 'VMS') {
       print "1..0 # skip - Bytecode/ByteLoader doesn't work on VMS\n";
       exit 0;
    }
    if ($ENV{PERL_CORE}){
	chdir('t') if -d 't';
	@INC = ('.', '../lib');
    } else {
	unshift @INC, 't';
	push @INC, "blib/arch", "blib/lib";
    }
    if (($Config{'extensions'} !~ /\bB\b/) ){
        print "1..0 # Skip -- Perl configured without B module\n";
        exit 0;
    }
    if ($Config{ccflags} =~ /-DPERL_COPY_ON_WRITE/) {
	print "1..0 # skip - no COW for now\n";
	exit 0;
    }
    require 'test.pl'; # for run_perl()
}
use strict;
my $debugging = ($Config{config_args} =~ m/DEBUGGING/);

undef $/;
open TEST, "< t/TESTS" or open TEST, "< TESTS";
my @tests = split /\n###+\n/, <TEST>;
close TEST;
my $numtests = $#tests+1;
$numtests++ if $debugging;

print "1..$numtests\n";

my $cnt = 1;
my $test;
my %insncov; # insn coverage
if ($debugging) {
  # either via Assembler debug, or via ByteLoader -Dl on a -DDEBUGGING perl
  use B::Asmdata q(@insn_name);
  for (0..@insn_name) { $insncov{$_} = 0; }
}

for (@tests) {
    my $got;
    my @insn;
    my ($script, $expect) = split />>>+\n/;
    $expect =~ s/\n$//;
    $test = "bytecode$cnt.pl";
    open T, ">$test"; print T $script; close T;
    $got = run_perl(switches => [ "-Mblib -MO=Bytecode,-o${test}c" ],
		    verbose  => 0, # for debugging
		    nolib    => $ENV{PERL_CORE} ? 0 : 1, # include ../lib only in CORE
		    stderr   => 1, # to capture the "bytecode.pl syntax ok"
		    progfile => $test);
    unless ($?) {
      # test coverage if -Dl is allowed
      if ($debugging) {
	my $cov = run_perl(progfile => "${test}c",  # run the .plc
			   nolib    => $ENV{PERL_CORE} ? 0 : 1,
			   stderr   => 1,
			   switches => [ "-Mblib -MByteLoader -Dv" ]);
	for (map { /\(insn (\d+)\)/ ? $1 : undef }
	     grep /\(insn (\d+)\)/, split(/\n/, $cov))
	  { $insncov{$_}++ }
      }
      $got = run_perl(progfile => "${test}c",  # run the .plc
		      nolib    => $ENV{PERL_CORE} ? 0 : 1,
		      stderr   => 1,
		      switches => [ "-Mblib -MByteLoader" ]);
      unless ($?) {
	if ($got =~ /^$expect$/) {
	  print "ok $cnt\n";
	  next;
	} else {
	  $keep_plc = $keep_plc_fail unless $keep_plc;
	  print "not ok $cnt # wanted: $expect, got: $got\n";
	  next;
	}
      }
    }
    print "not ok $cnt # wanted: $expect, \$\? = $?, got: $got\n";
} continue {
    1 while unlink($keep_pl ? () : $test, $keep_plc ? () : "${test}c");
    $cnt++;
}
# DEBUGGING coverage test:
if ($debugging) {
  my $zeros = '';
  use B::Asmdata q(@insn_name);
  for (0..$#insn_name) { $zeros .= ($insn_name[$_]."($_) ") unless $insncov{$_} };
  if ($zeros) { print "not ok ",$cnt++," # TODO no coverage for: $zeros"; }
  else { print "ok ",$cnt++," # TODO coverage unexpectetly passed";}
}
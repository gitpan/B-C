# -*- cperl -*-
# t/e_perlcc.t - after c, before i(ssue*.t) and m(modules.t)
# test most perlcc options

use strict;
use Test::More tests => 76;
use Config;

my $usedl = $Config{usedl} eq 'define';
my $X = $^X =~ m/\s/ ? qq{"$^X"} : $^X;
# TODO: no global output 'a' and 'a.c' to enable parallel testing (test speedup)
my $exe = $^O =~ /MSWin32|cygwin|msys/ ? 'pcc.exe' : './pcc';
my $a_exe = $^O =~ /MSWin32|cygwin|msys/ ? 'a.exe' : './a.out';
my $a   = $^O eq 'MSWin32' ? 'pcc.exe' : './pcc';
my $redir = $^O eq 'MSWin32' ? '' : '2>&1';
my $devnull = $^O eq 'MSWin32' ? '' : '2>/dev/null';
#my $o = '';
#$o = "-Wb=-fno-warnings" if $] >= 5.013005;
#$o = "-Wb=-fno-fold,-fno-warnings" if $] >= 5.013009;
my $perlcc = "$X -Iblib/arch -Iblib/lib blib/script/perlcc";
sub cleanup { unlink ('pcc.c','pcc.c.lst','a.out.c', "a.c", $exe, $a, "a.out.c.lst", "a.c.lst"); }
my $e = q("print q(ok)");

is(`$perlcc -S -o pcc -r -e $e $devnull`, "ok", "-S -o pcc -r -e");
ok(-e 'pcc.c', "-S => pcc.c file");
ok(-e $a, "keep pcc executable"); #3
cleanup;

is(`$perlcc -o pcc -r -e $e $devnull`, "ok", "-o pcc r -e");
ok(! -e 'pcc.c', "no pcc.c file");
ok(-e $a, "keep pcc executable"); # 6
cleanup;

my @c = <*.c>;
is(`$perlcc -r -e $e $devnull`, "ok", "-r -e"); #7
my @c1 = <*.c>;
is(length @c, length @c1, "no temp cfile");
ok(-e $a_exe, "keep default executable"); #9
cleanup;

system(qq($perlcc -o pcc -e $e $devnull));
ok(-e $a, '-o pcc -e');
is(`$a`, "ok", "$a => ok"); #11
cleanup;

# Try a simple XS module which exists in 5.6.2 and blead (test 45)
$e = q("use Data::Dumper ();Data::Dumper::Dumpxs({});print q(ok)");
is(`$perlcc -r -e $e  $devnull`, "ok", "-r xs ".($usedl ? "dynamic" : "static")); #12
cleanup;

SKIP: {
  #skip "--staticxs hangs on darwin", 10 if $^O eq 'darwin';
 TODO: {
    # fails 5.8 and darwin, msvc also
    local $TODO = '--staticxs is experimental' if $^O eq 'darwin' or $] < 5.010;
    is(`$perlcc --staticxs -r -e $e $devnull`, "ok", "-r --staticxs xs"); #13
    ok(-e $a_exe, "keep default executable"); #14
  }
  ok(! -e 'a.out.c', "delete a.out.c file without -S");
  ok(! -e 'a.out.c.lst', "delete a.out.c.lst without -S");
  cleanup;

 TODO: {
    local $TODO = '--staticxs is experimental' if $^O eq 'darwin' or $] < 5.010;
    is(`$perlcc --staticxs -S -o pcc -r -e $e  $devnull`, "ok",
       "-S -o -r --staticxs xs"); #17
    ok(-e $a, "keep executable"); #18
  }
  ok(-e 'pcc.c', "keep pcc.c file with -S");
  ok(-e 'pcc.c.lst', "keep pcc.c.lst with -S");
  cleanup;

  is(`$perlcc --staticxs -S -o pcc -O3 -r -e "print q(ok)"  $devnull`, "ok",
     "-S -o -r --staticxs without xs");
  ok(! -e 'pcc.c.lst', "no pcc.c.lst without xs"); #22
  cleanup;
}

my $f = "pcc.pl";
open F,">",$f;
print F q(print q(ok));
close F;
$e = q("print q(ok)");

is(`$perlcc -S -o pcc -r $f $devnull`, "ok", "-S -o -r file");
ok(-e 'pcc.c', "-S => pcc.c file");
cleanup;

is(`$perlcc -o pcc -r $f $devnull`, "ok", "-r -o file");
ok(! -e 'pcc.c', "no pcc.c file");
ok(-e $a, "keep executable");
cleanup;


is(`$perlcc -o pcc $f $devnull`, "", "-o file");
ok(! -e 'pcc.c', "no pcc.c file");
ok(-e $a, "executable");
is(`$a`, "ok", "./pcc => ok");
cleanup;

is(`$perlcc -S -o pcc $f $devnull`, "", "-S -o file");
ok(-e $a, "executable");
is(`$a`, "ok", "./pcc => ok");
cleanup;

is(`$perlcc -Sc -o pcc $f $devnull`, "", "-Sc -o file");
ok(-e 'pcc.c', "pcc.c file");
ok(! -e $a, "-Sc no executable, compile only");
cleanup;

is(`$perlcc -c -o pcc $f $devnull`, "", "-c -o file");
ok(-e 'pcc.c', "pcc.c file");
ok(! -e $a, "-c no executable, compile only"); #40
cleanup;

#SKIP: {
TODO: {
  #skip "--stash hangs < 5.12", 3 if $] < 5.012; #because of DB?
  #skip "--stash hangs >= 5.14", 3 if $] >= 5.014; #because of DB?
  local $TODO = "B::Stash imports too many";
  is(`$perlcc -stash -r -o pcc $f $devnull`, "ok", "old-style -stash -o file"); #41
  is(`$perlcc --stash -r -opcc $f $devnull`, "ok", "--stash -o file");
  ok(-e $a, "executable");
  cleanup;
}#}

is(`$perlcc -t -O3 -o pcc $f $devnull`, "", "-t -o file"); #44
TODO: {
  local $TODO = '-t unsupported with 5.6' if $] < 5.007;
  ok(-e $a, "executable"); #45
  is(`$a`, "ok", "./pcc => ok"); #46
}
cleanup;

is(`$perlcc -T -O3 -o pcc $f $devnull`, "", "-T -o file");
ok(-e $a, "executable");
is(`$a`, "ok", "./pcc => ok");
cleanup;

# compiler verboseness
isnt(`$perlcc --Wb=-fno-fold,-v -o pcc $f $redir`, '/Writing output/m',
     "--Wb=-fno-fold,-v -o file");
TODO: {
  local $TODO = "catch STDERR not STDOUT" if $^O =~ /bsd$/i; # fails freebsd only
  like(`$perlcc -B --Wb=-DG,-v -o pcc $f $redir`, "/-PV-/m",
       "-B -v5 --Wb=-DG -o file"); #51
}
cleanup;
is(`$perlcc -Wb=-O1 -r $f $devnull`, "ok", "old-style -Wb=-O1");

# perlcc verboseness
isnt(`$perlcc -v 1 -o pcc $f $devnull`, "", "-v 1 -o file");
isnt(`$perlcc -v1 -o pcc $f $devnull`, "", "-v1 -o file");
isnt(`$perlcc -v2 -o pcc $f $devnull`, "", "-v2 -o file");
isnt(`$perlcc -v3 -o pcc $f $devnull`, "", "-v3 -o file");
isnt(`$perlcc -v4 -o pcc $f $devnull`, "", "-v4 -o file");
TODO: {
  local $TODO = "catch STDERR not STDOUT" if $^O =~ /bsd$/i; # fails freebsd only
  like(`$perlcc -v5 $f $redir`, '/Writing output/m',
       "-v5 turns on -Wb=-v"); #58
  like(`$perlcc -v5 -B $f $redir`, '/-PV-/m',
       "-B -v5 turns on -Wb=-v"); #59
  like(`$perlcc -v6 $f $redir`, '/saving magic for AV/m',
       "-v6 turns on -Dfull"); #60
  like(`$perlcc -v6 -B $f $redir`, '/nextstate/m',
       "-B -v6 turns on -DM,-DG,-DA"); #61
}
cleanup;

# switch bundling since 2.10
is(`$perlcc -r -e$e $devnull`, "ok", "-e$e");
cleanup;
like(`$perlcc -v1 -r -e$e $devnull`, '/ok$/m', "-v1");
cleanup;
is(`$perlcc -opcc -r -e$e $devnull`, "ok", "-opcc");
cleanup;

is(`$perlcc -OSr -opcc $f $devnull`, "ok", "-OSr -o file");
ok(-e 'pcc.c', "-S => pcc.c file");
cleanup;

is(`$perlcc -Or -opcc $f $devnull`, "ok", "-Or -o file");
ok(! -e 'pcc.c', "no pcc.c file");
ok(-e $a, "keep executable");
cleanup;

# -BS: ignore -S
like(`$perlcc -BSr -opcc.plc -e $e $redir`, '/-S ignored/', "-BSr -o -e");
ok(-e 'pcc.plc', "pcc.plc file");
cleanup;

is(`$perlcc -Br -opcc.plc $f $devnull`, "ok", "-Br -o file");
ok(-e 'pcc.plc', "pcc.plc file");
cleanup;

is(`$perlcc -B -opcc.plc -e$e $devnull`, "", "-B -o -e");
ok(-e 'pcc.plc', "pcc.plc");
TODO: {
  local $TODO = 'yet unsupported 5.6' if $] < 5.007;
  is(`$X -Iblib/arch -Iblib/lib pcc.plc`, "ok", "executable plc"); #76
}
cleanup;

#TODO: -m

unlink ($f);

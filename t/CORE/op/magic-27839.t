#!./perl -w

BEGIN {
    $SIG{__WARN__} = sub { die "Dying on warning: ", @_ };
    require 't/CORE/test.pl';
}

plan(tests => 2);

use strict;

# Test for bug [perl #27839]
{
    my $x;
    sub f {
	"abc" =~ /(.)./;
	$x = "@+";
	return @+;
    };
    "pqrstuvwxyz" =~ /..(....)../; # prime @+ etc in this scope
    my @y = f();
    is $x, "@y", "return a magic array ($x) vs (@y)";

    sub f2 {
	"abc" =~ /(?<foo>.)./;
	my @h =  %+;
	$x = "@h";
	return %+;
    };
    @y = f();
    is $x, "@y", "return a magic hash ($x) vs (@y)";
}


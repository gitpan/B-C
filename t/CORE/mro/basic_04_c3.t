#!./perl

use strict;
use warnings;

require q(t/CORE/test.pl); plan(tests => 1);

=pod 

From the parrot test t/pmc/object-meths.t

 A   B A   E
  \ /   \ /
   C     D
    \   /
     \ /
      F

=cut

{
    package t::lib::A; use mro 'c3';
    package t::lib::B; use mro 'c3';
    package t::lib::E; use mro 'c3';
    package t::lib::C; use mro 'c3'; use base ('t::lib::A', 't::lib::B');
    package t::lib::D; use mro 'c3'; use base ('t::lib::A', 't::lib::E');
    package t::lib::F; use mro 'c3'; use base ('t::lib::C', 't::lib::D');
}

ok(eq_array(
    mro::get_linear_isa('t::lib::F'),
    [ qw(t::lib::F t::lib::C t::lib::D t::lib::A t::lib::B t::lib::E) ]
), '... got the right MRO for t::lib::F');  


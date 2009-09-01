use strict;
use warnings;
use Test::More tests => 5;

use MooseX::Data::Function;

my $f = MooseX::Data::Function->new(
    arity    => 2,
    function => sub { my ($a, $b) = @_; return $a + $b },
);

isa_ok $f, 'MooseX::Data::Function';

my $plus_2 = $f->apply(2);
isa_ok $plus_2, 'MooseX::Data::Function';

is $plus_2->apply(2), 4, '2 + 2 is 4';
is $plus_2->apply(3), 5, '2 + 3 is 5';

is $f->show, '(* -> * -> *)', 'stringifies ok';


use strict;
use warnings;
use Test::More tests => 8;

use MooseX::Data::Function;
use MooseX::Data::List;

my $f = MooseX::Data::Function->new(
    arity    => 2,
    function => sub { my ($a, $b) = @_; return $a + $b },
);

isa_ok $f, 'MooseX::Data::Function';

my $plus_2 = $f->(2);
isa_ok $plus_2, 'MooseX::Data::Function';

is $plus_2->(2), 4, '2 + 2 is 4';
is $plus_2->(3), 5, '2 + 3 is 5';

is $f->show, '(* -> * -> *)', 'stringifies ok';

my $listify = MooseX::Data::Function->new(
    arity    => 1,
    function => sub { MooseX::Data::List->new( list => [$_[0]] ) },
);
isa_ok $listify, 'MooseX::Data::Function';

my $double = $listify->mappend($listify);
isa_ok $listify, 'MooseX::Data::Function';

is_deeply [$double->(2)->list], [2,2], 'mappend works';

# my $doublelist = MooseX::Data::Function->mconcat($listify, $listify);
# ok $doublelist, 'creating this is ok';
# is_deeply [$doublelist->(2)->list], [2,2], 'mempty also amazingly works';

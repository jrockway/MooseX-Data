use strict;
use warnings;
use Test::More tests => 24;

use MooseX::Data::Function;
use MooseX::Data::Maybe;

my $f = MooseX::Data::Function->new(
    arity    => 1,
    function => sub { my $a = shift; "hello, $a" },
);

my $value = MooseX::Data::Maybe->Just('world');
isa_ok $value, 'MooseX::Data::Maybe';

my $hworld = $value->fmap($f);
isa_ok $hworld, 'MooseX::Data::Maybe';
is $hworld->it, 'hello, world';
is $hworld->from_maybe('...'), 'hello, world';

my $nothing = MooseX::Data::Maybe->Nothing;
my $noworld = $nothing->fmap($f);
isa_ok $noworld, 'MooseX::Data::Maybe';

ok $noworld->is_nothing, 'fmap(nothing) is nothing';
is $nothing->from_maybe('...'), '...';

my $plus = MooseX::Data::Function->new(
    arity    => 2,
    function => sub { $_[0] + $_[1] },
);

my $one = MooseX::Data::Maybe->Just(1);
my $pplus = MooseX::Data::Maybe->pure($plus);

is $pplus->ap($one)->ap($one)->from_maybe, 2, '1 + 1 = 2';

is $pplus->ap($nothing)->ap($one)->from_maybe('NOES'), 'NOES', 'Nothing + 1 = Nothing';
is $pplus->ap($one)->ap($nothing)->from_maybe('NOES'), 'NOES', '1 + Nothing = Nothing';
is $pplus->ap($nothing)->ap($nothing)->from_maybe('NOES'), 'NOES', 'Nothing + Nothing = Nothing';

is $pplus->ap(2)->ap(2)->from_maybe, 4, '2 + 2 = 4';
is $pplus->ap(2)->ap(undef)->from_maybe, undef, '2 + undef = undef';
is $pplus->ap(undef)->ap(2)->from_maybe, undef, 'undef + 2 = undef';
is $pplus->ap(undef)->ap(undef)->from_maybe, undef, 'undef + undef = undef';

my $minc = MooseX::Data::Function->new(
    arity    => 1,
    function => sub { MooseX::Data::Maybe->mreturn(1 + $_[0]) },
);

is( MooseX::Data::Maybe->mreturn(1)->bind($minc)->from_maybe(0), 2, 'bind/Just works' );
is( MooseX::Data::Maybe->Nothing->bind($minc)->from_maybe(0), 0, 'bind/Nothing works' );

my $inc = MooseX::Data::Function->new(
    arity    => 1,
    function => sub { 1 + $_[0] },
);

is $one->liftM($inc)->it, 2, 'liftM works';
is( MooseX::Data::Maybe->Nothing->liftM($inc)->from_maybe(123), 123, 'liftM works' );

my $minus = MooseX::Data::Function->new(
    arity    => 2,
    function => sub { $_[0] - $_[1] },
);

my $ten = MooseX::Data::Maybe->Just(10);
is $ten->liftM2($one, $minus)->from_maybe('fail'),
  9, 'liftM2 works';

is (
    MooseX::Data::Maybe->Nothing->liftM2($one, $minus)->from_maybe('fail'),
    'fail', 'liftM2 works',
);

is $ten->liftM2(MooseX::Data::Maybe->Nothing, $minus)->from_maybe('fail'),
  'fail', 'liftM2 works';

# test sequence

my $fran = 0;
my $sran = 0;

MooseX::Data::Maybe->Just(10)->sequence(MooseX::Data::Function->new(
    arity    => 0,
    function => sub { $fran = 1; return MooseX::Data::Maybe->Nothing }
))->sequence(MooseX::Data::Function->new(
    arity => 0,
    function => sub { $sran = 1 },
));

is $fran, 1, 'first function ran';
is $sran, 0, 'second function did not run';

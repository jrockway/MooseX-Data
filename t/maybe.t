use strict;
use warnings;
use Test::More tests => 15;

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

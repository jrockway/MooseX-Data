use strict;
use warnings;
use Test::More tests => 11;

use ok 'MooseX::Data::Error';
use MooseX::Data::Function;

my $divide = MooseX::Data::Function->new(
    arity => 1,
    function => sub {
        my ($n, $d) = @{$_[0]};
        return MooseX::Data::Error->Left( 'Divide by 0 in divide' ) if $d == 0;
        return MooseX::Data::Error->Right( $n / $d );
    },
);

my $invert = MooseX::Data::Function->new(
    arity => 1,
    function => sub {
        my $arg = shift;
        return MooseX::Data::Error->Left( 'Divide by 0 in invert' ) if $arg == 0;
        return MooseX::Data::Error->Right( 1 / $arg );
    },
);

is(MooseX::Data::Error->Right([1,2])->bind($divide)->right, 1/2, '1/2 = 1/2');
is(MooseX::Data::Error->Right([1,2])->bind($divide)->bind($invert)->right, 2, '1/(1/2) == 2');

is(MooseX::Data::Error->Right(0)->bind($invert)->left, 'Divide by 0 in invert', "can't invert");
is(MooseX::Data::Error->Right([1,0])->bind($divide)->bind($invert)->left, 'Divide by 0 in divide', "can't 1/0");

my $negate = MooseX::Data::Function->new(
    arity => 1, function => sub { my $arg = shift; return 0-$arg; },
);

# functor
is(MooseX::Data::Error->pure(42)->fmap($negate)->right, '-42',
   'fmap right works');

is(MooseX::Data::Error->Left('error')->fmap($negate)->left, 'error',
   'fmap left works');

# applicative

my $add = MooseX::Data::Function->new(
    arity => 2, function => sub { my ($a, $b) = @_; return $a + $b },
);

my $plus_two = MooseX::Data::Error->pure($add)->ap(MooseX::Data::Error->Right(2));
is $plus_two->ap(MooseX::Data::Error->Right(3))->right, 5,
  'Right 2 + Right 3 == Right 5';
is $plus_two->ap(MooseX::Data::Error->Left(3))->left, 3, 'Right 2 + Left 3 == Left 3';

is (MooseX::Data::Error->Left("Foo")->ap(MooseX::Data::Error->Right(42))->left,
    'Foo',
    '(Left Foo) $ ... == Left Foo',
);

is (MooseX::Data::Error->Right($add)->ap(MooseX::Data::Error->Left(42))->ap(MooseX::Data::Error->Right(2))->left, 42, 'f (Left 42) (Right ...) == Left 42');

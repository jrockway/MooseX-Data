use strict;
use warnings;
use Test::More tests => 5;

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

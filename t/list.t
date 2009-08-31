use strict;
use warnings;
use Test::More tests => 3;

use MooseX::Data::List;
use MooseX::Data::Function;

my $inc = MooseX::Data::Function->new( arity => 1, function => sub { $_[0] + 1 } );
#my $id  = MooseX::Data::Function->new( arity => 1, function => sub { $_[0] } );

my $list = MooseX::Data::List->new( list => [1, 2, 3] );

{
    my $plus_one = $list->fmap($inc);

    is_deeply [$plus_one->list], [2, 3, 4],
      'added one to each element';
}

{
    my $adder = MooseX::Data::List->pure($inc);
    my $plus_one = $adder->ap( $list );

    is_deeply [$plus_one->list], [2, 3, 4],
      'added one to each element';
}

{
    my $plus = MooseX::Data::Function->new(
        arity    => 2,
        function => sub { $_[0] + $_[1] },
    );

    my $sums = MooseX::Data::List->pure($plus)->
      ap( MooseX::Data::List->new( list => [1, 2, 3] ) )->
      ap( MooseX::Data::List->new( list => [2, 3, 4] ) );

    is_deeply [$sums->list], [3..5,4..6,5..7], 'added correctly';
}

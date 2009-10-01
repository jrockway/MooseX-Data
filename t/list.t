use strict;
use warnings;
use Test::More tests => 7;

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


my $plus = MooseX::Data::Function->new(
    arity    => 2,
    function => sub { $_[0] + $_[1] },
);

my $sums = MooseX::Data::List->pure($plus)->
  ap( MooseX::Data::List->new( list => [1, 2, 3] ) )->
  ap( MooseX::Data::List->new( list => [2, 3, 4] ) );

is_deeply [$sums->list], [3..5,4..6,5..7], 'added correctly';

my $minus = MooseX::Data::Function->new(
    arity    => 2,
    function => sub { $_[0] - $_[1] },
);

my $add_and_subtract = MooseX::Data::List->new( list => [
    $plus, $minus,
]);

my $sums_and_differences = $add_and_subtract->ap( $list )->ap( $list );
is_deeply [$sums_and_differences->list],
  [2,3,4,3,4,5,4,5,6,0,-1,-2,1,0,-1,2,1,0],
  'added and subtracted correctly';

# test monoid
is_deeply [MooseX::Data::List->mconcat($sums, $sums)->list],
          [map { $sums->list } 1,2],
  'monoid stuff works';

# test monad

is_deeply scalar $list->bind( MooseX::Data::Function->new(
    function => sub {
        my $x = shift;
        $list->bind( MooseX::Data::Function->new(
            function => sub {
                my $y = shift;
                MooseX::Data::List->mreturn( [$x, $y] );
            },
        )),
    },
))->list, [[1,1],[1,2],[1,3],[2,1],[2,2],[2,3],[3,1],[3,2],[3,3]], 'list as monad works';

# test monadzero

is_deeply scalar $list->bind( MooseX::Data::Function->new(
    function => sub {
        my $x = shift;
        $list->bind( MooseX::Data::Function->new(
            function => sub {
                my $y = shift;
                MooseX::Data::List->guard( $x != $y )->sequence(
                    MooseX::Data::Function->new(
                        arity   => 0,
                        function => sub {
                            MooseX::Data::List->mreturn( [$x, $y] );
                        },
                    ),
                ),
            },
        )),
    },
))->list, [[1,2],[1,3],[2,1],[2,3],[3,1],[3,2]], 'list as monadzero works';


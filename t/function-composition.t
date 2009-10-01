use strict;
use warnings;
use Test::More tests => 7;

use MooseX::Data::Function;

my ($f, $g) = map {
    my $letter = $_;
    MooseX::Data::Function->new(
        arity => 1,
        function => sub { "$letter (@_)" },
    );
} qw/f g/;

is $f->('foo'), 'f (foo)', 'f works';
is $g->('foo'), 'g (foo)', 'g works';
is $f->($g->('foo')), 'f (g (foo))', 'f(g(x)) works';
is $f->compose($g)->('foo'), 'f (g (foo))', 'f . g works';
is $f->fmap($g)->('foo'), 'f (g (foo))', 'f <$> g works';

is (MooseX::Data::Function->pure($f)->ap($g)->('foo'),
    'f (g (foo))', 'pure f <*> g == f <$> g',
);

my $lookup_point = MooseX::Data::Function->new(
    arity    => 3,
    function => sub {
        my ($grid, $x, $y) = @_;
        return $grid->[$x][$y];
    },
);

my $extract_next_x = MooseX::Data::Function->new(
    arity    => 1,
    function => sub {
        my ($grid) = @_;
        return $grid->[0][0];
    },
);

my $extract_next_y = MooseX::Data::Function->new(
    arity    => 1,
    function => sub {
        my ($grid) = @_;
        return $grid->[0][0];
    },
);

my $grid = [ [ 5,  1..5  ],
             [ 1,  6..10 ],
             [ 2, 11..15 ],
             [ 3, 16..20 ],
             [ 4, 21..25 ],
             [ 5, 26..30 ], ];

my $next = $lookup_point->ap($extract_next_x)->ap($extract_next_y)->($grid);
is $next, 30, 'got next point';


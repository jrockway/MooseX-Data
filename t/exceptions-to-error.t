use strict;
use warnings;
use Test::More tests => 10;

use MooseX::Data::Util::Error qw(try);
use MooseX::Data::Error;
use MooseX::Data::Function;

sub is_left($$;$){
    my ($got, $expected, $msg) = @_;
    ok $got->has_left, 'is left';
    like $got->left, $expected, $msg;
}

sub is_right($$;$){
    my ($got, $expected, $msg) = @_;
    ok $got->has_right, 'is right';
    is $got->right, $expected, $msg;
}

is_right try { 42 }, '42', 'got 42';
is_left  try { die 42 }, qr/^42/, 'got 42 (left)';

my $divide = sub {
    my ($a, $b) = @_;
    (try { $a / $b })->bind( sub($ ) { my $arg = shift; return try { 1 / $arg }  } );
};

is_right $divide->(1,2), 2;
is_left  $divide->(0,1), qr/Illegal division by zero/;
is_left  $divide->(1,0), qr/Illegal division by zero/;



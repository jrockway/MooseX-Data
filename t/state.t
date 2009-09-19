use strict;
use warnings;
use Test::More tests => 3;

use ok 'MooseX::Data::Function::State';

my $val = 0;

my $getter = MooseX::Data::Function::State->get->bind(
    MooseX::Data::Function::State->new(
        function => sub {
            my ($value) = @_;
            $val = $value;
            return MooseX::Data::Function::State->mreturn('it worked');
        },
    ),
);

is_deeply $getter->runState(42), ['it worked', 42], 'runState over get + identity = state';
is $val, 42, 'value is 42';

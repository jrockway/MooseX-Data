use strict;
use warnings;
use Test::More tests => 6;

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

####

my @input = (1,2,3);
my $get_input = MooseX::Data::Function::State->mreturn(shift @input);

is_deeply $get_input->runState('xxx'), [1, 'xxx'], 'got first input';

my @output;
my $print_state = MooseX::Data::Function::State->get->bind(
    MooseX::Data::Function::State->new(
        function => sub {
            my ($state) = @_;
            push @output, $state;
            return MooseX::Data::Function::State->mreturn(undef);
        },
    ),
);

$print_state->runState('test test');
is $output[0], 'test test', 'printed state';

my $result = $get_input->sequence($print_state);
$result->runState('XXX');
is $output[1], 'XXX', 'got input';

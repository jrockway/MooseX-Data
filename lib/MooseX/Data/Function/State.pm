package MooseX::Data::Function::State;
use Moose;

extends 'MooseX::Data::Function'; # always returns a (a, s) pair
with 'MooseX::Data::Monad';

has '+arity' => ( default => 1 ); # the state

sub runState {
    my ($self, $state) = @_;
    return $self->apply($state);
}

# instance Functor (State s) where
#     fmap f m = State $ \s -> let
#         (a, s') = runState m s
#         in (f a, s')

sub fmap {
    my ($m, $f) = @_;
    return $m->new(
        function => sub {
            my $state = shift;
            my $result = $m->runState($state);
            my ($a, $state2) = @$result;
            return [$f->apply($a), $state2];
        },
    );
}

# instance Monad (State s) where
#     return a = State $ \s -> (a, s)
#     m >>= k  = State $ \s -> let
#         (a, s') = runState m s
#         in runState (k a) s'

sub mreturn {
    my ($class, $a) = @_;
    return $class->new(
        function => sub { my $state = shift; return [$a, $state] },
    );
}

BEGIN { *pure = *mreturn }

sub bind {
    my ($m, $k) = @_;

    return $m->new(
        function => sub {
            my $state = shift;
            my $result = $m->runState($state);
            my ($a, $state2) = @$result;
            return $k->apply($a)->runState($state2);
        },
    );
}

# instance MonadState s (State s) where
#     get   = State $ \s -> (s, s)
#     put s = State $ \_ -> ((), s)

sub get {
    my $class = shift;
    return $class->new(
        function => sub {
            my $state = shift;
            return [$state, $state];
        },
    );
}

sub put {
    my ($class, $state) = @_;
    return $class->new(
        function => sub {
            shift;
            return [undef, $state];
        },
    );
}

1;

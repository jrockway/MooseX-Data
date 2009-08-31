package MooseX::Data::Function;
use Moose;

has 'function' => (
    is       => 'ro',
    isa      => 'CodeRef',
    required => 1,
);

has 'arity' => (
    is       => 'ro',
    isa      => 'Int',
    required => 1,
);

# TODO, don't actually apply function, save value in list.  then we
# can dump for debugging more easily

sub apply {
    my ($self, $arg) = @_;

    my $arity = $self->arity;
    if($arity == 0){
        if(!$arg){
            return $self->function->();
        }
        else {
            confess 'cannot apply arg to a function of arity 0';
        }
    }

    # sort of a special case; perl != haskell
    if($arity == 1){
        return $self->function->($arg);
    }

    # otherwise, new function
    return $self->new(
        arity    => ($arity - 1),
        function => sub {
            my @args = @_;
            $self->function->($arg, @args);
        },
    );
}

1;

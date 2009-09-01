package MooseX::Data::Function;
use Moose;

with 'MooseX::Data::Show', 'MooseX::Data::Functor::Applicative';

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

sub show {
    my $self = shift;
    return '('. (join ' -> ', ('*')x$self->arity). ' -> *)';
}

sub compose {
    my ($f, $g) = @_;

    confess 'arity of $g in $f . $g must be 1'
      unless $g->arity == 1;

    return $f->new(
        arity    => 1,
        function => sub { $f->apply($g->apply(@_)) },
    );
}

# const :: \x -> (\e -> x)
sub pure {
    my ($class, $value) = @_;

    return $class->new(
        arity    => 1,
        function => sub { $value },
    );
}

BEGIN { *fmap = *compose }

# self <*> g = \env -> (self env (g env))
sub ap {
    my ($self, $g) = @_;
    return $self->new(
        arity    => 1,
        function => sub {
            my ($env) = @_;
            return $self->apply($env)->apply($g->apply($env));
        },
    );
}

1;

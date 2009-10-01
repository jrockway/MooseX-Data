package MooseX::Data::Function;
use Moose;

with 'MooseX::Data::Show',
  # 'MooseX::Data::Monoid',
  'MooseX::Data::Functor::Applicative';

use overload fallback => 1,
  '&{}' => sub {
      my $self = shift;
      return sub {
          my @args = @_;
          $self->apply(@args);
      },
  };

has 'function' => (
    is       => 'ro',
    isa      => 'CodeRef',
    required => 1,
);

has 'arity' => (
    is         => 'ro',
    isa        => 'Int',
    lazy_build => 1,
);

sub _build_arity {
    my $self = shift;
    my $fn = prototype $self->function;
    return 1 unless defined $fn;
    return length $fn;
}

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

    # sort of a special case; perl != haskell and we want to remove
    # the "Function" wrapper around a plain value ASAP.  I think.
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
        function => sub { $f->($g->(@_)) },
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
            return $self->($env)->($g->($env));
        },
    );
}

# sub mempty {
#     my $class = shift;
#     state $id = 0;
#     $id++;
#     warn "mempty $id @_";
#     return $class->new(
#         arity => 2,
#         function => sub { warn "evaluating mempty $id @_"; $_[0]->mempty },
#     );
# }

sub mappend {
    my ($f, $g) = @_;
    return $f->new(
        arity => 1,
        function => sub {
            my ($x) = @_;
            return $f->($x)->mappend($g->($x));
        },
    );
}

1;

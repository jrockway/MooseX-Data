package MooseX::Data::Error;
use Moose;
use MooseX::Method::Signatures;

use MooseX::Types::Moose qw(Any);
use MooseX::Data::Types qw(Function Either);

has left => (
    is        => 'ro',
    isa       => Any,
    predicate => 'has_left',
);

has right => (
    is        => 'ro',
    isa       => Any,
    predicate => 'has_right',
);

sub Left {
    my $class = shift;
    my $it = shift;
    return $class->new( left => $it );
}

sub Right {
    my $class = shift;
    my $it = shift;
    return $class->new( right => $it );
}

method show {
    if($self->has_left) {
        return 'Left '. (eval { $self->left->show } || $self->left);
    }
    else {
        return 'Right '. (eval { $self->right->show } || $self->right);
    }
}

# monad

BEGIN { *mreturn = *Right }

method bind(Function $f does coerce) {
    return $self->Left($self->left) if $self->has_left;
    return $f->($self->right);
}

# functor

BEGIN { *pure = *Right }

method fmap(Function $g does coerce){
    return $self->Left($self->left) if $self->has_left;
    return $self->Right($g->($self->right));
}

method ap(Either $arg does coerce){
    return $self->Left($self->left) if $self->has_left;
    return $self->Left($arg->left) if $arg->has_left;
    return $self->Right($self->right->( $arg->right ));
}

with
  'MooseX::Data::Show',
  'MooseX::Data::Functor::Applicative',
  'MooseX::Data::Monad';

1;

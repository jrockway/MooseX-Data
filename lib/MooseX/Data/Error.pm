package MooseX::Data::Error;
use Moose;
use MooseX::Method::Signatures;

use MooseX::Types::Moose qw(Any);

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


BEGIN { *pure = *Right }
BEGIN { *mreturn = *Right }

method show {
    if($self->has_left) {
        return 'Left '. (eval { $self->left->show } || $self->left);
    }
    else {
        return 'Right '. (eval { $self->right->show } || $self->right);
    }
}

method bind($f) {
    return $self->Left($self->left) if $self->has_left;
    return $f->apply($self->right);
}

with
  'MooseX::Data::Show',
  'MooseX::Data::Monad';

1;

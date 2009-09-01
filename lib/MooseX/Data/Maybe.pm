package MooseX::Data::Maybe;
use Moose;
use MooseX::Method::Signatures;

use MooseX::Data::Types qw(Maybe Function);
use MooseX::Types::Moose qw(Any);

has it => (
    is        => 'ro',
    isa       => Any,
    predicate => 'has_it', # I HAZ IT
);

sub Nothing {
    my $class = shift;
    return $class->new();
}

sub Just {
    my $class = shift;
    my $it = shift;
    return $class->new( it => $it );
}

sub is_nothing { return !$_[0]->has_it }

method from_maybe(Any $default) {
    return $self->is_nothing ? $default : $self->it;
}

sub pure {
    goto \&Just;
}

method fmap(Function $f) {
    if($self->has_it){
        return $self->Just( $f->apply( $self->it ) );
    }
    return $self->Nothing;
}

method ap(Maybe $arg does coerce) {
    return $self->Nothing if $self->is_nothing || $arg->is_nothing;
    return $self->Just( $self->it->apply( $arg->it ) );
}

method show {
    if($self->is_nothing) {
        return 'Nothing';
    }
    else {
        return 'Just '. (eval { $self->it->show } || $self->it);
    }
}

with 'MooseX::Data::Functor::Applicative', 'MooseX::Data::Show';

1;

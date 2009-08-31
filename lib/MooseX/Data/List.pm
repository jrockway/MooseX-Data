package MooseX::Data::List;
use Moose;
use MooseX::AttributeHelpers;

with 'MooseX::Data::Functor::Applicative';

has list => (
    metaclass  => 'Collection::List',
    is         => 'ro',
    isa        => 'ArrayRef',
    auto_deref => 1,
    required   => 1,
    default    => sub { [] },
);

sub pure {
    my ($class, $value) = @_;
    return $class->new( list => [$value] );
}

sub fmap {
    my ($self, $f) = @_;
    return $self->new( list => [
        map { $f->apply($_) } $self->list,
    ]);
}

sub ap {
    my ($self, $functor) = @_;

    my @result;
    for my $elt ($self->list) {
        push @result, $functor->fmap($elt)->list;
    }

    return $self->new( list => \@result );
}

1;

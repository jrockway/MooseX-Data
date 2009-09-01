package MooseX::Data::List;
use Moose;
use MooseX::AttributeHelpers;

with 'MooseX::Data::Functor::Applicative', 'MooseX::Data::Show';

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
    my ($self, $g) = @_; # self == functor, g == function
    return $self->new( list => [
        map { $g->apply($_) } $self->list,
    ]);
}

sub ap {
    my ($self, $f) = @_; # self == functor, f == functor

    my @result;
    for my $g ($self->list) { # g == function
        push @result, $f->fmap($g)->list;
    }

    return $self->new( list => \@result );
}

sub show {
    my $self = shift;
    return '[ ' . (join ',', map { eval { $_->show } || $_ } $self->list). ' ]';
}

1;

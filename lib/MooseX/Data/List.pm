package MooseX::Data::List;
use Moose;
use MooseX::AttributeHelpers;

with 'MooseX::Data::Functor::Applicative',
  'MooseX::Data::Monoid',
  'MooseX::Data::Monad',
  'MooseX::Data::Show';

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
        map { $g->($_) } $self->list,
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

sub mempty {
    return $_[0]->new( list => [] );
}

sub mappend {
    my ($a, $b) = @_;
    return $a->new(
        list => [ $a->list, $b->list ],
    );
}

BEGIN { *mreturn = *pure }

sub bind {
    my ($self, $g) = @_;
    my $result = $self->mempty;
    $result = $result->mappend($g->($_)) for $self->list;
    return $result;
}

1;

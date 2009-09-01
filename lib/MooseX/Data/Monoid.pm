package MooseX::Data::Monoid;
use Moose::Role;

requires 'mempty';
requires 'mappend';

sub mconcat {
    my ($class, @data) = @_;

    my $result = $class->mempty;
    $result = $result->mappend($_) for @data;
    return $result;
}

1;

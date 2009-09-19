package MooseX::Data::Monad;
use Moose::Role;

requires 'mreturn';
requires 'bind';
requires 'ap';

sub sequence {
    my ($a, $b) = @_;
    return $a->bind( MooseX::Data::Function->new(
        arity => 1,
        function => sub { my $ignore = shift; $b->apply() }
    ));
}

sub liftM {
    my ($m, $f) = @_;
    my $fprime =
    return $m->bind(
        MooseX::Data::Function->new(
            arity    => 1,
            function => sub {
                my $x = shift;
                $m->mreturn(
                    $f->apply($x),
                );
            },
        ),
    );
}

sub liftM2 {
    my ($m1, $m2, $f) = @_;
    return $m1->bind(
        MooseX::Data::Function->new(
            arity    => 1,
            function => sub {
                my $x = shift;
                return $m2->bind(
                    MooseX::Data::Function->new(
                        arity => 1,
                        function => sub {
                            my $y = shift;
                            return $m2->mreturn(
                                $f->apply($x)->apply($y),
                            );
                        },
                    ),
                ),
            },
        ),
    );
}
1;

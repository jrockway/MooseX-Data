package MooseX::Data::MonadZero;
use Moose::Role;

with 'MooseX::Data::Monad';

requires 'mzero';

sub guard {
    my ($m, $condition) = @_;
    if ($condition){
        $m->mreturn(undef);
    }
    else {
        $m->mzero;
    }
}

1;

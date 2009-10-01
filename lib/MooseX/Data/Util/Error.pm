package MooseX::Data::Util::Error;
use strict;
use warnings;
use MooseX::Data::Error;
require Try::Tiny;

use Sub::Exporter -setup => {
    exports => [qw/try Left Right/],
};

# todo: curry type with S::Ex

sub Left($) {
    MooseX::Data::Error->Left(@_);
}

sub Right($) {
    MooseX::Data::Error->Right(@_);
}

sub try(&) {
    my $code = shift;
    my $retval;
    Try::Tiny::try(sub {
        $retval = Right(scalar $code->());
    }, sub {
        $retval = Left($_);
    });

    return $retval;
}

1;

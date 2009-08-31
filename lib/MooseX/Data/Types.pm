package MooseX::Data::Types;
use Moose;

use MooseX::Types -declare => [qw{
    Maybe
    Function
}];

use MooseX::Types::Moose qw(Any Undef);

class_type Maybe, { class => 'MooseX::Data::Maybe' };

coerce Maybe, from Undef, via {
    require MooseX::Data::Maybe;
    MooseX::Data::Maybe->Nothing;
};

coerce Maybe, from Any, via {
    require MooseX::Data::Maybe;
    MooseX::Data::Maybe->Just( $_ );
};

class_type Function, { class => 'MooseX::Data::Function' };

1;

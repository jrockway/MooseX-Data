package MooseX::Data::Types;
use Moose;

use MooseX::Types -declare => [qw{
    Maybe
    Either
    Function
}];

use MooseX::Types::Moose qw(Any Undef CodeRef);

class_type Maybe, { class => 'MooseX::Data::Maybe' };
class_type Either, { class => 'MooseX::Data::Error' };

coerce Maybe, from Undef, via {
    require MooseX::Data::Maybe;
    MooseX::Data::Maybe->Nothing;
};

coerce Maybe, from Any, via {
    require MooseX::Data::Maybe;
    MooseX::Data::Maybe->Just( $_ );
};

coerce Either, from Any, via {
    require MooseX::Data::Maybe;
    MooseX::Data::Error->Right( $_ );
};

class_type Function, { class => 'MooseX::Data::Function' };

coerce Function, from CodeRef, via {
    return MooseX::Data::Function->new(
        function => $_,
    );
};

1;

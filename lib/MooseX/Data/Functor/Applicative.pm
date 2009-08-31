package MooseX::Data::Functor::Applicative;
use Moose::Role;

with 'MooseX::Data::Functor::Pointed';

requires 'ap';

1;

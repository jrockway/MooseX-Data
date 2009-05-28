use MooseX::Declare;

role MooseX::Data::Comparable {
    requires 'compare_to';

    method is_equal_to($other) {
        return $self->compare_to($other) == 0;
    };

    method is_less_than($other) {
        return $self->compare_to($other) < 0;
    };

    method is_greater_than($other) {
        return $self->compare_to($other) > 0;
    };

    method is_lesser_or_equal_to($other) {
        return not $self->is_greater_than($other);
    };

    method is_greater_or_equal_to($other) {
        return not $self->is_less_than($other);
    };
}

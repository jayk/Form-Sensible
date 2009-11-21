package Form::Sensible::Field::Select;

use Moose;
extends Form::Sensible::Field;

## provides a select field - potentially with multiple selections
## this could be a dropdown box or a radio-select group

has 'accepts_multiple' => (
    is          => 'rw',
    isa         => 'Bool',
    required    => 1,
    default     => 0,
);

has 'potential_values' => (
    is          => 'rw',
    isa         => 'ArrayRef',
    required    => 1,
    default     => sub { return [] },
    lazy        => 1,
);

1;
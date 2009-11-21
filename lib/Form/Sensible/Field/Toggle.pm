package Form::Sensible::Field::Toggle;

use Moose;
extends Form::Sensible::Field;

## provides a simple on/off field

has 'on_value' => (
    is          => 'rw',
    default     => 'on',
);

has 'off_value' => (
    is          => 'rw',
    default     => 'off',
);


1;
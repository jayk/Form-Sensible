package Form::Sensible::Field::Text;

use Moose;
extends 'Form::Sensible::Field';

## provides a plain text field

has 'maximum_length' => (
    is          => 'rw',
    isa         => 'Int',
    required    => 1,
    default     => 256,
);



1;
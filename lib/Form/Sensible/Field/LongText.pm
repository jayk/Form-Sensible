package Form::Sensible::Field::LongText;

use Moose;
extends 'Form::Sensible::Field::Text';

## provides a long text field (such as a 'text area' or 'notes' box)

has 'maximum_length' => (
    is          => 'rw',
    isa         => 'Int',
    required    => 1,
    default     => 10240,
);


1;
package Form::Sensible::Field::Trigger;

use Moose;
extends Form::Sensible::Field;

## provides an action trigger

## always has an activation trigger, even if it does nothing.

has 'activation_trigger' => (
    is          => 'rw',
    isa         => 'CodeRef',
    required    => 1,
    default     => sub { return sub {}; }
);



1;
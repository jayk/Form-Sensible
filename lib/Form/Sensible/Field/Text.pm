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

sub get_additional_configuration {
    my $self = shift;
    
    return { 'maximum_length' => $self->maximum_length };    
}

1;
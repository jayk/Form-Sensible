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


sub get_additional_configuration {
    my $self = shift;
    
    return { 
                'on_value' => $self->on_value,
                'off_value' => $self->off_value
           };

}

1;
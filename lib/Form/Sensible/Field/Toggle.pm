package Form::Sensible::Field::Toggle;

use Moose; 
use namespace::autoclean;
extends 'Form::Sensible::Field';

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

sub options {
    my $self = shift;
    
    return [ map { { name => $_, value => $_ } } ($self->on_value, $self->off_value) ];
}

sub validate {
    my $self = shift;
    
    if ($self->value ne $self->on_value && $self->value ne $self->off_value) {
    
        if (exists($self->validation->{'invalid_message'})) {
            return $self->validation->{'invalid_message'};
        } else {
            return $self->display_name . " was set to an invalid value";            
        }        
    } else {
        return 0;
    }
}

__PACKAGE__->meta->make_immutable;
1;
package Form::Sensible::Field::Trigger;

use Moose; 
use namespace::autoclean;
extends 'Form::Sensible::Field';

## provides an action trigger

## always has an activation trigger, even if it does nothing.

has 'event_to_trigger' => (
    is          => 'rw',
    isa         => 'Str',
    required    => 1,
    builder     => '_default_event_name',
    lazy        => 1,
);

sub _default_event_name {
    my ($self) = @_;
    
    return $self->name . "_triggered";
}


sub get_additional_configuration {
    my $self = shift;
    
    return { 
                'event_to_trigger' => $self->event_to_trigger,
           };

}

__PACKAGE__->meta->make_immutable;
1;
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

has 'value' => (
    is          => 'rw',
    isa         => 'ArrayRef',
    required    => 1,
    default     => sub { return []; },
    lazy        => 1,
);


# overcomplicated.
#around 'value' => sub {
#    my ($self, $orig) = @_;
#    
#    return $self->$orig() unless @_;
#    
#    if ($#_ > 0) {
#        $self->$orig([ @_ ]);
#    } else {
#        my $val = shift;
#        my $original_value = $self->$orig();
#        if (ref($val) eq 'ARRAY') {
#            $self->$orig($val);
#        } else {
#            push @{$self->$orig()}, $val;
#        }
#    }
#};

sub add_selection {
    my ($self, $value) = @_;
    
    if (!$self->accepts_multiple && $#{$self->value} >= 0) {
        ## this instance doesn't accept multiple, so we replace the old value
        $self->value([$value]);
    } else {
        push @{$self->value}, $value;
    }
}

sub get_additional_configuration {
    my $self = shift;
    
    return { 
                'accepts_multiple' => $self->accepts_multiple,
                'potential_values' => $self->potential_values
           };

}

sub validate {
    my ($self) = @_;
    

    foreach my $value (@{$self->value}) {
        my $valid = 0;
        foreach my $potential_value (@{$self->potential_values}) {
            if ($value eq $potential_value) {
                $valid = 1;
                last;
            }
        }
        if (!$valid) {
            if (exists($self->validation->{'invalid_message'})) {
                return $self->validation->{'invalid_message'};
            } else {
                return $self->display_name . " was set to an invalid value";            
            }
        }
    }
    return 0;
}

1;
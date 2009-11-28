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

has 'should_truncate' => (
    is          => 'rw',
    isa         => 'Bool',
    required    => 1,
    default     => 0,
);

## does truncation if should_truncate is set.
around 'value' => sub {
    my $orig = shift;
    my $self = shift;
    
    if (@_) {
        my $value = shift;
        if ($self->should_truncate) {
            $self->$orig(substr($value,0,$self->maximum_length));
        } else {
            $self->$orig($value);
        }
    } else {
        return $self->$orig()
    }
};

sub get_additional_configuration {
    my ($self) = @_;
    
    return { 
                'maximum_length' => $self->maximum_length,
                'should_truncate' => $self->should_truncate
           };    
}

sub validate {
    my ($self) = @_;
    
    if (length($self->value) > $self->maximum_length) {
        return $self->display_name . " is too long";
    }
    return 0;
}

1;
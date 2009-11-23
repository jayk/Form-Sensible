package Form::Sensible::Validator;

use Moose;

## this module provides the basics for validation of a Form.
##
## should this be an abstract role that simply defines the interface to validators?

has 'config' => (
    is          => 'rw',
    isa         => 'HashRef',
    required    => 1,
    default     => sub { return { }; },
    lazy        => 1,
);

has 'field_messages' => (
    is          => 'rw',
    isa         => 'HashRef[ArrayRef]',
    required    => 1,
    default     => sub { return {}; },
    lazy        => 1,
);

has 'error_fields' => (
    is          => 'rw',
    isa         => 'ArrayRef',
    required    => 1,
    default     => sub { return []; },
    lazy        => 1,
    # additional options
);

sub form_is_valid {
    my $self = shift;
    
    if ($#{$self->error_fields} == -1 ) {
        return 1;
    } else {
        return 0;
    }
}

sub initialize_for_form {
    my ($self, $form) = @_;
    
    $self->reset($form);
}

sub reset {
    my ($self, $form) = @_;
    
    $self->error_fields([]);
    $self->field_messages({});
    $self->config($form->validation);
}

sub validate {
    my ($self, $form) = @_;
    
}

1;
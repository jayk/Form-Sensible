package Form::Sensible::Validator;

use Moose;
use Form::Sensible::FieldValidator::Code;
use Form::Sensible::FieldValidator::Regex;

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

has 'field_validators' => (
    is          => 'rw',
    isa         => 'HashRef[ArrayRef]',
    required    => 1,
    default     => sub { return {}; },
    lazy        => 1,
);


sub form_is_valid {
    my $self = shift;
    
    if ($#{$self->error_fields} == -1 ) {
        return 1;
    } else {
        return 0;
    }
}

## hook point for resetting validator state to process a new form.
sub reset {
    my ($self, $form) = @_;
    
    $self->error_fields([]);
    $self->field_messages({});
    $self->field_validators({});
    $self->config($form->validation);
    
    ## maybe at some future date, we make this work for arbitrary field validators
    ## my guess is, however, that anything more complex will require an external
    ## form validation module
    foreach my $fieldname ($form->fieldnames) {
        my $field = $form->field($fieldname);
        if (defined($field->validation->{'regex'})) {
            push @{$self->field_validators->{$fieldname}}, Form::Sensible::FieldValidator::Regex->new( regex => $field->validation->{'regex'});
        }
        if (defined($field->validation->{'code'})) {
            push @{$self->field_validators->{$fieldname}}, Form::Sensible::FieldValidator::Code->new( code => $field->validation->{'regex'});
        }
    }
}

# returns 0 if validation failed, or 1 if validation succeeded.
sub validate {
    my ($self, $form) = @_;
    
    ## validation follows this process: Validate each field in order, using
    ## the order provided by the form.  If all of those succeed, then proceed to 
    ## complete form validation if provided.
    
    foreach my $fieldname ($form->fieldnames) {
        my $field = $form->field($fieldname);
        if ($field->value) {
            ## field has value, so we run the field validators
            foreach my $validator (@{$self->field_validators->{$fieldname}}) {
                my $result = $validator->validate($field);
                if($result) {
                    push @{$self->error_fields}, $fieldname;
                    push @{$self->field_messages->{$fieldname}}, $result;
                }
            }
        } elsif ($field->required) {
            ## field was required but was empty.
            push @{$self->error_fields}, $fieldname;
            if (exists($field->validation->{'missing_message'})) {
                push @{$self->field_messages->{$fieldname}}, $field->validation->{'missing_message'};
            } else {
                push @{$self->field_messages->{$fieldname}}, $field->display_name . " is a required field and was not provided.";
            }
        }
    }
    
    if ($#{$self->error_fields} eq -1) {
        if (defined($self->config->{'post_field_validation'}) && ref($self->config->{'post_field_validation'}) eq 'CODE') {
            my $results = $self->config->{'post_field_validation'}->($form);
            if (scalar keys %{$results}) {
                foreach my $key (keys %{$results}) {
                    push @{$self->error_fields}, $key;
                    push @{$self->field_messages->{$key}}, @{$results->{$key}};
                }
                return 0;
            }
        }
        return 1;
    } else {
        return 0;
    }
}

1;
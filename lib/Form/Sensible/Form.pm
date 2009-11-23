package Form::Sensible::Form;

use Moose;
use Carp;

## a form is a collection of fields. Different form types will work differently.

## the Concept basically follows a flow:
##
## 1) Form is created.
## 2) Fields are created and added to the Form
## 3) Form is rendered
## 4) user takes action - filling in fields, etc.
## 5) user indicates an action (form is complete (submit) or cancelled)
## 6) If cancelled, form triggers cancel action.

## 7) if submitted - form calls validators in turn on each of it's fields (and finally a
##               'last step' validation that runs against all fields, if provided.)

## 7a) if validation fails - failed_validation action is called - most often re-render of the form with messages.

## 7b) if validation succeeds - complete_action is called.

has '_fields' => (
    is          => 'rw',
    isa         => 'HashRef[Form::Sensible::Field]',
    required    => 1,
    default     => sub { return {}; },
    lazy        => 1,
);

has 'field_order' => (
    is          => 'rw',
    isa         => 'ArrayRef[Str]',
    required    => 1,
    default     => sub { return []; },
    lazy        => 1,
);


has 'render_hints' => (
    is          => 'rw',
    isa         => 'HashRef',
    required    => 1,
    default     => sub { return {}; },
    lazy        => 1,
    # additional options
);

## validation hints - FULL form validation
## runs _after_ field validation.
has 'validation' => (
    is          => 'rw',
    isa         => 'HashRef',
    required    => 1,
    default     => sub { return {}; },
    lazy        => 1,    
);


has 'validator' => (
    is          => 'rw',
    isa         => 'Form::Sensible::Validator',
    lazy        => 1,
    builder     => '_create_validator'
);



## actions provide a simple event model - actions can
## be created on a form that cause certain things to happen
## action names are free-form and the values associated with them
## are arrayrefs of code refs.  The internally used triggers are:
##
## form_completed   - defaults to calling validation routines
## form_cancelled   - defaults to doing nothing
## validation_passed - validation succeeded
## validation_failed - validation failed

has 'actions' => (
    is          => 'rw',
    isa         => 'HashRef',
    required    => 1,
    default     => sub { return {}; },
    lazy        => 1,
);


sub BUILD {
    my ($self) = @_;
    
    # set up default behavior for actions - 
    # currently only 'form_completed' has a default action - 
    # that is to call validate.
    $self->add_action('form_completed', sub { 
                                                my $object = shift; 
                                                $object->validate();
                                            });
}

## adds a field to the form.  If position is specified, places it at the
## given position, otherwise places it at the end of the form.  
## returns the new fields position in the form.
## Note that fieldname does not necessarily need to be the same as $field->name
## though you may get odd behavior if you accidentally insert multiple fields with
## the same $field->name

sub add_field {
    my ($self, $fieldname, $field, $position) = @_;
    
    if (defined($self->_fields->{$fieldname})) {
        $self->remove_field($fieldname);
    }
    
    $self->_fields->{$fieldname};
    
    ## if position is larger than the current form size
    ## reset position so the field is added to the end of the
    ## list.
    
    if ($position > $#{$self->field_order}) {
        $position = undef;
    }
    if (!$position) {
        push @{$self->field_order}, $fieldname;
        $position = $#{$self->field_order};
    } else {
        splice @{$self->field_order}, $position, 0, $fieldname;
    }
    return $position;
}

## removes a field from the form by name.  Returns the removed field 
## or undef if the field was not present in the form.
sub remove_field {
    my ($self, $fieldname) = @_;
    
    my $field = $self->_fields->{$fieldname};
    delete($self->_fields->{$fieldname});
    foreach my $i (0..$#{$self->field_order}) {
        if ($self->field_order->[$i] eq $fieldname ) {
            splice @{$self->field_order}, $i, 1;
            last;
        }
    }
    return $field;
}

## moves a field from one position to another.
sub reorder_field {
    my ($self, $fieldname, $newposition) = @_;
    
    my $field = $self->remove_field($fieldname);
    return $self->add_field($fieldname, $field, $newposition);
}

## returns the field requested or undef if a field by that name is not found
sub field {
    my ($self, $fieldname) = @_;
    
    return $self->_fields->{$fieldname};
}

## returns a hash containing all the fields in the current form
sub fields {
    my $self = shift;
    
    return { %{$self->_fields} };
}

## returns the fieldnames in the current form in their presentation order
sub fieldnames {
    my $self = shift;
    
    return @{$self->field_order};
}

## add an action for the given 
sub add_action {
    my ($self, $event_name, $action) = @_;
    
    if (ref($action) ne 'CODE') {
        croak "add action called but action is not a CODE ref";
    }
    if (!exists($self->actions->{$event_name})) {
        $self->actions->{$event_name} = [];
    }
    push @{$self->actions->{$event_name}}, $action;
}

sub remove_action {
    my ($self, $event_name, $action_to_remove) = @_;
    
    my @new_actions;
    foreach my $action (@{$self->actions->{$event_name}}) {
        if ($action ne $action_to_remove) {
            push @new_actions, $action;
        }
    }
    $self->actions->{$event_name} = \@new_actions;
}

sub clear_actions {
    my ($self, $event_name) = @_;
    
    $self->actions->{$event_name} = [];
}

sub _create_validator {
    my ($self) = @_;
    
    my $validator;

    ## first see if we have had our validator class overridden
    if (defined($self->validation->{class})) {
        
        ## we have, so get the class name and instantiate an object of that class
        my $classname = $self->validation->{class};
        $validator = $classname->new( form => $self, options => $self->validation);
    } else {
        ## otherwise, we create a Form::Sensible::Validator object.
        $validator = Form::Sensible::Validator->new( form => $self, options => $self->validation);
    }
}


sub validate {
    my ($self) = @_;

    $self->validator->reset($self);
    return $self->validator->validate($self);
}

1;
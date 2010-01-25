package Form::Sensible::Form;

use Moose; 
use namespace::autoclean;
use Carp qw/croak/;
use Class::MOP;    ## I don't believe this is required

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

has 'name' => (
    is          => 'rw',
    isa         => 'Str',
    required    => 1,
    default     => 'form',
);

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


has 'renderer' => (
    is          => 'rw',
    isa         => 'Form::Sensible::Renderer',
);

has 'render_hints' => (
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

has 'validator_args' => (
    is          => 'rw',
    isa         => 'ArrayRef',
    required    => 1,
    default     => sub { return []; },
    lazy        => 1,
);

has 'validator_result' => (
    is          => 'rw',
    isa         => 'Form::Sensible::Validator::Result',
    required    => 0,
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
    my ($self, $field, $fieldname, $position) = @_;
    
    if (!$fieldname) {
        if (ref($field) =~ /^Form::Sensible::Field/) {
            $fieldname = $field->name;
        } elsif (ref($field) eq 'HASH') {
            $fieldname = $field->{'name'};
        } 
    }
    
    if (defined($self->_fields->{$fieldname})) {
        $self->remove_field($fieldname);
    }
    
    ## this will cause an unblessed hash passed to add_field to auto-create
    ## the appropriate field type.
    if (ref($field) eq 'HASH') {
        my $newfield = $field;
        $field = Form::Sensible::Field->create_from_flattened($newfield);
    }
    
    if ($field->isa('Form::Sensible::Field::SubForm') && $field->form == $self) {
        croak "Unable to add sub-form. sub-form is the same as me. Infinite recursion will occur, dying now instead of later.";
    }
    
    $self->_fields->{$fieldname} = $field;
    
    ## if position is larger than the current form size
    ## reset position so the field is added to the end of the
    ## list.
    
    if ($position && $position > $#{$self->field_order}) {
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
    
    my $field = $self->field($fieldname);
    delete($self->_fields->{$fieldname});
    foreach my $i (0..$#{$self->field_order}) {
        if ($self->field_order->[$i] eq $fieldname ) {
            splice @{$self->field_order}, $i, 1;
            last;
        }
    }
    return $field;
}

## moves a field from one position to another.  This may not work the way 
## I think because the field is removed and then replaced, depending on it's 
## original position, it may not appear where the user expects.  Need to work 
## on that.
sub reorder_field {
    my ($self, $fieldname, $newposition) = @_;
    
    my $field = $self->remove_field($fieldname);
    return $self->add_field($field, $fieldname, $newposition);
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
    my $classname;
    if (defined($self->validation->{'validator_class'})) {
        ## we have, so get the class name and instantiate an object of that class
        $classname = $self->validation->{'validator_class'};
    } else {
        ## otherwise, we create a Form::Sensible::Validator object.
        $classname = '+Form::Sensible::Validator';
    }
    if ($classname =~ /^\+(.*)$/) {
        $classname = $1;
    } else {
        $classname = 'Form::Sensible::Validator::' . $classname;
    }
    Class::MOP::load_class($classname);
    $validator = $classname->new(@{$self->validator_args});
    
    return $validator;
}

## validation_results() are set automatically if validate is run from the form.
## otherwise it is not set.

sub validate {
    my ($self) = @_;

    if ($self->validator) {
        my $results = $self->validator->validate($self);
        $self->validator_result($results);
        return $self->validator_result();
    } else {
        croak 'Failure attempting to load validator';
    }
}

sub render {
    my ($self) = shift;
    
    if ($self->renderer) {
        return $self->renderer->render($self, @_);
    } else {
        croak __PACKAGE__ . '->render() called but no renderer defined for this form (' . $self->name . ')';
    }
}

sub set_values {
    my ($self, $values) = @_;
    
    foreach my $fieldname ( $self->fieldnames ) {
        if (exists($values->{$fieldname})) {
            $self->field($fieldname)->value($values->{$fieldname});
        }
    }
}

sub flatten {
    my ($self, $template_only) = @_;
    
    my $form_hash = {
    	                    'name' => $self->name,
    	                    'render_hints' => $self->render_hints,
    	                    'validation' => $self->validation,
    	                    'field_order' => $self->field_order,
    	            };

    $form_hash->{'fields'} = {};

    foreach my $fieldname ( $self->fieldnames ) {
        $form_hash->{'fields'}{$fieldname} = $self->field($fieldname)->flatten($template_only);
    }
    return $form_hash; 
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

Form::Sensible::Form - Form::Sensible's Form class

=head1 SYNOPSIS

    use Form::Sensible::Form;
    
    my $form = Form::Sensible::Form->new( name => 'login_form' );

    $form->add_field({ ... });
    
    # later
    
    $form->set_values( $cgi->Vars );
    
    my $validation_result = $form->validate();

    if ( !$validation_result->is_valid() ) {
        # re-render form with errors.
    }

=head1 DESCRIPTION

Form::Sensible::Form is the main class in the Form::Sensible module. It
represents a complete set of fields to be presented to the user in more or
less a single transaction. Unlike an HTML form which has certain presentation
and behaviors associated with it, a Form::Sensible::Form is simply a container
of fields. Forms exist primarily as a handle to allow easy operation upon a
group of fields simultaneously. I< Note that while Forms may only contain
Fields, it is possible to include forms into other forms by using subforms
(L<Form::Sensible::Field::SubForm>) >

Note also that Renderer and Validator objects are built to operate on 
potentially multiple Forms during their lifecycle. The C<render()> and 
C<validate()> are primarily convenience routines.

=head1 ATTRIBUTES

=over 8

=item C<name>

The name of this form. Used mainly to identify a particular form within renderers.

=item C<render_hints>

A hashref containing global form-level rendering hints. Render hints are used
to give renderers clues as to how the form should be rendered.

=item C<validation>

Hashref containing arguments to be used during complete form validation (which
runs after each individual field's validation has run.) Currently only
supports a single key, C<code> which provides a coderef to run to validate the
form. When run, the form, and a prepared C<Form::Sensible::Validator::Result>
object are passed to the subroutine call.

=item C<validator_args>

Hashref containing arguments to the validator class to be used when a validator object is created 'on demand'.

=item C<renderer>

The renderer object associated with this form, if any.  May be set to enable 
the C<< $form->render() >> shortcut.

=back

I<The following attributes are set during normal operating of the Form object, and do not
need to be set manually.  They may be overridden, but if you don't know exactly what 
you are doing, you are likely to run into very hard to debug problems.>

=over 8

=item C<field_order>

An array reference containing the fieldnames for the fields in the form in the
order that they should be presented. While this may be set manually, it's
generally preferred to use the C<add_field> and C<reorder_field> to set field
order.

=item C<validator>

The validator object associated with this form, if any.  May be set manually to 
override the default C<< $form->validate() >> behavior.

=item C<validator_result>

Contains a C<Form::Sensible::Validator::Result> object if this form has had
it's C<validate()> method called. 

=back

=head1 METHODS

=over 8

=item C<new( %options )>

Creates a new Form object with the provided options.  All the attributes above may be passed.

=item C<add_field( $field, $fieldname, $position )>

Adds the provided field to the form with the given fieldname and position. If
C<$fieldname> is not provided the field will be asked for it's name via it's
C<< $field->name >> method call. If C<$position> is not provided the field
will be appended to the form. The C<$field> argument may be an object of a
subclass of L<Form::Sensible::Field> OR a simple hashref which will be passed
to L<Form::Sensible::Field>s C< create_from_flattened() > method in order to
create a field.

=item C<remove_field( $fieldname )>

Removes the field identified by C<$fieldname> from the form.  Using this will
update the order of all fields that follow this one as appropriate. 
Returns the field object that was removed.

=item C<reorder_field( $fieldname, $new_position )>

Moves the field identified by C<$fieldname> to C<$new_position> in the form. All
other fields positions are adjusted accordingly.

=item C<field( $fieldname )>

Returns the field object identified by $fieldname.

=item C<fields()>

Returns a hash containing all the fields in the current form.  

=item C<fieldnames()>

Returns an array of all the fieldnames in the current form.  Order is not guaranteed, if you 
need the field names in presentation-order, use C<field_order()> instead.

=item C<set_values( $values )>

Uses the hashref C<$values> to set the value for each field in the form. This
is a shortcut routine only and is functionally equivalent to calling 
C<< $field->value( $values->{$fieldname} ) >> for each value in the form.

=item C< validate() >

Validates the form based on the validation rules provided for each field during form 
creation.  Delegates it's work to the C<validator> object set for this form.  If no
C<validator> object is set, a new C<Form::Sensible::Validator> will be created.

=item C<render( @options )>

Renders the current form using the C<renderer> object set for this form. Since
different renderers require different options, the C< @options > are specific
to the renderer and are passed as-is to the renderer's C<render()> method.
Returns a rendered form handle object. I< B<Note> that rendered form handle objects
are specific in type and behavior to the renderer being used, please refer to
the renderer's documentation for the proper way to use the rendered form
object.>

=item C<flatten( $template_only )>

Returns a hashref containing the state of the form and all it's fields. This
can be used to re-create the entire form at a later time via
L<Form::Sensible>s C<create_form()> method call. If C<$template_only> is true,
then only the structure of the form is saved and no values or other state will
be included in the returned hashref.

=back

=head1 AUTHOR

Jay Kuri - E<lt>jayk@cpan.orgE<gt>

=head1 SPONSORED BY

Ionzero LLC. L<http://ionzero.com/>

=head1 SEE ALSO

L<Form::Sensible>

=head1 LICENSE

Copyright 2009 by Jay Kuri E<lt>jayk@cpan.orgE<gt>

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
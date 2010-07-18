package Form::Sensible::Field::Select;

use Moose; 
use namespace::autoclean;
use Form::Sensible::DelegateConnection;

extends 'Form::Sensible::Field';

## provides a select field - potentially with multiple selections
## this could be a dropdown box or a radio-select group



has 'options' => (
    is          => 'rw',
    isa         => 'ArrayRef',
    required    => 1,
    default     => sub { return [] },
    lazy        => 1,
);

has 'options_delegate' => (
    is          => 'rw',
    isa         => 'Form::Sensible::DelegateConnection',
    required    => 1,
    default     => sub {
                            my $self = shift;
                            my $obj = $self;
                            
                            return FSConnector( sub { return $obj->options } );
                   },
    lazy        => 1,
    coerce      => 1,
    # additional options
);

has 'values_ok_delegate' => (
    is          => 'rw',
    isa         => 'Form::Sensible::DelegateConnection',
    required    => 1,
    default     => sub {
                            my $self = shift;
                            my $obj = $self;
                            return FSConnector( sub {
                                my $caller = shift;
                                my $values = shift;
                                
                                my @errors;
                                foreach my $value (@{$values}) {
                                    my $valid = 0;
                                    foreach my $option (@{$caller->get_options}) {
                                        if ($value eq $option->{'value'}) {
                                            $valid = 1;
                                            last;
                                        }
                                    }
                                    if (!$valid) {
                                        if (exists($caller->validation->{'invalid_message'})) {
                                            push @errors, $caller->validation->{'invalid_message'};
                                        } else {
                                            push @errors, "_FIELDNAME was set to an invalid value";            
                                        }
                                    }
                                }
                                return @errors;
                            });
                   },
    lazy        => 1,
    coerce      => 1,
    # additional options
);


sub get_additional_configuration {
    my ($self) = @_;
    
    return { 
                'options' => $self->options,
           };    
}

sub set_selection {
    my ($self) = shift;
    
    
    if (!$self->accepts_multiple) {
        $self->value([ $_[0] ]);
    } else {
        push @{$self->value}, @_;
    }
}

sub add_option {
    my ($self, $value, $display_name) = @_;
    
    push @{$self->options}, { name => $display_name,
                               value => $value };
}

sub get_options {
    my ($self) = shift;
    
    $self->options_delegate->($self, @_);
}

around 'validate' => sub {
    my $orig = shift;
    my $self = shift;
    
    my $values;
    if (ref($self->value) eq 'ARRAY') {
        $values = $self->value;
    } else {
        $values = [ $self->value ];
    }
    my @errors = $self->values_ok_delegate->($self, $values);
    return @errors;
};

__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

Form::Sensible::Field::Select - A multiple-choice option field

=head1 SYNOPSIS

    use Form::Sensible::Field::Select;
    
    my $select_field = Form::Sensible::Field::Select->new( 
                                                         name => 'bread_type'
                                                         accepts_multiple => 0
                                                    );

    $select_field->add_option('wheat', 'Wheat Bread');
    $select_field->add_option('white', 'White Bread');
    $select_field->add_option('sour', 'Sourdough Bread');



=head1 DESCRIPTION

This Field type allows a user to select one or more options from a
provided set of options.  This could be rendered as a select box,
a radio group or even a series of checkboxes, depending on the renderer
and the render_hints provided.

Note that the value returned by a select field will always be an arrayref,
even if only a single option was selected.

=head1 ATTRIBUTES

=over 8


=item C<accepts_multiple>

Does this field allow multiple options to be selected.  Defaults to false.

=back 

=head1 METHODS

=over 8

=item C<get_options()> 

Returns an array ref containing the allowed options. Each option is represented as a
hash containing a C<name> element and a C<value> element for the given option.

=item C<set_selection($selected_option,...)> 

Set's the provided option values as selected.  If C<accepts_multiple> is 
false, only the first item will be set as selected.


=item C<add_option($option_value, $option_display_name)>

If no C<options_delegate> was provided - Adds the provided value and display name to the set of options that can
be selected for this field.  If an options_delegate I<IS> provided, has no effect whatsoever.

=back

=head1 DELEGATES

=over 8

=item options_delegate->($self)

The C<options_delegate> is called to obtain the valid options for this field.
Is expected to return an array ref of options. Each option should be a hash
entry with a C<name> key and a C<value> key. If no C<options_delegate> is
provided, defaults to delegating to itself, using internal storage of options
(using the C<add_option> mechanism outlined above)

=item values_ok_delegate->($self, $values_arrayref)

The C<values_ok_delegate> is called to validate the values selected for the
field. It is passed an arrayref containing the selected values and should
return an array of error messages if any of the values are invalid, or undef
otherwise. If no C<values_ok_delegate> is provided, the default delegate
simply loops over the options returned by the C<options_delegate> and checks
each value provided in turn. If retrieving options is an expensive operation
(say pulling from a DB table) it is often less expensive to check the specific
values provided rather than pulling back all options and then comparing them.
This delegate action provides for that possibility.

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
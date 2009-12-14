package Form::Sensible::Field::Select;

use Moose; 
use namespace::autoclean;
extends 'Form::Sensible::Field';

## provides a select field - potentially with multiple selections
## this could be a dropdown box or a radio-select group

has 'accepts_multiple' => (
    is          => 'rw',
    isa         => 'Bool',
    required    => 1,
    default     => 0,
);

has 'options' => (
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

sub get_additional_configuration {
    my $self = shift;
    
    return { 
                'accepts_multiple' => $self->accepts_multiple,
                'options' => $self->options,
                'display_names' => $self->display_names,
           };

}

sub validate {
    my ($self) = @_;
    

    foreach my $value (@{$self->value}) {
        my $valid = 0;
        foreach my $option (@{$self->options}) {
            if ($value eq $option->{'value'}) {
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

=item C<'options'> 

An array ref containing the allowed options. Each option is represented as a
hash containing a C<name> element and a C<value> element for the given option.

=item C<'accepts_multiple'>

Does this field allow multiple options to be selected.  Defaults to false.

=back 

=head1 METHODS

=over 8

=item C<set_selection($selected_option,...)> 

Set's the provided option values as selected.  If C<accepts_multiple> is 
false, only the first item will be set as selected.


=item C<add_option($option_value, $option_display_name)>

Adds the provided value and display name to the set of options that can
be selected for this field.

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
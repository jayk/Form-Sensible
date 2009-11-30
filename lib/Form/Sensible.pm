package Form::Sensible;

use Moose; 
use namespace::autoclean;
use Class::MOP;
use Form::Sensible::Form;
use Form::Sensible::Field;
use Form::Sensible::Field::Number;
use Form::Sensible::Field::Select;
use Form::Sensible::Field::Text;
use Form::Sensible::Field::LongText;
use Form::Sensible::Field::Toggle;
use Form::Sensible::Field::Trigger;
use Form::Sensible::Validator;
use Form::Sensible::Validator::Result;


our $VERSION = "0.10000";

## This module is a simple factory class which will load and create the various
## types of modules required when working with Form::Sensible

sub create_form {
    my ($class, $template) = @_;
    
    my $formhash = { %{$template} };
    delete($formhash->{'fields'});
    delete($formhash->{'field_order'});
    
    my $form = Form::Sensible::Form->new(%{$formhash});
    
    if (ref($template->{'fields'}) eq 'ARRAY') {
        foreach my $field (@{$template->{'fields'}}) {
            my $newfield = Form::Sensible::Field->create_from_flattened($field);
            $form->add_field($newfield, $newfield->name);
        }
    } else {
        my @field_order;
        if (exists($template->{'field_order'})) {
            push @field_order, @{$template->{'field_order'}};
        } else {
            push @field_order, keys %{$template->{'fields'}};
        }
        foreach my $fieldname (@field_order) {
            my $newfield = Form::Sensible::Field->create_from_flattened($template->{'fields'}{$fieldname});
            $form->add_field($newfield, $fieldname);
        }
    }
    return $form;
}

sub get_renderer {
    my ($class, $type, $options) = @_;

    my $class_to_load;
    if ($type =~ /^\+(.*)$/) {
        $class_to_load = $1;
    } else {
        $class_to_load = 'Form::Sensible::Renderer::' . $type;
    }
    Class::MOP::load_class($class_to_load);
    
    return $class_to_load->new($options);
}

sub get_validator {
    my ($class, $type, $options) = @_;
 
    my $class_to_load;
    if ($type =~ /^\+(.*)$/) {
        $class_to_load = $1;
    } else {
        $class_to_load = 'Form::Sensible::Validator::' . $type;
    }
    Class::MOP::load_class($class_to_load);
    
    return $class_to_load->new($options);   
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

Form::Sensible - A sensible way to handle form based user interface

=head1 SYNOPSIS

    use Form::Sensible;
    
    my $object = Form::Sensible::foo->new();

    $object->do_stuff();

=head1 DESCRIPTION

This module does not really exist, it
was made for the sole purpose of
demonstrating how POD works.

=head2 Methods

=over 8

=item C<new>

Returns a new My::Module object.

=item C<as_string>

Returns a stringified representation of
the object. This is mainly for debugging
purposes.

=back

=head1 LICENSE

This is released under the Artistic 
License. See L<perlartistic>.


=head1 AUTHOR

Jay Kuri - <jayk@cpan.org>

=head1 SPONSORED BY

Ionzero LLC. L<http://ionzero.com/>

=head1 SEE ALSO

L<Form::Sensible>

=cut


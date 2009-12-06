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
use Form::Sensible::Field::SubForm;
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
            $form->add_field($field, $field->{name});
            #Form::Sensible::Field->create_from_flattened($field);
            #$form->add_field($newfield, $newfield->name);
        }
    } else {
        my @field_order;
        if (exists($template->{'field_order'})) {
            push @field_order, @{$template->{'field_order'}};
        } else {
            push @field_order, keys %{$template->{'fields'}};
        }
        foreach my $fieldname (@field_order) {
            $form->add_field($template->{'fields'}{$fieldname}, $fieldname);
            
            #my $newfield = Form::Sensible::Field->create_from_flattened($template->{'fields'}{$fieldname});
            #$form->add_field($newfield, $fieldname);
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
    if (!defined($type)) {
        $type = "+Form::Sensible::Validator";
    }
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
        
    my $form = Form::Sensible->create_form( { ... } );

    my $renderer = Form::Sensible->get_renderer('HTML', { tt_config => { INCLUDE_PATH => [ '/path/to/templates' ] }}); 

    my $output = $renderer->render($form)->complete;
    
    ## Form Validation:
    
    my $validation_result = $form->validate();
    
    if ($validation_result->is_valid()) {
        ## do form was valid stuff
    } else {
        my $output_with_messages = $renderer->render($form)->complete;
    }

=head1 DESCRIPTION

Form::Sensible is a different kind of form library. Form::Sensible is not just
another HTML form creator, or a form validator, though it can do both.
Form::Sensible, instead, focuses on what forms are: a method to relay
information to and from a user interface.

Form::Sensible forms are primarily tied to the data they represent.
Form::Sensible is not tied to HTML in any way. You could render Form::Sensible
forms using any presentation system you like, whether that's HTML, console
prompts, WxPerl or voice prompts. (* currently only an HTML renderer is
provided with Form::Sensible, but work is already under way to produce
others.)

The Form::Sensible form lifecycle works as follows:

=head2 Phase 1 - Show a form

    1) Create form object
    2) Create or get a renderer
    3) Use renderer to render form


=head2 Phase 2 - Validate input
    
    1) Create form object
    2) Retrieve user input and place it into form 
    3) Validate form
    4) If form data is invalid, re-render the form with messages

One of the most important features of Form::Sensible is that Forms, once
created, are easily stored for re-generation later. A form's definition and
state are easily converted to a hashref data structure ready for serializing.
Likewise, the serialized data structure can be used to create a complete
Form::Sensible form object ready for use. This makes re-use of forms extremely
easy and provides for dynamic creation and processing of forms.

=head1 EXAMPLES 

=over 8

=item Form creation from simple data structure

    use Form::Sensible;
        
    my $form = Form::Sensible->create_form( {
                                                name => 'test',
                                                fields => [
                                                             { 
                                                                field_class => 'Text',
                                                                name => 'username',
                                                                validation => { regex => '^[0-9a-z]*'  }
                                                             },
                                                             {
                                                                 field_class => 'Text',
                                                                 name => 'password',
                                                                 render_hints => { field_type => 'password' }
                                                             },
                                                             {
                                                                 field_class => 'Trigger',
                                                                 name => 'submit'
                                                             }
                                                          ],
                                            } );

This example creates a form from a simple hash structure. This example creates
a simple (and all too familiar) login form.

=item Creating a form programmatically

    use Form::Sensible;
    
    my $form = Form::Sensible::Form->new(name=>'test');

    my $username_field = Form::Sensible::Field::Text->new(  
                                                            name=>'username', 
                                                            validation => { regex => qr/^[0-9a-z]*$/  }
                                                         );

    $form->add_field($username_field);

    my $password_field = Form::Sensible::Field::Text->new(  
                                                            name=>'password',
                                                            render_hints => { field_type => 'password' } 
                                                         );
    $form->add_field($password_field);

    my $submit_button = Form::Sensible::Field::Trigger->new( name => 'submit' );

    $form->add_field($submit_button);

This example creates the exact same form as the first example. This time,
however, it is done by creating each field object individually, and then
adding each in turn to the form.
    
Both of these methods will produce the exact same results when rendered.

=item Form validation
    
    ## set_values takes a hash of name->value pairs 
    $form->set_values($c->req->params);
    
    my $validation_result = $form->validate();
    
    if ($validation_result->is_valid) { 
    
        #... do stuff if form submission is ok.
    
    } else {
    
        my $renderer = Form::Sensible->get_renderer('HTML');
        my $output = $renderer->render($form)->complete;    
    }

Here we fill in the values provided to us via $c->req->params and then run validation
on the form.  Validation follows the rules provided in the B<validation> definitions for
each field.  Whole-form validation is can also be done if provided.  When validation
is run using this process, the messages are automatically available during rendering.

=back

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


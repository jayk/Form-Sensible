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
    use Form::Sensible::Renderer::HTML;
    
    my $form = Form::Sensible->create_form( {
                                                name => 'test',
                                                fields => [
                                                             { 
                                                                field_class => 'Text',
                                                                name => 'username',
                                                                validation => {  regex => '^[0-9a-z]*'  }
                                                             },
                                                             {
                                                                 field_class => 'Text',
                                                                 name => 'password',
                                                                 render_hints => {  field_type => 'password' }
                                                             },
                                                             {
                                                                 field_class => 'Trigger',
                                                                 name => 'submit'
                                                             }
                                                          ],
                                            } );

    my $renderer = Form::Sensible::Renderer::HTML->new( tt_config => { INCLUDE_PATH => [ '/path/to/templates' ] });

    my $output = $renderer->render($form)->complete;

    
    ######### OR - more programmatic creation of forms #########

    use Form::Sensible;
    use Form::Sensible::Field::Text;
    use Form::Sensible::Field::Trigger;    
    use Form::Sensible::Renderer::HTML;
    
    my $form = Form::Sensible::Form->new(name=>'test');

    my $username_field = Form::Sensible::Field::Text->new(  name=>'username', validation => { regex => qr/^[0-9a-z]*$/  });
    $form->add_field($username_field);

    my $password_field = Form::Sensible::Field::Text->new(  name=>'password',
                                                            render_hints => { field_type => 'password' } );
    $form->add_field($password_field);

    my $submit_button = Form::Sensible::Field::Trigger->new( name => 'submit' );
    $form->add_field($submit_button);

    my $renderer = Form::Sensible::Renderer::HTML->new(tt_config => { INCLUDE_PATH => [ $lib_dir . '/share/templates' ] });
 
    my $output = $renderer->render($form)->complete;
    
    ##
    
    my $form = Form::Sensible->create_form({ ..... });
    
    $form->set_values($c->req->params);
    
    my $validation_result = $form->validate();
    
    if ($validation_result->is_valid) { 
    
        #... do stuff
    
    } else {
    
        my $renderer = Form::Sensible->get_renderer('HTML');
        my $rendered_form = $renderer->render($form);
        $c->stash->{renderedform} = $rendered_form;
    
    }

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


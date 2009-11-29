package Form::Sensible;

use Moose;
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
use Data::Dumper;

## This module should create a multi-purpose 'factory' type object which 
## will provide fields / forms / etc. of the types based on it's configuration.
## this allows the code to simply work with an object and ask for fields
## and it will produce objects of the correct type - for example, if the form
## is to be used in a wxWidgets application, $sensible->field would produce 
## a Perl object appropriate for display in a wxWidget application, where the
## same call would produce an HTML field if the $sensible object was configured
## to work with HTML.

sub create_form_from_template {
    my ($class, $template) = @_;
    
    my $formhash = { %{$template} };
    delete($formhash->{'fields'});
    delete($formhash->{'fieldnames'});
    
    my $form = Form::Sensible::Form->new(%{$formhash});
    
    foreach my $field (@{$template->{'fields'}}) {
        #print Dumper($field);
        foreach my $fieldname (keys %{$field}) {
            my $newfield = Form::Sensible::Field->create_from_flattened($field->{$fieldname});
            $form->add_field($newfield, $fieldname);
        }
    }
    return $form;
}
1;

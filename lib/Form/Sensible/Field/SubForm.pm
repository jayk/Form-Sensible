package Form::Sensible::Field::SubForm;

use Moose; 
use namespace::autoclean;
extends 'Form::Sensible::Field';

has 'form' => (
    is          => 'rw',
    isa         => 'Form::Sensible::Form',
    required    => 1,
);

sub BUILDARGS {
    my $class = shift;
    
    my $args = $_[0];
    if (!ref($args)) {
        $args = { @_ };
    }
    
    ## could probably do this with some sort of coersion - not sure if I want to though.
    if (ref($args->{'form'}) eq 'HASH') {
        $args->{'form'} = Form::Sensible->create_form($args->{'form'});
    }
    return $class->SUPER::BUILDARGS($args);
}

sub BUILD {
    my $self = shift;
    
    if (!exists($self->form->render_hints->{'form_template_prefix'})) {
        $self->form->render_hints->{'form_template_prefix'} = 'subform';
    } 
}

sub get_additional_configuration {
    my ($self, $template_only) = @_;
    
    return { 
                'form' => $self->form->flatten($template_only),
           };

}

sub validate {
    my ($self) = shift;

    return $self->form->validate();    
}

__PACKAGE__->meta->make_immutable;

1;
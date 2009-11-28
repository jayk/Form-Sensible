package Form::Sensible::Renderer::HTML::RenderedForm;

use Moose;
use Carp qw/croak/;

has 'form' => (
    is          => 'rw',
    isa         => 'Form::Sensible::Form',
    required    => 1,
);

has 'template' => (
    is          => 'rw',
    isa         => 'Template',
    required    => 1,
);

has 'css_prefix' => (
    is          => 'rw',
    isa         => 'Str',
    required    => 1,
    default     => '',
);

has 'fields' => (
    is          => 'rw',
    isa         => 'ArrayRef',
    required    => 1,
    default     => sub { return []; },
    lazy        => 1,
);

has 'status_messages' => (
    is          => 'rw',
    isa         => 'ArrayRef[Str]',
    required    => 1,
    default     => sub { return []; },
    lazy        => 1,
);

has 'error_messages' => (
    is          => 'rw',
    isa         => 'HashRef[ArrayRef]',
    required    => 1,
    default     => sub { return {}; },
    lazy        => 1,
);

sub add_status_message {
    my ($self, $message) = @_;
    
    push @{$self->status_messages}, $message;
}

sub add_error_message {
    my ($self, $fieldname, $message) = @_;
    
    if (!exists($self->error_messages->{$fieldname})) {
        $self->error_messages->{$fieldname} = [];
    }
    push @{$self->error_messages->{$fieldname}}, $message;
}

sub add_errors_from_validator_result {
    my ($self, $validator_result) = @_;
    
    foreach my $field ($self->form->fieldnames) {
        if (exists($validator_result->error_fields->{$field})) {
            foreach my $message (@{$validator_result->error_fields->{$field}}) {
                $self->add_error_message($field, $message);
            }
        }
        if (exists($validator_result->missing_fields->{$field})) {
            foreach my $message (@{$validator_result->missing_fields->{$field}}) {
                $self->add_error_message($field, $message);
            }
        }
    }
}

## render form start using $action as our form action
sub start {
    my ($self, $action, $method) = @_;
    
    if (!$method) {
        $method = 'POST';
    }
}

## render all messages - mostly just passes status/error messages to the messages template.
sub messages {
    my ($self, $additionalmessages) = @_;
    
}

## render all the form fields in the order provided by the form object.
sub fields {
    my ($self) = @_;
    
    my @rendered_fields;
    foreach my $field ($self->form->fieldnames) {
        push @rendered_fields, $self->render_field($field);
    }
}

sub render_field {
    my ($self, $fieldname) = @_;
    
    my $field = $self->form->field($fieldname);
    ## figure out what field template we need to load based on the field
    my @templates_to_try = (
                                $self->form->name . '/' . $fieldname,
                                $self->form->name . '/' . $field->field_type,
                                $fieldname,
                                $field->field_type
                           );
    
    ## Order for trying templates should be:
    ## formname/fieldname
    ## formname/fieldtype
    ## fieldname
    ## fieldtype
    
    ## --jk need to set up $vars and such.
    my $output;
    my $vars = {};
    my $template_found = 0;
    foreach my $template_name (@templates_to_try) {
        my $res = $self->template->process($template_name, $vars, \$output);
        if ($res) {
            $template_found = 1;
            last;
        }
    }
    if (!$template_found) {
        ## crap.  throw an error or something, we couldn't find ANY matching template.
        croak "Unable to find any template for " . $self->form->name . ':' . $field->name . " tried: " . join(", ", @templates_to_try);
    }
    return $output;
}

## render end of form.  Probably just </form> most of the time.
sub end {
    my ($self) = @_;
    
    
}
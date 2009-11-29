package Form::Sensible::Renderer::HTML::RenderedForm;

use Moose;
use Carp qw/croak/;
use File::ShareDir;

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

has 'template_fallback_order' => (
    is          => 'rw',
    isa         => 'ArrayRef[Str]',
    required    => 1,
    default     => sub { return [ shift->form->name ]; },
    lazy        => 1,
);

has 'stash' => (
    is          => 'rw',
    isa         => 'HashRef',
    required    => 1,
    default     => sub { return {}; },
    lazy        => 1,
);

has 'css_prefix' => (
    is          => 'rw',
    isa         => 'Str',
    required    => 1,
    default     => 'fs_',
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

has 'render_hints' => (
    is          => 'rw',
    isa         => 'HashRef',
    required    => 1,
    default     => sub { 
                            my $self = shift;
                            return { %{$self->form->render_hints} };
                       },
    lazy        => 1,
);


sub add_status_message {
    my ($self, $message) = @_;
    
    push @{$self->status_messages}, $message;
}

sub add_error_message {
    my ($self, $fieldname, $message) = @_;
    print "in add_error_message for $message\n";
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
    my $vars = {
                    method => $method,
                    action => $action
               };

    my $output;
    $self->process_first_template($vars, \$output, 'form_start');

    return $output;
}

## render all messages - mostly just passes status/error messages to the messages template.
sub messages {
    my ($self, $additionalmessages) = @_;
    
    my $output;

    $self->process_first_template({}, \$output, 'form_messages');
    
    return $output;
}

## return the form field names.
sub fieldnames {
    my ($self) = @_;
    
    return @{$self->form->fieldnames};
}

## render all the form fields in the order provided by the form object.
sub fields {
    my ($self) = @_;
    
    my @rendered_fields;
    foreach my $field ($self->form->fieldnames) {
        push @rendered_fields, $self->render_field($field);
    }
    return join("\n",@rendered_fields);
}

sub render_field {
    my ($self, $fieldname) = @_;

    my $field = $self->form->field($fieldname);
    my $fieldtype = $field->field_type;
    
    ## allow render_hints to override field type - allowing a number to be rendered
    ## as a select with a range, etc.  also allows text to be rendered as 'hidden'  
    if (exists($field->render_hints->{'field_type'})) {
        $fieldtype = $field->render_hints->{'field_type'};
    }

    
    ## Order for trying templates should be:
    ## formname/fieldname
    ## formname/fieldtype
    ## fieldname
    ## fieldtype
    
    my $output;
    my $vars =  {
                    'field' => $field,
                    'field_type' => $fieldtype,
                    'field_name' => $fieldname
                };
                
    ## if we have field-specific render_hints, we have to add them
    ## ourselves.  First we load any already-set render_hints
    if (scalar keys %{$field->render_hints}) {
        $vars->{'render_hints'} = { %{ $self->render_hints } };
        foreach my $key (keys %{$field->render_hints}) {
            $vars->{'render_hints'}{$key} = $field->render_hints->{$key};
        }
    }

    
    ## process the field template we need to load based on the fieldname / field type
    $self->process_first_template($vars, \$output, $fieldname, $fieldtype );
    
    return $output;
}

## pass in the vars / output / template_names to use.  This method handles automatic fallback
## of templates from most specific to least specific.  

sub process_first_template {
    ## I know.... splice is unusual there, but I want to pass templates and this looks better
    ## than a ton of shifts;
    my $self = shift;
    my $vars = shift;
    my $output = shift;
    my @template_names = @_;
    
    ## prefill anything provided already into the stash
    my $stash_vars = { %{$self->stash } }; 
     
    $stash_vars->{'render_hints'} = $self->render_hints;
    $stash_vars->{'form'} = $self->form;
    $stash_vars->{'error_messages'} = $self->error_messages;
    $stash_vars->{'status_messages'} = $self->status_messages;
    $stash_vars->{'css_prefix'} = $self->css_prefix;
    
    ## copy the vars array into the stash_vars
    foreach my $key (keys %{$vars}) {
      $stash_vars->{$key} = $vars->{$key};  
    } 
                         
    my @templates_to_try;
    
    foreach my $path (@{$self->template_fallback_order}) {
        foreach my $template_name (@template_names) {
            push @templates_to_try, $path . '/' . $template_name;
        }
    }
    
    push @templates_to_try, @template_names;
    
    my $template_found = 0;
    foreach my $template_name (@templates_to_try) {
        my $res = $self->template->process($template_name . ".tt", $stash_vars, $output);
        if ($res) {
            $template_found = 1;
            last;
        }
    }
    
    if (!$template_found) {
        ## crap.  throw an error or something, we couldn't find ANY matching template.
        croak "Unable to find any template for processing, tried: " . join(", ", @templates_to_try);
    }
    return $output;
}

## render end of form.  Probably just </form> most of the time.
sub end {
    my ($self) = @_;
    
    my $output;
    
    $self->process_first_template({}, \$output, 'form_end');

    return $output;
}

1;
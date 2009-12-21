package Form::Sensible::Renderer::HTML::RenderedForm;

use Moose; 
use namespace::autoclean;
use Data::Dumper;
use Carp qw/croak/;
use File::ShareDir;

has 'form' => (
    is          => 'rw',
    isa         => 'Form::Sensible::Form',
    required    => 1,
    #weak_ref    => 1,
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

has 'form_template_prefix' => (
    is          => 'rw',
    isa         => 'Str',
    required    => 1,
    builder     => '_default_form_template_prefix',
    lazy        => 1,
);

has 'subform_renderers' => (
    is          => 'rw',
    isa         => 'HashRef',
    required    => 1,
    default     => sub { return {}; },
    lazy        => 1
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

sub _default_form_template_prefix {
    my $self = shift;
    
    if (exists($self->form->render_hints->{form_template_prefix})) {
        return $self->form->render_hints->{form_template_prefix};
    } else {
        return 'form';
    }
}

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
                    'form'  => $self->form,
                    'method' => $method,
                    'action' => $action,
               };

    
    my $output;
    $self->process_first_template($vars, \$output, $self->form_template_prefix . '_start');

    return $output;
}

## render all messages - mostly just passes status/error messages to the messages template.
sub messages {
    my ($self, $additionalmessages) = @_;
    
    ## if we haven't already added error_messages and we have a validator_result in the form
    ## then we add the errors immediately before processing.
    if ((!scalar keys %{$self->error_messages}) && defined($self->form->validator_result)) {
        $self->add_errors_from_validator_result($self->form->validator_result);
    }
    
    my $output;
    $self->process_first_template({}, \$output, $self->form_template_prefix . '_messages');
    
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
    foreach my $field (@{$self->form->field_order}) {
        push @rendered_fields, $self->render_field($field);
    }
    return join("\n",@rendered_fields);
}

sub render_field {
    my ($self, $fieldname, $manual_hints) = @_;

    my $field = $self->form->field($fieldname);
    my $fieldtype = $field->field_type;
    
    if (exists($self->subform_renderers->{$fieldname})) {
        ## handle fields that are subforms.  
        return $self->subform_renderers->{$fieldname}->complete();
    } else {
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
                        'form'  => $self->form,
                        'field' => $field,
                        'field_type' => $fieldtype,
                        'field_name' => $fieldname
                    };
                
        ## if we have field-specific render_hints, we have to add them
        ## ourselves.  First we load any already-set render_hints
        $vars->{'render_hints'} = { %{ $self->render_hints } };
        if (scalar keys %{$field->render_hints}) {
            foreach my $key (keys %{$field->render_hints}) {
                $vars->{'render_hints'}{$key} = $field->render_hints->{$key};
            }
        }
        if (ref($manual_hints) eq 'HASH') {
            foreach my $key (keys %{$manual_hints}) {
                $vars->{'render_hints'}{$key} = $manual_hints->{$key};
            }
        }
    
        ## process the field template we need to load based on the fieldname / field type
        $self->process_first_template($vars, \$output, $fieldname, $fieldtype );
    
        return $output;
    }
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
        } else {
            my $error = $self->template->error();
            if ($error->info =~ /parse error/) {
                croak 'Error processing ' . $template_name . ': ' . $error;
            }
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
    
    $self->process_first_template({}, \$output, $self->form_template_prefix . '_end');

    return $output;
}

sub complete {
    my ($self, $action, $method) = @_;
    
    return join('', $self->start($action, $method), $self->messages, $self->fields, $self->end);
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

Form::Sensible::Renderer::HTML::RenderedForm - A HTML based rendered form handle.

=head1 SYNOPSIS

    use Form::Sensible::Renderer::HTML::RenderedForm;
    
    my $object = Form::Sensible::Renderer::HTML::RenderedForm->new();

    $object->do_stuff();

=head1 DESCRIPTION

This module does not really exist, it
was made for the sole purpose of
demonstrating how POD works.

=head1 ATTRIBUTES

=over 8
=item C<'form'> has
=item C<'template'> has
=item C<'template_fallback_order'> has
=item C<'stash'> has
=item C<'css_prefix'> has
=item C<'form_template_prefix'> has
=item C<'subform_renderers'> has
=item C<'status_messages'> has
=item C<'error_messages'> has
=item C<'render_hints'> has

=back

=head1 METHODS

=over 8

=item C<_default_form_template_prefix> sub
=item C<add_status_message> sub
=item C<add_error_message> sub
=item C<add_errors_from_validator_result> sub
=item C<start> sub
=item C<messages> sub
=item C<fieldnames> sub
=item C<fields> sub
=item C<render_field> sub
=item C<process_first_template> sub
=item C<end> sub
=item C<complete> sub


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

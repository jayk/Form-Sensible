package Form::Sensible::Validator;

use Moose; 
use namespace::autoclean;
use Form::Sensible::Validator::Result;
use Carp qw/croak/;

## this module provides the basics for validation of a Form.

has 'config' => (
    is          => 'rw',
    isa         => 'HashRef',
    required    => 1,
    default     => sub { return { }; },
    lazy        => 1,
);

# returns a Form::Sensible::Validator::Result
sub validate {
    my ($self, $form) = @_;
    
    ## validation follows this process: Validate each field in order, using
    ## the order provided by the form.  If all of those succeed, then proceed to 
    ## complete form validation if provided.
    
    ## Prepare our validation result - it will be 'valid' unless we fail something.
    my $validation_result = Form::Sensible::Validator::Result->new();
    
    foreach my $fieldname ($form->fieldnames) {
        my $field = $form->field($fieldname);
        if ($field->value) {
            
            ## field has value, so we run the field validators
            ## first regex. 
            if (defined($field->validation->{'regex'})) {
                my $invalid = $self->validate_field_with_regex($field, $field->validation->{'regex'});
                if ($invalid) {
                    $validation_result->add_error($fieldname, $invalid);
                }
            }
            ## if we have a coderef, and we passed regex, run the coderef.  Otherwise we
            ## don't bother. 
            if (defined($field->validation->{'code'}) && $validation_result->is_valid()) {
                my $invalid = $self->validate_field_with_code($field, $field->validation->{'code'});
                if ($invalid) {
                    $validation_result->add_error($fieldname, $invalid);
                }
            }
            ## finally, we run the fields internal validate routine
            my $invalid = $field->validate($self);
            if ($invalid) {
                $validation_result->add_error($fieldname, $invalid);
            }
        } elsif ($field->required) {
            ## field was required but was empty.
            if (exists($field->validation->{'missing_message'})) {
                $validation_result->add_missing($fieldname, $field->validation->{'missing_message'});
            } else {
                $validation_result->add_missing($fieldname,  $field->display_name . " is a required field but was not provided.");
            }
        }
    }
    
    if ($validation_result->is_valid()) {
        if (defined($form->validation->{'code'}) && ref($form->validation->{'code'}) eq 'CODE') {
            my $results = $form->validation->{'code'}->($form, $validation_result);
        }
    }
    return $validation_result;
}

sub validate_field_with_regex {
    my ($self, $field, $regex) = @_;
    
    if (ref($regex) ne 'Regexp') {
        $regex = qr/$regex/;
    }
    
    if ($field->value !~ $regex) {
        if (exists($field->validation->{'invalid_message'})) {
            return $field->validation->{'invalid_message'};
        } else {
            return $field->display_name . " is invalid.";
        }
    } else {
        return 0;
    }
}

sub validate_field_with_coderef {
    my ($self, $field, $code) = @_;

    if (ref($code) ne 'CODE') {
        croak('Bad coderef provided to validate_field_with_coderef');
    }
    
    my $results = $code->($field);
    
    ## if we get $results of 0 or a message, we return it.
    ## if we get $results of simply one, we generate the invalid message
    if ($results == 1) {
        if (exists($field->validation->{invalid_message})) {
            return $field->validation->{invalid_message};
        } else {
            return $field->display_name . " is invalid.";
        }
    } else {
        return $results;
    }
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

Form::Sensible::Validator - Default Validator for Form::Sensible forms

=head1 SYNOPSIS

    use Form::Sensible::Validator;
    
    my $object = Form::Sensible::Validator->new();

    $object->do_stuff();

=head1 DESCRIPTION

This module does not really exist, it
was made for the sole purpose of
demonstrating how POD works.

=head1 ATTRIBUTES 

=over 8

=item C<'config'> 

=back 

=head1 METHODS

=over 8

=item C<validate> 
=item C<validate_field_with_regex> 
=item C<validate_field_with_coderef> 

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
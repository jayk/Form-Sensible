package Form::Sensible::Validator::Result;

use Moose; 
use namespace::autoclean;

has 'error_fields' => (
    is          => 'rw',
    isa         => 'HashRef',
    required    => 1,
    default     => sub { return {}; },
    lazy        => 1,
);

has 'missing_fields' => (
    is          => 'rw',
    isa         => 'HashRef',
    required    => 1,
    default     => sub { return {}; },
    lazy        => 1,
);

sub add_error {
    my ($self, $fieldname, $message) = @_;
    
    if (ref($message) && $message->DOES('Form::Sensible::Validator::Result')) {
        $self->merge_from_result($message);
    } else {
        if (!exists($self->error_fields->{$fieldname})) {
            $self->error_fields->{$fieldname} = [];
        }
        push @{$self->error_fields->{$fieldname}}, $message;
    }
}

sub add_missing {
    my ($self, $fieldname, $message) = @_;
    
    if (ref($message) && $message->DOES('Form::Sensible::Validator::Result')) {
        $self->merge_from_result($message);
    } else {
        if (!exists($self->missing_fields->{$fieldname})) {
            $self->missing_fields->{$fieldname} = [];
        }
        push @{$self->missing_fields->{$fieldname}}, $message;
    }
}

sub is_valid {
    my ($self) = @_;
    
    if ((scalar keys %{$self->error_fields}) || (scalar keys %{$self->missing_fields})) {
        return 0;
    } else {
        return 1;
    }
}

# if we have a validation result instead of a message in the error routines, we will need to
# merge the values from the provided result into the current result

sub merge_from_result {
    my ($self, $result) = @_;
    
    foreach my $fieldname (keys %{$result->error_fields}) {
        if (!exists($self->error_fields->{$fieldname})) {
            $self->error_fields->{$fieldname} = [];
        }
        push @{$self->error_fields->{$fieldname}}, @{$result->error_fields->{$fieldname}};
    }
    foreach my $fieldname (keys %{$result->missing_fields}) {
        if (!exists($self->missing_fields->{$fieldname})) {
            $self->missing_fields->{$fieldname} = [];
        }
        push @{$self->missing_fields->{$fieldname}}, @{$result->missing_fields->{$fieldname}};
    }
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

Form::Sensible::Validator::Result - Validation results for a given form.

=head1 SYNOPSIS

    use Form::Sensible::Validator::Result;
    
    my $object = Form::Sensible::Validator::Result->new();

    $object->do_stuff();

=head1 DESCRIPTION

This module does not really exist, it
was made for the sole purpose of
demonstrating how POD works.

=head1 ATTRIBUTES

=over 8

=item C<'error_fields'> 
=item C<'missing_fields'> 

=back

=head1 METHODS

=over 8

=item C<add_error> 
=item C<add_missing> 
=item C<is_valid> 
=item C<merge_from_result> 

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
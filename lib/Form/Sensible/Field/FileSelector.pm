package Form::Sensible::Field::FileSelector;

use Moose; 
use namespace::autoclean;
extends 'Form::Sensible::Field';

## provides a plain text field

has 'valid_extensions' => (
    is          => 'rw',
    isa         => 'ArrayRef',
    required    => 1,
    default     => sub { return [] },
);

has 'maximum_size' => (
    is          => 'rw',
    isa         => 'Int',
    required    => 1,
    default     => 0,
    lazy        => 1,
);

has 'must_exist' => (
    is          => 'rw',
    isa         => 'Bool',
    required    => 1,
    default     => 1,
    lazy        => 1,
);

has 'must_be_readable' => (
    is          => 'rw',
    isa         => 'Bool',
    required    => 1,
    default     => 1,
    lazy        => 1,
);




sub get_additional_configuration {
    my ($self) = @_;
    
    return { 
                'maximum_size' => $self->maximum_size,
                'valid_extensions' => $self->valid_extensions,
                'must_exist' => $self->must_exist,
                'must_be_readable' => $self->must_be_readable
           };    
}

sub validate {
    my ($self) = @_;
    
    if ($#{$self->valid_extensions} != -1) {
        my $extensions = "." . join('|.', @{$self->valid_extensions});
        if ($self->value !~ /($extensions)$/) {
            return $self->display_name . " is not a valid file type";
        }
    }
    # file must exist.
    if ($self->must_exist && ! -e $self->value) {
        return $self->display_name . " does not exist.";
    }
    if ($self->must_be_readable && ! -r $self->value ) {
        return $self->display_name . " is not readable";
    }
    if ($self->maximum_size) {
        my $filesize = -s $self->value;
        if ($filesize > $self->maximum_size) {
            return $self->display_name . " is too large";
        }
    }
    return 0;
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

Form::Sensible::Field::FileSelector - 

=head1 SYNOPSIS

    use Form::Sensible::Field::FileSelector;
    
    my $object = Form::Sensible::Field::FileSelector->new();

    $object->do_stuff();

=head1 DESCRIPTION

This module does not really exist, it
was made for the sole purpose of
demonstrating how POD works.

=head1 ATTRIBUTES

=over 8

=item C<'maximum_length'> has
=item C<'should_truncate'> has

=back

=head1 METHODS

=over 8

=item C<'maximum_length'> has
=item C<'should_truncate'> has
=item C<get_additional_configuration> sub
=item C<validate> sub


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
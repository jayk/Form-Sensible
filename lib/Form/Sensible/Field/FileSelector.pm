package Form::Sensible::Field::FileSelector;

use Moose; 
use namespace::autoclean;
extends 'Form::Sensible::Field';

## provides a plain text field

has 'file_ref' => (
    is          => 'rw',
);


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

Form::Sensible::Field::FileSelector - Field used for file selection

=head1 SYNOPSIS

    use Form::Sensible::Field::FileSelector;
    
    my $object = Form::Sensible::Field::FileSelector->new({
        name => 'upload_file',
        valid_extensions => [ "jpg", "gif", "png" ],
        maximum_size => 262144,
    });


=head1 DESCRIPTION

This field represents a File.  When the FileSelector field type is used, 
the user will be prompted to select a file.  Depending on the user 
interface, it may be prompting for a local file or a file upload.  

=head1 ATTRIBUTES

=over 8

=item C<value>
The local filename of the file selected.  

=item C<maximum_size>
The maximum file size allowed for the file.

=item C<valid_extensions>
An array ref containing the valid extensions for this file. 

=item C<must_exist>
A true / false indicating whether the file must exist by the time the field is validated.  Defaults to true.

=item C<must_be_readable>
A true / false indicating whether the file must be readable by the time the field is validated.  Defaults to true.

=item C<file_ref>
A reference to the file.  This will only be defined if appropriate for your interface type.  This will be defined,
for example, within a Catalyst app to hold the Catalyst::Request::Upload object.

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
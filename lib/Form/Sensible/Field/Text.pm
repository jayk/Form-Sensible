package Form::Sensible::Field::Text;

use Moose; 
use namespace::autoclean;
extends 'Form::Sensible::Field';

## provides a plain text field

has 'maximum_length' => (
    is          => 'rw',
    isa         => 'Int',
    required    => 1,
    default     => 256,
);

has 'should_truncate' => (
    is          => 'rw',
    isa         => 'Bool',
    required    => 1,
    default     => 0,
);

## does truncation if should_truncate is set.
around 'value' => sub {
    my $orig = shift;
    my $self = shift;
    
    if (@_) {
        my $value = shift;
        if ($self->should_truncate) {
            $self->$orig(substr($value,0,$self->maximum_length));
        } else {
            $self->$orig($value);
        }
    } else {
        return $self->$orig()
    }
};

sub get_additional_configuration {
    my ($self) = @_;
    
    return { 
                'maximum_length' => $self->maximum_length,
                'should_truncate' => $self->should_truncate
           };    
}

sub validate {
    my ($self) = @_;
    
    if (length($self->value) > $self->maximum_length) {
        return $self->display_name . " is too long";
    }
    return 0;
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

Form::Sensible::Field::Text - 

=head1 SYNOPSIS

    use Form::Sensible::Field::Text;
    
    my $object = Form::Sensible::Field::Text->new();

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
package Form::Sensible::Field::Toggle;

use Moose; 
use namespace::autoclean;
extends 'Form::Sensible::Field';

## provides a simple on/off field

has 'on_value' => (
    is          => 'rw',
    default     => 'on',
);

has 'off_value' => (
    is          => 'rw',
    default     => 'off',
);

sub get_additional_configuration {
    my $self = shift;
    
    return { 
                'on_value' => $self->on_value,
                'off_value' => $self->off_value
           };

}

sub options {
    my $self = shift;
    
    return [ map { { name => $_, value => $_ } } ($self->on_value, $self->off_value) ];
}

sub validate {
    my $self = shift;
    
    if ($self->value ne $self->on_value && $self->value ne $self->off_value) {
    
        if (exists($self->validation->{'invalid_message'})) {
            return $self->validation->{'invalid_message'};
        } else {
            return $self->display_name . " was set to an invalid value";            
        }        
    } else {
        return 0;
    }
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

Form::Sensible::Field::Toggle - 

=head1 SYNOPSIS

    use Form::Sensible::Field::Toggle;
    
    my $object = Form::Sensible::Field::Toggle->new();

    $object->do_stuff();

=head1 DESCRIPTION

This module does not really exist, it
was made for the sole purpose of
demonstrating how POD works.

=head1 METHODS

=over 8

=item C<'on_value'> has
=item C<'off_value'> has

=back

=head1 METHODS

=over 8

=item C<get_additional_configuration> sub
=item C<options> sub
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
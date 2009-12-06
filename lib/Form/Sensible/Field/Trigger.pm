package Form::Sensible::Field::Trigger;

use Moose; 
use namespace::autoclean;
extends 'Form::Sensible::Field';

## provides an action trigger

## always has an activation trigger, even if it does nothing.

has 'event_to_trigger' => (
    is          => 'rw',
    isa         => 'Str',
    required    => 1,
    builder     => '_default_event_name',
    lazy        => 1,
);

sub _default_event_name {
    my ($self) = @_;
    
    return $self->name . "_triggered";
}


sub get_additional_configuration {
    my $self = shift;
    
    return { 
                'event_to_trigger' => $self->event_to_trigger,
           };

}

__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

Form::Sensible::Field::Trigger - 

=head1 SYNOPSIS

    use Form::Sensible::Field::Trigger;
    
    my $object = Form::Sensible::Field::Trigger->new();

    $object->do_stuff();

=head1 DESCRIPTION

This module does not really exist, it
was made for the sole purpose of
demonstrating how POD works.


=head1 ATTRIBUTES

=over 8

=item C<'event_to_trigger'> has

=back

=head1 METHODS

=over 8

=item C<_default_event_name> sub
=item C<get_additional_configuration> sub

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
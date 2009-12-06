package Form::Sensible::Field::LongText;

use Moose; 
use namespace::autoclean;
extends 'Form::Sensible::Field::Text';

has '+maximum_length' => (
    default => 10240,
);

## provides a long text field (such as a 'text area' or 'notes' box)
## for now the only difference is a longer length.  that may change.

__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

Form::Sensible::Field::LongText - 

=head1 SYNOPSIS

    use Form::Sensible::Field::LongText;
    
    my $object = Form::Sensible::Field::LongText->new();

    $object->do_stuff();

=head1 DESCRIPTION

This module does not really exist, it
was made for the sole purpose of
demonstrating how POD works.

=head1 ATTRIBUTES

=over 8

=item C<'+maximum_length'> has

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

package Form::Sensible::Renderer;

use Moose; 
use namespace::autoclean;

## this module provides the basics for rendering of forms / fields
##
## should this be an abstract role that defines the interface for rendering?

__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

Form::Sensible::Renderer - Base class for Renderers. 

=head1 DESCRIPTION

This module does not really exist and may go away entirely.

=head1 METHODS

=over 8

=item C<render($form)>

Returns a stringified representation of
the object. This is mainly for debugging
purposes.

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
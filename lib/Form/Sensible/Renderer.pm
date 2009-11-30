package Form::Sensible::Renderer;

use Moose; 
use namespace::autoclean;

## this module provides the basics for rendering of forms / fields
##
## should this be an abstract role that defines the interface for rendering?

__PACKAGE__->meta->make_immutable;
1;
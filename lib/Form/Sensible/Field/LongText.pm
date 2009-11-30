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
package Form::Sensible::Field::LongText;

use Moose;
extends 'Form::Sensible::Field::Text';

## provides a long text field (such as a 'text area' or 'notes' box)
## for now the only difference is a longer length.  that may change.

sub _set_max_length {
    my ($self) = shift;
    
    return 10240;
}

1;
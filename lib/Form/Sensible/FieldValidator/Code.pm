package Form::Sensible::FieldValidator::Code;

use Moose;

has 'code' => (
    is          => 'rw',
    isa         => 'CodeRef',
    required    => 1,
);

sub validate {
    my ($self, $field) = @_;

    my $results = $self->code->($field);
    
    ## if we get $results of 0 or a message, we return it.
    ## if we get $results of simply one, we generate the invalid message
    if ($results == 1) {
        if (exists($field->validation->{invalid_message})) {
            return $field->validation->{invalid_message};
        } else {
            return $field->display_name . " is invalid.";
        }
    } else {
        return $results;
    }
}


1;
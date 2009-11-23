package Form::Sensible::FieldValidator::Regex;

use Moose;

has 'regex' => (
    is          => 'rw',
    isa         => 'RegexpRef',
);


sub validate {
    my ($self, $field) = @_;

    if ($field->value !~ $self->regex) {
        if (exists($field->validation->{'invalid_message'})) {
            return $field->validation->{'invalid_message'};
        } else {
            return $field->display_name . " is invalid.";
        }
    } else {
        return 0;
    }
}

1;
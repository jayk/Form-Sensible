package Form::Sensible::Validator::Result;

use Moose; 
use namespace::autoclean;

has 'error_fields' => (
    is          => 'rw',
    isa         => 'HashRef',
    required    => 1,
    default     => sub { return {}; },
    lazy        => 1,
);

has 'missing_fields' => (
    is          => 'rw',
    isa         => 'HashRef',
    required    => 1,
    default     => sub { return {}; },
    lazy        => 1,
);

sub add_error {
    my ($self, $fieldname, $message) = @_;
    
    if (ref($message) && $message->DOES('Form::Sensible::Validator::Result')) {
        $self->merge_from_result($message);
    } else {
        if (!exists($self->error_fields->{$fieldname})) {
            $self->error_fields->{$fieldname} = [];
        }
        push @{$self->error_fields->{$fieldname}}, $message;
    }
}

sub add_missing {
    my ($self, $fieldname, $message) = @_;
    
    if (ref($message) && $message->DOES('Form::Sensible::Validator::Result')) {
        $self->merge_from_result($message);
    } else {
        if (!exists($self->missing_fields->{$fieldname})) {
            $self->missing_fields->{$fieldname} = [];
        }
        push @{$self->missing_fields->{$fieldname}}, $message;
    }
}

sub is_valid {
    my ($self) = @_;
    
    if ((scalar keys %{$self->error_fields}) || (scalar keys %{$self->missing_fields})) {
        return 0;
    } else {
        return 1;
    }
}

# if we have a validation result instead of a message in the error routines, we will need to
# merge the values from the provided result into the current result

sub merge_from_result {
    my ($self, $result) = @_;
    
    foreach my $fieldname (keys %{$result->error_fields}) {
        if (!exists($self->error_fields->{$fieldname})) {
            $self->error_fields->{$fieldname} = [];
        }
        push @{$self->error_fields->{$fieldname}}, @{$result->error_fields->{$fieldname}};
    }
    foreach my $fieldname (keys %{$result->missing_fields}) {
        if (!exists($self->missing_fields->{$fieldname})) {
            $self->missing_fields->{$fieldname} = [];
        }
        push @{$self->missing_fields->{$fieldname}}, @{$result->missing_fields->{$fieldname}};
    }
}

__PACKAGE__->meta->make_immutable;
1;
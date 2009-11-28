package Form::Sensible::Validator::Result;

use Moose;

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
    
    if (!exists($self->error_fields->{$fieldname})) {
        $self->error_fields->{$fieldname} = [];
    }
    push @{$self->error_fields->{$fieldname}}, $message;
}

sub add_missing {
    my ($self, $fieldname, $message) = @_;
    
    if (!exists($self->missing_fields->{$fieldname})) {
        $self->missing_fields->{$fieldname} = [];
    }
    push @{$self->missing_fields->{$fieldname}}, $message;}


sub is_valid {
    my ($self) = @_;
    
    if ((scalar keys %{$self->error_fields}) || (scalar keys %{$self->missing_fields})) {
        return 0;
    } else {
        return 1;
    }
}

1;
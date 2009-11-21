package Form::Sensible::Field;

use Moose;

=pod 
                    name => $xyz,
                    label => $xyz,
                    type => $xyz,
                    arg => $xyz,
                    options => $xyz,
                    required => 1, 
                    valid_regex => qr/...../,
                    valid_code => sub { .... }
=cut

has 'name' => (
    is          => 'rw',
    isa         => 'Str',
    required    => 1,
);

has 'label' => (
    is          => 'rw',
    isa         => 'Str',
    required    => 1,
    default     => sub { return shift->name(); },
    lazy        => 1,
);

has 'required' => (
    is          => 'rw',
    isa         => 'Bool',
    required    => 1,
    default     => 0,
);

has 'validator' => (
    is          => 'rw',
    isa         => 'Object',
    required    => 1,
    lazy        => 1,
    # additional options
);

has 'current_value' => (
    is          => 'rw',
);

1;

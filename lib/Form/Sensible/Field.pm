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

has 'display_name' => (
    is          => 'rw',
    isa         => 'Str',
    required    => 1,
    default     => sub { return ucfirst(shift->name()); },
    lazy        => 1,
);

has 'required' => (
    is          => 'rw',
    isa         => 'Bool',
    required    => 1,
    default     => 0,
);

## validation is args to the validator that will be used
## by default, the hashref can contain 'regex' - a ref to a 
## regex.  or 'code' - a code ref.  If both are present, 
## the regex will be checked first, then if that succeeds
## the coderef will be processed.


has 'validation' => (
    is          => 'rw',
    isa         => 'HashRef',
    required    => 1,
    default     => sub { return {}; },
    lazy        => 1,
);

## render hints is a hashref that gives hints about rendering
## for the various renderers.  for example:  
## render_hints->{HTML} = hash containing information about 
## how the field should be rendered.

has 'render_hints' => (
    is          => 'rw',
    isa         => 'HashRef',
    required    => 1,
    default     => sub { return {}; },
    lazy        => 1,
);




# values are of indeterminate type generally.
has 'value' => (
    is          => 'rw',
);

has 'default_value' => (
    is          => 'rw',
);

1;

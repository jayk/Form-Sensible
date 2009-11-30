package Form::Sensible::Field;

use Moose; 
use namespace::autoclean;
use Carp;
use Data::Dumper;
use Class::MOP;

has 'name' => (
    is          => 'rw',
    isa         => 'Str',
    required    => 1,
);

has 'display_name' => (
    is          => 'rw',
    isa         => 'Str',
    required    => 1,
    default     => sub { 
                            my $name = ucfirst(shift->name()); 
                            $name =~ s/_/ /;
                            return $name; 
                        },
    lazy        => 1,
);

has 'field_type' => (
    is          => 'rw',
    isa         => 'Str',
    required    => 1,
    builder     => '_field_type',
    lazy        => 1
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

sub _field_type {
    my $self = shift;
    
    my $class = ref($self);
    $class =~ m/::([^:]*)$/;
    return lc($1);
}

sub flatten {
    my ($self, $template_only) = @_;
    
    my %config = (
                    name => $self->name,
                    display_name => $self->display_name,
                    required => $self->required,
                    default_value => $self->default_value,
                    field_type => $self->field_type,
                    render_hints => $self->render_hints,
                 );
    
    my $class = ref($self);
    if ($class =~ /^Form::Sensible::Field::(.*)$/) {
        $class = $1;
    } else {
        $class = '+' . $class;
    }
    $config{'field_class'} = $class;
    if (!$template_only) {
        $config{'value'} = $self->value;
    }
    
    $config{'validation'} = {};
    foreach my $key (keys %{$self->validation}) {
        if (ref($self->validation->{$key})) {
            my $f = $self->validation->{$key};
            $config{'validation'}{$key} = "$f";
        } else {
            $config{'validation'}{$key} = $self->validation->{$key};   
        }
    }
    my $additional = $self->get_additional_configuration;
    foreach my $key (keys %{$additional}) {
        $config{$key} = $additional->{$key};
    }
    
    return \%config;
}

## hook for adding additional config without having to do 'around' every time.
sub get_additional_configuration {
    my ($self) = @_;
    
    return {};
}

## built-in field specific validation.  Regex and code validation run first.
sub validate {
    my ($self) = @_;
    
    return 0;
}

## restores a flattened field structure.
sub create_from_flattened {
    my ($class, $fieldconfig ) = @_;
    
    my $fieldclass = $fieldconfig->{'field_class'};
    if (!$fieldclass) {
        croak "Unable to restore flattened field, no field class defined";
    }
    my $class_to_load;
    if ($fieldclass =~ /^\+(.*)$/) {
        $class_to_load = $1;
    } else {
        $class_to_load = 'Form::Sensible::Field::' . $fieldclass;
    }
    Class::MOP::load_class($class_to_load);
    
    # copy because we are going to remove class, as it wasn't there to begin with.
    my $config = { %{$fieldconfig} };
    delete $config->{'field_class'};
    #print Dumper($config);
    return $class_to_load->new(%{$fieldconfig});
}

__PACKAGE__->meta->make_immutable;
1;

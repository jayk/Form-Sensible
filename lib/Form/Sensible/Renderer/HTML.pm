package Form::Sensible::Renderer::HTML;

use Moose;

has 'include_paths' => (
    is          => 'rw',
    isa         => 'ArrayRef[Str]',
    required    => 1,
    default     => sub { return []; },
);

has 'tt_config' => (
    is          => 'rw',
    isa         => 'HashRef',
    required    => 1,
    default     => sub { return {}; },
    lazy        => 1,
);

has 'template' => (
    is          => 'rw',
    isa         => 'Template',
);


sub render {
    my ($self, $form, $options) = @_;
    
    my $include_paths;
    
    if (exists($options->{include_paths})) {
        $include_paths = $options->{include_paths};
    } else {
        $include_paths = $self->include_paths;
    }
    
    if (exists($options->{additional_template_paths}) && ref($options->{additional_template_paths}) eq 'ARRAY') {
        my %paths = map { $_ => 1 } ( @{$include_paths}, @{$options->{additional_template_paths}} );
        @{$include_paths} = keys %paths;
    }

}

sub render_field {}

1;
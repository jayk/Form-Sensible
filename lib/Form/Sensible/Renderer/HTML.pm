package Form::Sensible::Renderer::HTML;

use Moose;
use File::ShareDir;

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

has 'default_options' => (
    is          => 'rw',
    isa         => 'HashRef',
    required    => 1,
    default     => sub {
                            return {
                                    include_path => [ File::ShareDir::dist_dir('Form-Sensible') ]
                            }; 
                       },
    lazy        => 1,
);


sub render {
    my ($self, $form, $options) = @_;
    
    my $include_paths;
    
    ## Merge the default options with the passed options for rendering
    ## passed options take precedent, if provided.
    my %render_options = ( %{$self->default_options} );
    foreach my $key (keys %{$options}) {
        $render_options{$key} = $options->{$key};
    }
        
    $include_paths = [ @{$render_options->{'include_paths'}} ];
    if (exists($render_options->{additional_template_paths}) && ref($render_options->{additional_template_paths}) eq 'ARRAY') {
        
        my %paths = map { $_ => 1 } ( @{$include_paths}, @{$render_options->{additional_template_paths}} );
        @{$include_paths} = keys %paths;
    } 
}

sub render_field {
    my ($self, $form, $field) = @_;
    
}

1;
package Form::Sensible::Renderer::HTML;

use Moose; 
use namespace::autoclean;
use Template;
use Data::Dumper;
use Form::Sensible::Renderer::HTML::RenderedForm;

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
    default     => sub {
                              return {
                                      INCLUDE_PATH => [ File::ShareDir::dist_dir('Form-Sensible') . '/templates/' ]
                              }; 
                         },
    lazy        => 1,
);

## if template is provided, it will be re-used.  
## otherwise, a new one is generated for each form render.
has 'template' => (
    is          => 'rw',
    isa         => 'Template',
);

has 'default_options' => (
    is          => 'rw',
    isa         => 'HashRef',
    required    => 1,
    default     => sub { return {}; },
    lazy        => 1,
);


sub render {
    my ($self, $form, $stash_prefill, $options) = @_;
    
    my $template_options = $self->default_options;
    
    # steps
    # use or create Template object with options
    # merge stash prefill
    # create RenderedForm object
    # setup RenderedForm object
    # return renderedForm object

    if (!defined($stash_prefill)) {
        $stash_prefill = {};
    }
    my $form_specific_stash = { %{$stash_prefill} };
    
    my $template = $self->template;
    
    ## if there is no $self->template - we have to 
    ## create one, but we don't keep it if we create it,
    ## we just use it for this render.
    if (!defined($template)) {
        $template = $self->new_template();
    }
    
    my %args = (
                    template => $template,
                    form => $form,
                    stash => $form_specific_stash,
                );
                
    if (ref($options) eq 'HASH') {
        foreach my $key (keys %{$options}) {
            $args{$key} = $options->{$key};
        }
    }
    
    ## take care of any subforms we have in this form.
    my $subform_init_hash = { %args };
    $args{'subform_renderers'} = {};
    foreach my $fieldname (@{$form->field_order}) {
        my $field = $form->field($fieldname);
        if ($field->DOES('Form::Sensible::Field::SubForm')) {
            $subform_init_hash->{'form'} = $field->form;
            print "FOO!! $fieldname\n";
            $args{'subform_renderers'}{$fieldname} = Form::Sensible::Renderer::HTML::RenderedForm->new( $subform_init_hash );
            #print Dumper($args{'subform_renderers'}{$fieldname});
        }
    }
    
    my $rendered_form = Form::Sensible::Renderer::HTML::RenderedForm->new( %args );
    
    return $rendered_form;
}

# create a new Template instance with the provided options. 
sub new_template {
    my ($self) = @_;
    
    return Template->new( $self->tt_config );
}

__PACKAGE__->meta->make_immutable;
1;
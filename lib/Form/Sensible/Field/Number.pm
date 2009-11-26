package Form::Sensible::Field::Number;

use Moose;
extends 'Form::Sensible::Field';

has 'integer_only' => (
    is          => 'rw',
    isa         => 'Bool',
    required    => 1,
    default     => 0,
);

has 'lower_bound' => (
    is          => 'rw',
    isa         => 'Num',
    required    => 0,
);

has 'upper_bound' => (
    is          => 'rw',
    isa         => 'Num',
    required    => 0,
);

has 'step' => (
    is          => 'rw',
    isa         => 'Num',
    required    => 0,
);


sub validate {
    my ($self) = @_;
    
    if (defined($self->lower_bound) && $self->value < $self->lower_bound) {
        return $self->display_name . " is lower than the minimum allowed value";
    }
    if (defined($self->upper_bound) && $self->value > $self->upper_bound) {
        return $self->display_name . " is higher than the maximum allowed value";
    }
    if ($self->integer_only && $self->value != int($self->value)) {
        return $self->display_name . " must be an integer.";
    }
    
    ## we ran the gauntlet last check is to see if value is in step.
    if (defined($self->step) && !$self->in_step()) {

        return $self->display_name . " must be a multiple of " . $self->step;
    }
}


## this is used when generating a slider or select of valid values.
sub generate_range_by_step {
    my ($self, $step, $lower_bound, $upper_bound) = @_;
    
    if (!$step) {
        $step = $self->step || 1;
    } 
    if (!defined($lower_bound)) {
        $lower_bound = $self->lower_bound;
    }
    if (!defined($upper_bound)) {
        $upper_bound = $self->upper_bound;
    }
    
    my $value = $lower_bound;
    
    ## this check ensures that we start with a value that is within our
    ## bounds.  If $self->lower_bound does not lie on a step boundry, 
    ## and we generated all our numbers from lower_bound, we would be
    ## producing a bunch of options that were always invalid. 
    ## Technically speaking, we shouldn't have a lower bound that is invalid
    ## but who are we kidding?  It will happen.
    
    if (!$self->in_step($lower_bound, $step)) {
        # lower bound doesn't lie on a step boundry.  Bump $div by 1 and 
        # multiply by step.  Should be the first value that lies above our
        # provided bound.
        my $div = $value / $step;
        
        $value = ($div+1) * $step;
    }
    
    my @vals;
    while ($value <= $upper_bound) {
        push @vals, $value;
        $value+= $step;
    }
    return @vals;
}

sub in_step {
    my ($self, $value, $step) = @_;
    
    if (!$step) {
        $step = $self->step;
    }
    if (!defined($value)) {
        $value = $self->value;
    }
    ## we have to do the step check this way, because % will not deal with
    ## a fractional step value.
    my $div = $value / $step;
    return ($div == int($div));
    
}

sub get_additional_configuration {
    my $self = shift;
    
    return { 
                'step'          => $self->step,
                'lower_bound'   => $self->lower_bound,
                'upper_bound'   => $self->upper_bound,
                'integer_only'  => $self->integer_only
           };

}
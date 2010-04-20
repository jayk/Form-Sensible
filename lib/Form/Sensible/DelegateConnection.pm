package Form::Sensible::DelegateConnection;

use Moose;
use Moose::Util::TypeConstraints;

coerce 'Form::Sensible::DelegateConnection' => from 'HashRef' => via { Form::Sensible::DelegateConnection->new( %{$_} ) };


## set up the delegate_function by default to call $target->$target_method;
has 'delegate_function' => (
    is          => 'rw',
    isa         => 'CodeRef',
    required    => 1,
    default     => sub { 
                         my $self = shift;
                         my $target = $self->target;  
                         my $target_method = $self->target_method;
                         return sub { return $target->$target_method(@_); }
                    },
    lazy        => 1,
);

has 'target' => (
    is          => 'rw',
    isa         => 'Object',
    weak_ref    => 1,
    # additional options
);

has 'target_method' => (
    is          => 'rw',
    isa         => 'Str',
);


sub call {
    my $self = shift;
    my $callingobject = shift;
    #die "asplode!";
    print STDERR "Delegate Being Called\n";

    return $self->delegate_function->($callingobject,  @_);
}


__PACKAGE__->meta->make_immutable;

1;
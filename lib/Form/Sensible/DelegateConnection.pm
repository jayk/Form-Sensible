package Form::Sensible::DelegateConnection;

use Moose;
use Moose::Util::TypeConstraints;
use Data::Dumper;

## This overloads our object to be treated as a method call to 'call' if accessed directly as a sub ref.
use overload q/&{}/ => sub { my $self = shift; return sub { $self->call(@_) } };

Moose::Exporter->setup_import_methods(
      as_is     => [ 'FSConnector', \&Form::Sensible::DelegateConnection::FSConnector ]  
);

coerce 'Form::Sensible::DelegateConnection' => from 'HashRef' => via { Form::Sensible::DelegateConnection->new( %{$_} ) };
coerce 'Form::Sensible::DelegateConnection' => from 'ArrayRef' => via { return FSConnector( @{$_} ); };
coerce 'Form::Sensible::DelegateConnection' => from 'CodeRef' => via { return FSConnector( $_ ); };

has 'delegate_function' => (
    is          => 'rw',
    isa         => 'CodeRef',
    required    => 1,
);

sub call {
    my $self = shift;
    my $callingobject = shift;
    #die "asplode!";
    #print STDERR "Delegate Being Called\n";
    
    return $self->delegate_function->($callingobject,  @_);
}

# creates a delegate connection 
sub FSConnector {
    my $function = shift;
    if (ref($function) eq 'CODE') {
        if ($#_ > -1) {
            my $args = [ @_ ];
            return Form::Sensible::DelegateConnection->new( delegate_function => sub { return $function->(@_, @{$args}) } );
        } else {
            return Form::Sensible::DelegateConnection->new( delegate_function => $function );
        }
    } else {
        my $object = $function;
        my $method_name = shift;

        my $args = [ @_ ];
        return Form::Sensible::DelegateConnection->new( delegate_function => sub { 
                                                                                    return $object->$method_name(@_, @{$args}); 
                                                                                 });
    }
}

__PACKAGE__->meta->make_immutable;

1;
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

=head1 NAME

Form::Sensible::DelegateConnection - Represents a connection between one object and another

=head1 SYNOPSIS

=head1 DESCRIPTION

Form::Sensible::DelegateConnection is an object that represents a connection
between one object and another.  In Form::Sensible when an object can have
its behavior customized by another object, a Delegate, a C<DelegateConnection>
object is usually used to create the link between the two objects.



=head1 ATTRIBUTES

=over 8

=item C<delegate_function>

=back

I<The following attributes are set during normal operating of the Form object, and do not
need to be set manually.  They may be overridden, but if you don't know exactly what 
you are doing, you are likely to run into very hard to debug problems.>

=back

=head1 METHODS

=over 8

=item C<new( %options )>

Creates a new Form object with the provided options.  All the attributes above may be passed.

=back

=head1 AUTHOR

Jay Kuri - E<lt>jayk@cpan.orgE<gt>

=head1 SPONSORED BY

Ionzero LLC. L<http://ionzero.com/>

=head1 SEE ALSO

L<Form::Sensible>

=head1 LICENSE

Copyright 2010 by Jay Kuri E<lt>jayk@cpan.orgE<gt>

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
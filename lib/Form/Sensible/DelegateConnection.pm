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

 sub the_options {
    my $calling_object = shift;
    
    # do stuff to get options and return them
 }
 
 ## calls the_options when the delegate is invoked
 my $options_delegate = FSConnector( \&the_options );
 
 ## OR --
 
 my $options_delegate = FSConnector( sub { 
                                            my $calling_object = shift;
                                            
                                            ## do stuff to get options and return them
                                         } );
 
 
 ## OR --
 
 my $data_source_object = Data::Source->new(...);
 
 
 ## calls $data_source_object->get_option_data($calling_object, ...); when the delegate is invoked
 ## Automatically captures your $data_source_object in a closure.
 
 my $options_delegate = FSConnector( $data_source_object, "get_option_data");
 
 ## OR --
 
 my $options_delegate = Form::Sensible::DelegateConnection->new( delegate_function => \&the_options );
 




=head1 DESCRIPTION

Form::Sensible::DelegateConnection is an object that represents a connection
between one object and another.  In Form::Sensible when an object can have
its behavior customized by another object, a Delegate, a C<DelegateConnection>
object is usually used to create the link between the two objects.  See 
L<Form::Sensible::Delegation> for more information on how DelegateConnections
are used within Form::Sensible.

=head1 ATTRIBUTES

=over 8

=item C<delegate_function($calling_object, $optional_additional_arguments, ...  )>

The C<delegate_function> refers to a function that will be run when this delegate
connection is used.  In most cases you will not access this attribute directly, 
preferring the C<FSConnector()> method, though if you are into deep voodoo, you may.

=back

=head1 METHODS

=over 8

=item C<new( %options )>

Creates a new DelegateConnection object with the provided options.  All the attributes above may be passed.

=back


=head1 FUNCTIONS

=over 8

=item C<FSConnector(...)>

The FSConnector function is available if you have C<use>d either C<Form::Sensible> 
or C<Form::Sensible::DelegateConnection>.  It is used to easily create a C<Form::Sensible::DelegateConnection> 
object in-place.  You can call it two ways, first, passing a code ref:

 
 # instead of:
 my $connection = Form::Sensible::DelegateConnection->new( delegate_function => sub { ... } );
 
 # this does the same thing:
 
 my $connection = FSConnector( sub { ... } );
 
This is a modest savings in typing, but can be very convenient when you are
defining a number of delegates during form creation, for example.

The C<FSConnector( ... )> is particularly useful when linking a delegate
connection to a method on an object. This method looks like this:

 my $connection = FSConnector( $object, 'method_to_call');
 
When used this way, The C<FSConnector> routine will create a subroutine ref
for you automatically capturing the passed object in a closure. Again, you can
do this yourself, but this makes your setup code a lot clearer.

As a further benefit, both methods will take additional args which will be
passed to the function or method after the args passed by the calling object:

 my $connection = FSConnector( $object, 'method_to_call', 'additional','args');
 
This can be useful, for example, when you are using the same object / method
repeatedly, but need slightly different information in each case.


=back

=head1 AUTHOR

Jay Kuri - E<lt>jayk@cpan.orgE<gt>

=head1 SPONSORED BY

Ionzero LLC. L<http://ionzero.com/>

=head1 SEE ALSO

L<Form::Sensible>
L<Form::Sensible::Delegation>

=head1 LICENSE

Copyright 2010 by Jay Kuri E<lt>jayk@cpan.orgE<gt>

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
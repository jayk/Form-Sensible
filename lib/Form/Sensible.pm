package Form::Sensible;

use Moose;

our $VERSION = "0.10014";

## This module should create a multi-purpose 'factory' type object which 
## will provide fields / forms / etc. of the types based on it's configuration.
## this allows the code to simply work with an object and ask for fields
## and it will produce objects of the correct type - for example, if the form
## is to be used in a wxWidgets application, $sensible->field would produce 
## a Perl object appropriate for display in a wxWidget application, where the
## same call would produce an HTML field if the $sensible object was configured
## to work with HTML.



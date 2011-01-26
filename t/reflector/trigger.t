use strict;
use warnings;
use Test::More;
use Form::Sensible;
use FindBin;
use lib "$FindBin::Bin/../lib";
use lib "t/lib";
use MockReflector;
use Data::Dumper;

my $reflector = MockReflector->new( with_trigger => 1 );
my $form      = $reflector->reflect_from(undef,  { form => { name => 'test' } });
warn Dumper $form;

done_testing();

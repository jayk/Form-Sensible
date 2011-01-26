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
my $form = $reflector->reflect_from( undef, { form => { name => 'test' } } );
warn "Form " . Dumper $form;
my $expected = Form::Sensible->create_form(
    {
        name   => "test",
        fields => [
            {
                field_class => 'Text',
                name        => 'field1',
                validation  => { regex => qr/^(.+){3,}$/ },
            },
            {
                field_class => 'FileSelector',
                name        => 'field2',
                validation  => {},               # wtf do we validate here?
            },
            {
                field_class => 'Text',
                name        => 'field3',
                validation  => {
                    regex =>
                      qr/^(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})$/,
                },
            },
            {
                field_class => 'Trigger',
                name        => 'submit',
            }
        ],
    }
);
is_deeply( $form, $expected, "forms compare correctly" );
done_testing();

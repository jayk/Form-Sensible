use Test::More;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Data::Dumper;
use Form::Sensible;

use Form::Sensible::Form;

my $lib_dir = $FindBin::Bin;
my @dirs = split '/', $lib_dir;
pop @dirs;
$lib_dir = join('/', @dirs);

sub the_options {
    return [ map { name => $_, value => "foo_" .$_ }, qw/ five options are very good /];
}

sub has_option {
    my ($array, $valuetolookfor) = @_;
    
    foreach my $item (@{$array}) {
        if ($item->{'value'} eq $valuetolookfor) {
            return 1;
        }
    }
    return 0;
}

############ same thing - only the 'flat' way.

my $form = Form::Sensible->create_form( {
                                            name => 'test',
                                            fields => [
                                                         { 
                                                            field_class => 'Select',
                                                            name => 'choices',
                                                            options => the_options()
                                                         },
                                                      ],
                                        } );

my $select_field = $form->field('choices');

ok(has_option($select_field->get_options, 'foo_five'), "Has options we expect from field creation");
ok(!has_option($select_field->get_options, 'white'), "Doesn't have option we haven't added yet.");

$select_field->add_option('wheat', 'Wheat Bread');
$select_field->add_option('white', 'White Bread');
$select_field->add_option('sour', 'Sourdough Bread');

ok(has_option($select_field->get_options, 'white'), "Has options we added programmatically");

$select_field->value('white');

ok($select_field->validate() eq 0, "Valid option passes validation.");

$select_field->value('junk');


ok(grep(/invalid/, $select_field->validate()), "Invalid option fails validation.");

done_testing();

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

############ same thing - only the 'flat' way.

my $form = Form::Sensible->create_form( {
                                            name => 'test',
                                            fields => [
                                                         { 
                                                            field_class => 'Text',
                                                            name => 'username',
                                                            validation => {  regex => '^[0-9a-z]*$'  }
                                                         },
                                                         {
                                                             field_class => 'Text',
                                                             name => 'password',
                                                             render_hints => {  field_type => 'password' }
                                                         },
                                                         {
                                                             field_class => 'Trigger',
                                                             name => 'submit'
                                                         }
                                                      ],
                                        } );

print STDERR "***********\n";
$form->set_values({ username => 'test', password => 'whee' });

print Dumper($form->get_all_values());
exit;

## here we should check these fields
is_deeply ({ username => 'test', password => 'test' } , { username => $form->field('username')->value, password => $form->field('password')->value }, 'Additional values on single-value fields are ignored');

## here we should add some field values
$form->set_values({ username => 'test', password => 'test' });

## here we should check these fields
is_deeply ({ username => 'test', password => 'test' } , { username => $form->field('username')->value, password => $form->field('password')->value }, 'Setting Values behaves properly');

## here we should make sure proper validation passes
my $validation_result = $form->validate();
is($validation_result->is_valid, 1, "Validates okay");

## here we should make sure improper validation is handled properly, aka fail for
## non-passing data
$form->set_values({ username => '*&#*&@)(*&)', password => 'test' });
is_deeply ({ username => '*&#*&@)(*&)', password => 'test' } , { username => $form->field('username')->value, password => $form->field('password')->value });

$validation_result = $form->validate();
isnt($validation_result->is_valid, 1, "Validation fails");

## here we should render the form, and make sure stuff lines up properly

done_testing();

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
    return map { name => $_, value => "foo_" .$_ }, qw/ five options are very good /;
}

############ same thing - only the 'flat' way.

$form = Form::Sensible->create_form( {
                                            name => 'test',
                                            fields => [
                                                         { 
                                                            field_class => 'Select',
                                                            name => 'choices',
                                                            #options_delegate => { delegate_function => sub { return the_options(); }}
                                                         },
                                                      ],
                                        } );

my $select_field = $form->field('choices');
#$field->options_delegate(Form::Sensible::DelegateConnection->new({
#    source => $field,
#    delegate_function => sub { return the_options(); }
#}));

$select_field->add_option('wheat', 'Wheat Bread');
$select_field->add_option('white', 'White Bread');
$select_field->add_option('sour', 'Sourdough Bread');

print Dumper($select_field->options());

$select_field->options_delegate(Form::Sensible::DelegateConnection->new({
    delegate_function => sub { return the_options(); }
}));

print Dumper($select_field->options());

#print Dumper($select_field->get_options());

#print Dumper($form->flatten());

## here we should render the form, and make sure stuff lines up properly

done_testing();

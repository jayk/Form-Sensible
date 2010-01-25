use Test::More;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Form::Sensible::Form;
use Form::Sensible::Field::Text;
use Form::Sensible::Renderer::Dump;

my $form = Form::Sensible::Form->new(name=>'test');
my $textarea = Form::Sensible::Field::Text->new(name=>'test_field', validation => { regex => qr/^[0-9a-z]*$/  });
$form->add_field($textarea);
my $dumper = Form::Sensible::Renderer::Dump->new(form=>$form);
my %validation = $dumper->build_hoh;
my %check_against =  (
	'test' => {
	             'validation' => {
	                               'regex' => qr/(?-xism:^[0-9a-z]*$)/
	                             },
	             'field_name' => 'test_field'
	           }
);

is_deeply(\%check_against, \%validation);
done_testing();
use Test::More;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Data::Dumper;
use Form::Sensible::Form;
use Form::Sensible::Field::Text;
use Form::Sensible::Field::Number;
use Form::Sensible::Field::Trigger;
use Form::Sensible::Renderer::HTML;

my $form = Form::Sensible::Form->new(name=>'test');
my $textarea = Form::Sensible::Field::Text->new(name=>'test_field', validation => { regex => qr/^[0-9a-z]*$/  });
$form->add_field($textarea);
$form->add_field(Form::Sensible::Field::Number->new(name=>'a_number', validation => { regex => qr/^[0-9]*$/  }));
$form->add_field(Form::Sensible::Field::Trigger->new(name=>'submit'));


my $renderer = Form::Sensible::Renderer::HTML->new(tt_config => { INCLUDE_PATH => [ '/home/jayk/Development/projects/Form-Sensible/share/templates' ] });

my $renderedform = $renderer->render($form);

print join("\n", $renderedform->start, $renderedform->messages, $renderedform->fields, $renderedform->end) . "\n";
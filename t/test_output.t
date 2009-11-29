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
$form->add_field(Form::Sensible::Field::Number->new(
                                                        name=>'another_number',
                                                        lower_bound => 18,
                                                        upper_bound => 249,
                                                        step => 10, 
                                                        validation => { regex => qr/^[0-9]*$/  },
                                                        render_hints => { field_type => 'select'},
                                                    ));
        

$form->add_field(Form::Sensible::Field::Trigger->new(name=>'submit'));
$form->field('a_number')->value(17);
$form->field('another_number')->value(230);
$form->field('another_number')->value(220);



my $dir = $FindBin::Bin;
my @dirs = split '/', $dir;
pop @dirs;
$dir = join('/', @dirs);

my $renderer = Form::Sensible::Renderer::HTML->new(tt_config => { INCLUDE_PATH => [ $dir . '/share/templates' ] });

my $renderedform = $renderer->render($form);

print join("\n", $renderedform->start('/do_stuff'), $renderedform->messages, $renderedform->fields, $renderedform->end) . "\n";
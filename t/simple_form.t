use Test::More;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Data::Dumper;
use Form::Sensible;

use Form::Sensible::Form;
use Form::Sensible::Renderer::HTML;

my $lib_dir = $FindBin::Bin;
my @dirs = split '/', $lib_dir;
pop @dirs;
$lib_dir = join('/', @dirs);


    my $form = Form::Sensible::Form->new(name=>'test');
    
    my $username_field = Form::Sensible::Field::Text->new(  name=>'username', validation => { regex => qr/^[0-9a-z]*$/  });
    $form->add_field($username_field);
    
    my $password_field = Form::Sensible::Field::Text->new(  name=>'password',
                                                            render_hints => { field_type => 'password' } );
    $form->add_field($password_field);
    
    my $submit_button = Form::Sensible::Field::Trigger->new( name => 'submit' );
    $form->add_field($submit_button);
    
    my $renderer = Form::Sensible::Renderer::HTML->new(tt_config => { INCLUDE_PATH => [ $lib_dir . '/share/templates' ] });
     
    my $output = $renderer->render($form)->complete;
    
    ############ same thing - only the 'flat' way.
    
    my $form = Form::Sensible->create_form( {
                                                name => 'test',
                                                fields => [
                                                             { 
                                                                field_class => 'Text',
                                                                name => 'username',
                                                                validation => {  regex => '^[0-9a-z]*'  }
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

    my $renderer2 = Form::Sensible::Renderer::HTML->new(tt_config => { INCLUDE_PATH => [ $lib_dir . '/share/templates' ] });

    my $output_2 = $renderer->render($form)->complete;
    
ok( $output eq $output_2, "flat creation and programmatic creation produce the same results");

done_testing();

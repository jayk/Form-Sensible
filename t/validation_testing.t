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



$form = Form::Sensible->create_form( {
                                            name => 'test',
                                            fields => [
                                                         { 
                                                            field_class => 'Text',
                                                            name => 'string',
                                                            validation => {  regex => '^[0-9a-z]*$'  }
                                                         },
                                                         { 
                                                            field_class => 'Number',
                                                            name => 'numeric_step',
                                                            integer_only => 1,
                                                            lower_bound => 10,
                                                            upper_bound => 100,
                                                            step => 5,
                                                         },
                                                         { 
                                                            field_class => 'Number',
                                                            name => 'numeric_nostep',
                                                            integer_only => 0,
                                                            lower_bound => 10,
                                                            upper_bound => 200,
                                                            validation => { 
                                                                            code => sub { 
                                                                                            ## number can not be 172.
                                                                                            ## we don't like 172.
                                                                                            my $value = shift;
                                                                                            my $field = shift;
                                                                                            if ($value == 172) {
                                                                                                return "We don't like 172.";
                                                                                            } else {
                                                                                                return 0;
                                                                                            }
                                                                                        }
                                                                         }
                                                         },

                                                      ],
                                        } );
                                    
## first, success     
$form->set_values({ 
                    string => 'a2z0to9',
                    numeric_step => 25,
                    numeric_nostep => 122.7
                  });
                  
my $validation_result = $form->validate();

ok( $validation_result->is_valid(), "valid forms values are considered valid");

## fail on numeric_step
$form->set_values({ 
                    string => 'a2z0to9',
                    numeric_step => 26,
                    numeric_nostep => 122.7
                  });

$validation_result = $form->validate();

ok( !$validation_result->is_valid(), "Form is invalid with invalid field");

like( $validation_result->error_fields->{numeric_step}[0], qr/multiple of/, "Number field value is invalid based on step");

## fail on fraction
$form->set_values({ 
                    string => 'a2z0to9',
                    numeric_step => 25.7,
                    numeric_nostep => 122.7
                  });

$validation_result = $form->validate();

like( $validation_result->error_fields->{numeric_step}[0], qr/an integer/,  "Number field value is invalid: fraction in integer only field");


## fail on too high
$form->set_values({ 
                    string => 'a2z0to9',
                    numeric_step => 126,
                    numeric_nostep => 122.7
                  });

$validation_result = $form->validate();

like( $validation_result->error_fields->{numeric_step}[0], qr/maximum allowed value/,  "Number field value is invalid: over maximum value");

## fail on too low 
$form->set_values({ 
                    string => 'a2z0to9',
                    numeric_step => 6,
                    numeric_nostep => 122.7
                  });

$validation_result = $form->validate();

like( $validation_result->error_fields->{numeric_step}[0], qr/minimum allowed value/,  "Number field value is invalid: under minimum value");

## fail on code ref
$form->set_values({ 
                    string => 'a2z0to9',
                    numeric_step => 25,
                    numeric_nostep => 172
                  });

$validation_result = $form->validate();

like( $validation_result->error_fields->{numeric_nostep}[0], qr/We don't/,  "Number field value is invalid: coderef");

## fail on code ref
$form->set_values({ 
                    string => 'ZZZ0to9',
                    numeric_step => 25,
                    numeric_nostep => 172
                  });

$validation_result = $form->validate();

like( $validation_result->error_fields->{string}[0], qr/invalid/,  "String field value is invalid: regex");


done_testing();
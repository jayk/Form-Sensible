package Form::Sensible::Renderer::Dump;
use Moose;
use namespace::autoclean;
use Data::Dumper;

has 'form' => (
	is => 'ro',
	isa => 'Form::Sensible::Form',
	required => 1,
);

sub build_hoh {
	my $self = shift;
	my %params;
	my $form = $self->form;
	
	for my $fieldname ( $form->fieldnames ) {
		my $name  = $form->name;
		my $field = $form->field($fieldname);
	
		%params = (
			$name => {
			    field_name => $fieldname,
	            validation => {
		        	%{$field->validation}
				}
			}
		);
	
	}
	
	return %params;
}

sub dump_hoh {
	my $self = shift;
	my %hoh = $self->build_hoh;
	
	print Dumper(\%hoh);
}

1;
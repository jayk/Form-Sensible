package Form::Sensible::Renderer::TestDump;
use Moose;
use namespace::autoclean;

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
		my $field = $form->field($fieldname);
		if ( $field->value ) {
			
			$params{'field_name'} = $fieldname;
			$params{$fieldname}{'value'} = $field->value;
		 	$params{$fieldname}{'validators'} = $field->field_validators->{$fieldname};
			
		}
	}
	
	return %params;
}

sub dump_hoh {
	my $self = shift;
	my %hoh = $self->build_hoh;
	
	for ( sort keys %hoh ) {
		print "$_ =>\n";
		my $subkey = $hoh{$_};
		print "\t $_ => $subkey->{$_}\n" for sort keys %$subkey;
	}
}

1;
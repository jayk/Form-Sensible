package Form::Sensible::Form::Reflector::DBIC;
use Moose; 
use namespace::autoclean;

has 'schema' => (
	is           => 'ro',
	isa      	 => 'DBIx::Class::Schema',
	required     => 1,
	lazy_builder => 1,
);

1;
package Form::Sensible::Reflector::DBIC::TypeMap;
use Moose;
use namespace::clean;
use Regexp::Common;

## Start with the basic SQL types found in common RDBMSes pertinent to forms
## primary keys are ignored as form types
##############################################################################
## NAME			DBMS	DBMS TYPE			FORM TYPE
##############################################################################
## bool			Pg		number/truth		checkbox?
## bigint		Pg		number				textfield with a bigint maxlength and \d regex?
## character	Pg		letter				textfield with a char/varchar size constraint and \w regex?
## date			Pg		date				$js_framework date chooser
## float8		Pg		number				textfield requiring a decimal and precision of 8
## integer		Pg		number				textfield with an int maxlength and a \d regex?	
## macaddr		Pg		MAC address			textfield with a macaddress regex
## money		Pg		currency			textfield with money constraints
## numeric		Pg		decimal				textfield with a decimal constraint and precision constraint
## real			Pg		number				textfield requiring a decimal and a precision of 4
## smallint		Pg		number				textfield with smallint maxlength
## text			Pg		text				textarea with row/col constraints
## timestamp	Pg		date				$js_framework date chooser
## uuid			Pg		uuid				textfield with UUID like regex
## enum			Pg		enumerated			select dropdown
##############################################################################
## bit			MySQL	number				checkbox?
## tinyint		MySQL	number				textfield with a maxlength of tinyint
## bool			MySQL	number/truth		checkbox
## smallint		MySQL	number				textfield with a maxlength of smallint
## mediumint	MySQL	number				textfield with a maxlength of mediumint
## int			MySQL	number				textfield with a maxlength of int
## bigint		MySQL	number				textfield with a maxlength of bigint
## float		MySQL	number				texfield requiring a decimal and precision constraints
## (etc for numerics)
## date(time)	MySQL	date				$js_framework date widget
## timestamp	MySQL	date				''
## (var)char	MySQL	date				textfield with a maxlength specified and regex \w?
## *blob		MySQL	blob				??? file upload?
## text			MySQL	text				textarea with row/col constraints
## enum 		MySQL	enumerated			select dropdown
## set			MySQL	set					''
##############################################################################
## integer		SQLite	number				textfield with a maxlength of integer
## real			SQLite	number				textfield with a floating point constraint (see above)
## text			SQLite	text				textfield with a maxlength constraint of text size
## blob			SQLite	*					file upload? textarea? will need to be specified, default file
##############################################################################
## Informix
## Sybase
## MSSQL
## Oracle

1;
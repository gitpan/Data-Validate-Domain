# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Data-Validate-Domain.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 22;
BEGIN { use_ok('Data::Validate::Domain', qw(is_domain is_domain_label) ) };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

is	('www',		is_domain_label('www'),		'is_domain_label www');
is	('frii',	is_domain_label('frii'),	'is_domain_label frii');
is	('com',		is_domain_label('com'),		'is_domain_label com');
is	('128',		is_domain_label('128'),		'is_domain_label 128');
isnt	('',		is_domain_label(''),		'is_domain_label ');
isnt	('-bob',	is_domain_label('-bob'),	'is_domain_label -bob');
#70 character label
isnt	('1234567890123456789012345678901234567890123456789012345678901234567890',	
	is_domain_label('1234567890123456789012345678901234567890123456789012345678901234567890'),	
	'is_domain_label 1234567890123456789012345678901234567890123456789012345678901234567890');

is	('www.frii.com',	is_domain('www.frii.com'),	'is_domain www.frii.com');
is	('frii.com',		is_domain('frii.com'),		'is_domain frii.com');
is	('test-frii.com',	is_domain('test-frii.com'),	'is_domain test-frii.com');
is	('aa.com',		is_domain('aa.com'),		'is_domain aa.com');
is	('A-A.com',		is_domain('A-A.com'),		'is_domain A-A.com');
isnt	('216.17.184.1',	is_domain('216.17.184.1'),	'is_domain 216.17.184.1');
isnt	('test_frii.com',	is_domain('test_frii.com'),	'is_domain test_frii.com');
isnt	('.frii.com',		is_domain('.frii.com'),		'is_domain .frii.com');
isnt	('www.frii.com.',	is_domain('www.frii.com.'),	'is_domain www.frii.com.');
isnt	('-www.frii.com',	is_domain('-www.frii.com'),	'is_domain -www.frii.com');
isnt	('a',			is_domain('a'),			'is_domain a');
isnt	('.',			is_domain('.'),			'is_domain .');
isnt	('com.',		is_domain('com.'),		'is_domain com.');
#280+ character domain
isnt	('123456789012345678901234567890123456789012345678901234567890.1234567890123456789012345678901234567890.12345678901234567890123456789012345678901234567890.12345678901234567890123456789012345678901234567890.12345678901234567890123456789012345678901234567890.123456789012345678901234567890.com',	
	is_domain('123456789012345678901234567890123456789012345678901234567890.1234567890123456789012345678901234567890.12345678901234567890123456789012345678901234567890.12345678901234567890123456789012345678901234567890.12345678901234567890123456789012345678901234567890.123456789012345678901234567890.com'),	
	'is_domain 123456789012345678901234567890123456789012345678901234567890.1234567890123456789012345678901234567890.12345678901234567890123456789012345678901234567890.12345678901234567890123456789012345678901234567890.12345678901234567890123456789012345678901234567890.123456789012345678901234567890.com');


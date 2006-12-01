# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Data-Validate-Domain.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 44;
BEGIN { use_ok('Data::Validate::Domain', qw(is_hostname is_domain is_domain_label) ) };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

is	('www',		is_domain_label('www'),		'is_domain_label www');
is	('w-w',		is_domain_label('w-w'),		'is_domain_label w-w');
is	('frii',	is_domain_label('frii'),	'is_domain_label frii');
is	('com',		is_domain_label('com'),		'is_domain_label com');
is	('COM',		is_domain_label('COM'),		'is_domain_label COM');
is	('128',		is_domain_label('128'),		'is_domain_label 128');
is	(undef,		is_domain_label(''),		'is_domain_label ');
is	(undef,		is_domain_label('-bob'),	'is_domain_label -bob');
#70 character label
isnt	('1234567890123456789012345678901234567890123456789012345678901234567890',	
	is_domain_label('1234567890123456789012345678901234567890123456789012345678901234567890'),	
	'is_domain_label 1234567890123456789012345678901234567890123456789012345678901234567890');

is	('www.frii.com',	is_domain('www.frii.com'),	'is_domain www.frii.com');
is	(undef,			is_domain('www.frii.com.'),	'is_domain www.frii.com.');
is	(undef,			is_domain('www.frii.com...'),	'is_domain www.frii.com...');
is	(undef,			is_domain('www.frii.lkj'),	'is_domain www.frii.lkj');
is	('frii.com',		is_domain('frii.com'),		'is_domain frii.com');
is	('test-frii.com',	is_domain('test-frii.com'),	'is_domain test-frii.com');
is	('aa.com',		is_domain('aa.com'),		'is_domain aa.com');
is	('A-A.com',		is_domain('A-A.com'),		'is_domain A-A.com');
is	('aa.com',		is_hostname('aa.com'),		'is_hostname aa.com');
is	('aa.bb',		is_hostname('aa.bb'),		'is_hostname aa.bb');
is	('aa',			is_hostname('aa'),		'is_hostname aa');
is	(undef,			is_domain('216.17.184.1'),	'is_domain 216.17.184.1');
is	(undef,			is_domain('test_frii.com'),	'is_domain test_frii.com');
is	(undef,			is_domain('.frii.com'),		'is_domain .frii.com');
is	(undef,			is_domain('-www.frii.com'),	'is_domain -www.frii.com');
is	(undef,			is_domain('a'),			'is_domain a');
is	(undef,			is_domain('.'),			'is_domain .');
is	(undef,			is_domain('com.'),		'is_domain com.');
is	(undef,			is_domain('com'),		'is_domain com');
is	(undef,			is_domain('net'),		'is_domain net');
is	(undef,			is_domain('uk'),		'is_domain uk');
is	('co.uk',		is_domain('co.uk'),		'is_domain co.uk');
#280+ character domain
is	(undef,	
	is_domain('123456789012345678901234567890123456789012345678901234567890.1234567890123456789012345678901234567890.12345678901234567890123456789012345678901234567890.12345678901234567890123456789012345678901234567890.12345678901234567890123456789012345678901234567890.123456789012345678901234567890.com'),	
	'is_domain 123456789012345678901234567890123456789012345678901234567890.1234567890123456789012345678901234567890.12345678901234567890123456789012345678901234567890.12345678901234567890123456789012345678901234567890.12345678901234567890123456789012345678901234567890.123456789012345678901234567890.com');
#Some additional tests for options
is	('myhost.frii',		is_domain('myhost.frii', {domain_private_tld => {'frii' => 1}}),	'is_domain myhost.frii w/domain_private_tld option');
is	(undef,		is_domain('myhost.frii'),	'is_domain myhost.frii');
is	('com',		is_domain('com', {domain_allow_single_label => 1}),	'is_domain com w/domain_allow_single_label option');
is	('frii',		is_domain('frii', {domain_allow_single_label => 1, domain_private_tld => {'frii' => 1}}),	'is_domain frii w/domain_private_tld  and domain_allow_single_label option');
is	(undef,		is_domain('frii'),	'is_domain frii');

my $obj = Data::Validate::Domain->new();
is	('co.uk',		$obj->is_domain('co.uk'),		'$obj->is_domain co.uk');

my $private_tld_obj = Data::Validate::Domain->new(
						domain_private_tld => {
									frii	=>	1,
									frii72	=>	1,
									},
					);
is	('myhost.frii',	$private_tld_obj->is_domain('myhost.frii'),	'$private_tld_obj->is_domain myhost.frii');
is	('myhost.frii72',	$private_tld_obj->is_domain('myhost.frii72'),	'$private_tld_obj->is_domain myhost.frii72');

my $private_single_label_tld_obj = Data::Validate::Domain->new(
						domain_allow_single_label => 1,
						domain_private_tld => {
									frii	=>	1,
									},
					);

is	('frii',	$private_single_label_tld_obj->is_domain('frii'),	'$private_single_label_tld_obj->is_domain frii');
is	('FRII',	$private_single_label_tld_obj->is_domain('FRII'),	'$private_single_label_tld_obj->is_domain FRII');
is	('frii.com',	$private_single_label_tld_obj->is_domain('frii.com'),	'$private_single_label_tld_obj->is_domain frii.com');


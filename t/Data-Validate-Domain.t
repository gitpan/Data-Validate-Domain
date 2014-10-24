# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Data-Validate-Domain.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 57;
BEGIN { use_ok('Data::Validate::Domain', qw(is_hostname is_domain is_domain_label) ) };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

is	('www',		is_domain_label('www'),		'is_domain_label www');
is	('w-w',		is_domain_label('w-w'),		'is_domain_label w-w');
is	('neely',	is_domain_label('neely'),	'is_domain_label neely');
is	('com',		is_domain_label('com'),		'is_domain_label com');
is	('COM',		is_domain_label('COM'),		'is_domain_label COM');
is	('128',		is_domain_label('128'),		'is_domain_label 128');
is	(undef,		is_domain_label(''),		'is_domain_label ');
is	(undef,		is_domain_label('-bob'),	'is_domain_label -bob');
#70 character label
isnt	('1234567890123456789012345678901234567890123456789012345678901234567890',	
	is_domain_label('1234567890123456789012345678901234567890123456789012345678901234567890'),	
	'is_domain_label 1234567890123456789012345678901234567890123456789012345678901234567890');

is	('www.neely.cx',	is_domain('www.neely.cx'),	'is_domain www.neely.cx');
is	(undef,			is_domain('www.neely.cx.'),	'is_domain www.neely.cx.');
is	(undef,			is_domain('www.neely.cx...'),	'is_domain www.neely.cx...');
is	(undef,			is_domain('www.neely.lkj'),	'is_domain www.neely.lkj');
is	('neely.cx',		is_domain('neely.cx'),		'is_domain neely.cx');
is	('test-neely.cx',	is_domain('test-neely.cx'),	'is_domain test-neely.cx');
is	('aa.com',		is_domain('aa.com'),		'is_domain aa.com');
is	('A-A.com',		is_domain('A-A.com'),		'is_domain A-A.com');
is	('aa.com',		is_hostname('aa.com'),		'is_hostname aa.com');
is	('aa.bb',		is_hostname('aa.bb'),		'is_hostname aa.bb');
is	('aa',			is_hostname('aa'),		'is_hostname aa');
is	(undef,			is_domain('216.17.184.1'),	'is_domain 216.17.184.1');
is	(undef,			is_domain('test_neely.cx'),	'is_domain test_neely.cx');
is	(undef,			is_domain('.neely.cx'),		'is_domain .neely.cx');
is	(undef,			is_domain('-www.neely.cx'),	'is_domain -www.neely.cx');
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
is	('myhost.neely',		is_domain('myhost.neely', {domain_private_tld => {'neely' => 1}}),	'is_domain myhost.neely w/domain_private_tld option');
is	(undef,		is_domain('myhost.neely'),	'is_domain myhost.neely');
is	('com',		is_domain('com', {domain_allow_single_label => 1}),	'is_domain com w/domain_allow_single_label option');
is	('neely',		is_domain('neely', {domain_allow_single_label => 1, domain_private_tld => {'neely' => 1}}),	'is_domain neely w/domain_private_tld  and domain_allow_single_label option');
is	(undef,		is_domain('neely'),	'is_domain neely');
isnt	('_spf',	is_hostname('_spf'),	'is_hostname("_spf"');
is	('_spf',	is_hostname('_spf', {domain_allow_underscore => 1}),	'is_hostname("_spf", {domain_allow_underscore = 1}');

#precompiled regex format
is	('myhost.neely',		is_domain('myhost.neely', {domain_private_tld => qr/^neely$/}),	'is_domain myhost.neely w/domain_private_tld option - precompiled regex');
is	(undef,			is_domain('myhost.neely', {domain_private_tld => qr/^intra$/}),	'is_domain myhost.neely w/domain_private_tld option - precompiled regex looking for intra');

my $obj = Data::Validate::Domain->new();
is	('co.uk',		$obj->is_domain('co.uk'),		'$obj->is_domain co.uk');

my $private_tld_obj = Data::Validate::Domain->new(
						domain_private_tld => {
									neely	=>	1,
									neely72	=>	1,
									},
					);
is	('myhost.neely',	$private_tld_obj->is_domain('myhost.neely'),	'$private_tld_obj->is_domain myhost.neely');
is	('myhost.neely72',	$private_tld_obj->is_domain('myhost.neely72'),	'$private_tld_obj->is_domain myhost.neely72');
is	(undef,		$private_tld_obj->is_domain('myhost.intra'),	'$private_tld_obj->is_domain myhost.intra');
is	(undef,		$private_tld_obj->is_domain('neely'),	'$private_tld_obj->is_domain neely');

my $private_single_label_tld_obj = Data::Validate::Domain->new(
						domain_allow_single_label => 1,
						domain_private_tld => {
									neely	=>	1,
									},
					);

is	('neely',	$private_single_label_tld_obj->is_domain('neely'),	'$private_single_label_tld_obj->is_domain neely');
is	('NEELY',	$private_single_label_tld_obj->is_domain('NEELY'),	'$private_single_label_tld_obj->is_domain NEELY');
is	('neely.cx',	$private_single_label_tld_obj->is_domain('neely.cx'),	'$private_single_label_tld_obj->is_domain neely.cx');


#precompiled regex format
my $private_tld_obj2 = Data::Validate::Domain->new(
						domain_private_tld => qr/^(?:neely|neely72)$/,
					);
is	('myhost.neely',	$private_tld_obj2->is_domain('myhost.neely'),	'$private_tld_obj2->is_domain myhost.neely');
is	('myhost.neely72',	$private_tld_obj2->is_domain('myhost.neely72'),	'$private_tld_obj2->is_domain myhost.neely72');
is	(undef,		$private_tld_obj2->is_domain('myhost.intra'),	'$private_tld_obj2->is_domain myhost.intra');
is	(undef,		$private_tld_obj2->is_domain('neely'),	'$private_tld_obj2->is_domain neely');

my $allow_underscore_obj = Data::Validate::Domain->new(
						domain_allow_underscore => 1,
					);
is	('_spf.neely.cx',	$allow_underscore_obj->is_domain('_spf.neely.cx'),	'$allow_underscore_obj->is_domain _spf.neely.cx');
is	('_sip._tcp.neely.cx',	$allow_underscore_obj->is_domain('_sip._tcp.neely.cx'),	'$allow_underscore_obj->is_domain _sip._tcp.neely.cx');
is	('_spf',	$allow_underscore_obj->is_hostname('_spf'),	'$allow_underscore_obj->is_domain _spf');

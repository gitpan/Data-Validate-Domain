package Data::Validate::Domain;

use strict;
use warnings;

use Net::Domain::TLD;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Data::Validate::Domain ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	is_domain
	is_hostname
	is_domain_label
);

our $VERSION = '0.02';



=head1 NAME

Data::Validate::Domain - domain validation methods

=head1 SYNOPSIS

  use Data::Validate::Domain qw(is_domain);
  
  if(is_domain($suspect)){
        print "Looks like a domain name";
  } else {
        print "Not a domain name\n";
  }
  

  # or as an object
  my $v = Data::Validate::Domain->new();
  
  die "not a domain" unless ($v->is_domain('domain.com'));

=head1 DESCRIPTION

This module collects domain validation routines to make input validation,
and untainting easier and more readable. 

All functions return an untainted value if the test passes, and undef if
it fails.  This means that you should always check for a defined status explicitly.
Don't assume the return will be true. (e.g. is_username('0'))

The value to test is always the first (and often only) argument.

=head1 FUNCTIONS

=over 4

=cut

# -------------------------------------------------------------------------------

=pod

=item B<new> - constructor for OO usage

  $obj = Data::Validate::Domain->new();

=over 4

=item I<Description>

Returns a Data::Validator::Domain object.  This lets you access all the validator function
calls as methods without importing them into your namespace or using the clumsy
Data::Validate::Domain::function_name() format.

=item I<Arguments>

None

=item I<Returns>

Returns a Data::Validate::Domain object

=back

=cut




sub new{
        my $class = shift;
        
        return bless {}, $class;
}


# -------------------------------------------------------------------------------

=pod

=item B<is_domain> - does the value look like a domain name?

  is_domain($value);
  or
  $obj->is_domain($value);


=over 4

=item I<Description>

Returns the untainted domain name if the test value appears to be a well-formed
domain name. 

=item I<Arguments>

=over 4

=item $value

The potential domain to test.

=back

=item I<Returns>

Returns the untainted domain on success, undef on failure.

=item I<Notes, Exceptions, & Bugs>

The function does not make any attempt to check whether a domain  
actually exists. It only looks to see that the format is appropriate.

A dotted quad (such as 127.0.0.1) is not considered a domain and will return false.
See L<Data::Validate::IP(3)> for IP Validation.

Performs a lookup via Net::Domain::TLD to verify that the TLD is valid for this domain.

Does not consider "domain.com." a valid format.

=item I<From RFC 952>

   A "name" (Net, Host, Gateway, or Domain name) is a text string up
   to 24 characters drawn from the alphabet (A-Z), digits (0-9), minus
   sign (-), and period (.).  Note that periods are only allowed when
   they serve to delimit components of "domain style names".

    No blank or space characters are permitted as part of a
   name. No distinction is made between upper and lower case.  The first
   character must be an alpha character [Relaxed in RFC 1123] .  The last 
   character must not be a minus sign or period.

=item I<From RFC 1035>

    labels          63 octets or less
    names           255 octets or less

    [snip] limit the label to 63 octets or less.

    To simplify implementations, the total length of a domain name (i.e.,
    label octets and label length octets) is restricted to 255 octets or
    less.

=item I<From RFC 1123>

    One aspect of host name syntax is hereby changed: the
    restriction on the first character is relaxed to allow either a
    letter or a digit.  Host software MUST support this more liberal
    syntax.

    Host software MUST handle host names of up to 63 characters and
    SHOULD handle host names of up to 255 characters.


=back

=cut

sub is_domain {
        my $self = shift if ref($_[0]); 
        my $value = shift;
        
        return unless defined($value);

	my $length = length($value);
	return unless ($length > 0 && $length <= 255);
      
	my @bits; 
	foreach my $label (split('\.', $value, -1)) {
		my $bit = is_domain_label($label);	
		return unless defined $bit;
		push(@bits, $bit);
	} 
	#All domains have more then 1 label (frii.com good, com not good)
	return unless (@bits >= 2);

	#require the last value in the last section to be a letter.
	#This lets us catch ip addresses and not consider them a domain
	#and still will let something like this: 216.17.184.1.frii.com to 
	#be considered a domain as it is valid.

	#I don't have an RFC to back this up, but I believe it to be prudent
	my $tld = $bits[$#bits];
	return unless $tld =~ /^[a-zA-Z]+$/;

	#Verify domain has a valid TLD
	return  unless Net::Domain::TLD->exists($tld);
        
        return join('.', @bits);
}

# -------------------------------------------------------------------------------

=pod

=item B<is_hostname> - does the value look like a hostname

  is_hostname($value);
  or
  $obj->is_hostname($value);


=over 4

=item I<Description>

Returns the untainted hostname if the test value appears to be a well-formed
hostname. 

=item I<Arguments>

=over 4

=item $value

The potential hostname to test.

=back

=item I<Returns>

Returns the untainted hostname on success, undef on failure.

=item I<Notes, Exceptions, & Bugs>

The function does not make any attempt to check whether a hostname  
actually exists. It only looks to see that the format is appropriate.

Functions much like is_domain, except that it does not verify whether or
not a valid TLD has been supplied and allows for there to only
be a single component of the hostname (i.e www)

Hostnames might or might not have a valid TLD attached.

=back

=cut

sub is_hostname {
        my $self = shift if ref($_[0]); 
        my $value = shift;

        
        return unless defined($value);

	my $length = length($value);
	return unless ($length > 0 && $length <= 255);

#	return is_domain_label($value) unless $value =~ /\./;  #If just a simple hostname

	#Anything past here has multiple bits in it
	my @bits; 
	foreach my $label (split('\.', $value, -1)) {
		my $bit = is_domain_label($label);	
		return unless defined $bit;
		push(@bits, $bit);
	} 

	#We do not verify TLD for hostnames, as hostname.subhost is a valid hostname

        return join('.', @bits);
	
}

=pod

=item B<is_domain_label> - does the value look like a domain label?

  is_domain_label($value);
  or
  $obj->is_domain_label($value);


=over 4

=item I<Description>

Returns the untainted domain label if the test value appears to be a well-formed
domain label. 

=item I<Arguments>

=over 4

=item $value

The potential ip to test.

=back

=item I<Returns>

Returns the untainted domain label on success, undef on failure.

=item I<Notes, Exceptions, & Bugs>

The function does not make any attempt to check whether a domain label
actually exists. It only looks to see that the format is appropriate.

=cut


sub is_domain_label {
        my $self = shift if ref($_[0]); 
        my $value = shift;
        
        return unless defined($value);

	# bail if we are dealing with more then just a hostname
	return if ($value =~ /\./);
	my $length = length($value);
	my $hostname;
	if ($length == 1) {
          ($hostname) = $value =~ /^([\dA-Za-z])$/;
	} elsif ($length > 1 && $length <= 63) {
          ($hostname) = $value =~ /^([\dA-Za-z][\dA-Za-z\-]*[\dA-Za-z])$/;
	} else {
		return;
	}
	return $hostname;
}

1;
__END__
# 



# -------------------------------------------------------------------------------

=back

=head1 SEE ALSO

B<[RFC 1034] [RFC 1035] [RFC 2181] [RFC 1123]>

=over 4

=item  L<Data::Validate(3)>

=item  L<Data::Validate::IP(3)>

=back


=head1 AUTHOR

Neil Neely <F<neil@frii.net>>.

=head1 ACKNOWLEDGEMENTS 

Thanks to Richard Sonnen <F<sonnen@richardsonnen.com>> for writing the Data::Validate module.

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2005 Neil Neely.  

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.


=cut

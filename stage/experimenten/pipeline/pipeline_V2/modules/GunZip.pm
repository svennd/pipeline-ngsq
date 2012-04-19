# GunZip
# svenn dhert @ sckcen
#
# use :
# if a file is zipped, (.gz) gunzip it & return the base name
# vb: 
	# alfa.txt.gz 	-> alfa.txt
	# beta.txt	-> beta.txt

package GunZip;

use strict;
use warnings;
 
# for logging
require "modules/Log.pm";

our $VERSION = '1.00';
our @EXPORT  = qw(is_gunzip);

sub is_gunzip
{
	my @para	= @_;
	my $file	= $para[0];
	
	# there might be a better method for this but it works.
	# it works. 
	my $ext 	= ($file =~ m/([^.]+)$/)[0];
	my $base 	= ($file =~ m/^(.*?)\.gz$/)[0];
	
	if ($ext eq "gz")
	{
		# depending on bash/linux
		print `gunzip $file`;
		Log::make_entry("gunzipping ${file}");
		return $base;
	}
	return $file;
}

# FileFormat.pm
# svenn dhert @ sckcen

# use
	# FileFormat::get_files('./', 'samm');
	# returns all files in ./ dir having *.samm

package FileFormat;

use strict;
use warnings;
 

our $VERSION = '1.00';
our @EXPORT  = qw(get_files);

sub get_files
{
	my @para	= @_;
	my $dir		= $para[0];
	my $wanted_ext	= $para[1];
	
	my @result;
	my $i = 0;
	
	opendir(my $dh, $dir) || die;
	opendir(MYDIR, $dir) || die;
	
	while(my $file = readdir MYDIR) 
	{
		if ($file eq "." || $file eq "..") {next;}
		my $alfa = (($file =~ m/([^.]+)$/)[0]);
		
		if ($alfa eq $wanted_ext)
		{
			$result[$i] = "$dir/$file";
			$i++;
		}
	}
	return @result;
}

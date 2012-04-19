# Screen.pm
# svenn dhert @ sckcen
#
# use :
# Screen handeling

package Screen;

use strict;
use warnings;

our $VERSION = '1.00';
our @EXPORT  = qw(clean);

sub clean
{
	my @para 	= @_;
	my $os	 	= $para['0'];
	
	if ($os eq "unix")
	{
		system("clear");
	}
	elsif ($os eq "windows")
	{
		system("cls");
	}
	else
	{
		# lets try unix anyways
		system("clear");
	}
}

sub show_done
{
	my @para		= @_;
	our @messages_to_print 	= (@messages_to_print, $para[0]); # add element to existing arr
	my $os	 		= $para['1'];
	
	# clear screen
	clean ($os);
	
	# loop them all
	foreach my $message (@messages_to_print)
	{
		print $message . "\n";
	}
}

# Log.pm
# svenn dhert @ sckcen
#
# use :
# make a proper log

package Log;

use strict;
use warnings;

our $VERSION = '1.00';
our @EXPORT  = qw(make_entry);

sub make_entry
{
    my @para 		= @_;
    my $message 	= $para['0'];
    my $file 		= $para['1'];
    $file 		= 'log/general_log.txt' unless defined $file;
    
    open (LOG_FILE, ">>$file") or die("Could not make log file : " . $file);
    	print LOG_FILE get_time() . " - " . $message . "\n";
    close(LOG_FILE);
}

sub get_time
{
	my @months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
 	my @weekDays = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
 	
 	my ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
 	
 	my $year = 1900 + $yearOffset;
 	my $time = "$hour:$minute:$second, $weekDays[$dayOfWeek] $months[$month] $dayOfMonth, $year";
 	return $time; 
}

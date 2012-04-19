# QualityCheck.pm
# svenn dhert @ sckcen
#
# use :
# Checks the quality of fastaQ file
# And reports if the quality is below (log file)

package QualityCheck;

use strict;
use warnings;

# for logging
require "modules/Log.pm";

our $VERSION = '1.00';
our @EXPORT  = qw(check_quality);

sub check_quality
{
	# config
	my $do_reads 	= 100000; # amount of reads the script will check
	
	#
	my @para 	= @_;
	my $input 	= $para['0'];
	open(FASTQ, $input) or die("file not found. ". $input);
	
	my $count = 1;
	my $total_reads = 0;

	my @scores;
	
	while(<FASTQ>)
	{
		if ($count > $do_reads){last;}
	
		my $current_line = $_;
	
		if ($count % 4 == 0)
		{
			my @chars = split(//, $current_line);
			my $i = 0;
			foreach my $char (@chars)
			{
				my $nr = ord($char);
				my $score = $nr - 66;
			
				$scores[$i] += $score;
				$i++;
			}
			$total_reads++;
		}
		$count++;
	}
	close(FASTQ);
	
	open(RESULT, ">>result/quality_$input") or die("Couldn't not write file result/quality_" . $input);
	my $position = 1;
	foreach my $score (@scores)
	{
		my $point = $score/$total_reads;
		if ( $point < 30 )
		{
			Log::make_entry("Low avg read quality for base " . $position . " @ " . $input . " (" . $point . ")");
		}
		
		print RESULT $point . "\n";
		$position++;
	}
	close(RESULT);
}


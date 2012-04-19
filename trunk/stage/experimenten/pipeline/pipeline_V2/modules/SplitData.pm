# SplitData.pm
# svenn dhert @ sckcen
#
# use :
# Split SAM files into different parameters
# and truncate unmapped reads.

package SplitData;

#use strict; # this won't work cause of line 42 + 59 (problem not resolved)
use warnings;
use POSIX;

# for logging
require "modules/Log.pm";

our $VERSION = '1.00';
our @EXPORT  = qw(split_sam);

sub split_sam
{
	my @para 	= @_;
	my $input 	= $para['0'];
	open(SHIFT_SAM, $input) or die("read error cannot find sam file");

	# stats 
	my $bad_read 	= 0;
	my $total_count	= 0;

	while(<SHIFT_SAM>)
	{
		# store line
		my $current_line = $_;
	
		# making files
		if ($current_line =~ /^\@SQ\tSN:/)
		{
			
			(my $a, my $seq, my $length) = split("\t", $current_line);
			(my $trash, my $sequence) = split(":" , $seq);
			print "\t\t# Found chr/plasmide : " . $sequence . "\n";

			open($sequence, '>>' . $sequence . '.ssam') 
				or die ("Cannot make file : " . $sequence . ".sam");
		}

		# check if no info line (@)
		else
		{
			# split tabbed
			(
				my $qname, 
				my $flag,
				my $rname,
				my @rest
			) = split('\t', $current_line);	

			if ($rname ne "*")
			{
				print $rname $current_line . "\n";
			}
			else
			{
				$bad_read++;
			}
			$total_count++;
		} 
	}

	print "\t\t\t# Amount of reads : " 		. $total_count 	. "\n";
	print "\t\t\t# Reads that cannot be mapped : " 	. $bad_read 	." (" . ceil($bad_read/$total_count) ." %)\n";
	print "\t\t\t# Correct mapped reads : " 	. ($total_count - $bad_read) . "\n\n";

	close(SHIFT_SAM);
}


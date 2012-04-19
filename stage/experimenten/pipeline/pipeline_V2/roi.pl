# svenn dhert @ sckcen
use warnings;
use strict;

# load file
open(INFILE, "NC_007973.ssam") or die("file not found.");

# save file
open(RESULT, ">>ROI") or die("file not found.");

my $count = 0;

while(<INFILE>)
{
	$count++;
	if ($count % 2 == 0){next;}
	
	# store line
	my $current_line = $_;
	
	# split tabbed
	(
		my $qname, 
		my $flag,
		my $rname,
		my $pos,	
		my $mapq,	
		my $cigar,	
		my $NRNM,	
		my $mpos,
		my $size,
		my $SEQ
	) = split('\t', $current_line);	
	# dec flag to bin values
	(
		my $second_read,
		my $first_read,
		my $strand_mate, 	my $strand_quer,
		my $mate_unmapped,	my $quer_unmapped,
		my $proper_mapped,
		my $paired_seq
	) = split(//, dec2bin($flag));
	
	
	if ($proper_mapped == 0)
	{
		if (($pos > 1901000) && ($pos < 1902000))
		{
			print $pos. "\n";
			print RESULT $SEQ ."\n";
		}
	}
}# endloop

close(INFILE);
close(RESULT);


# Monsieurs Pieter - sckcen
sub dec2bin {
     my $str = unpack("B32", pack("N", shift));
     $str =~ s/^0+(?=\d)//;   # otherwise you'll get leading zeros
     if (length($str) < 8) {
        $str = "0"x(8-length($str)).$str;
     }
     #$myDEBUG && print $str, "\n";
     return $str;
}

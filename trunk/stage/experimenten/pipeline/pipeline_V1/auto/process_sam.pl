# svenn dhert @ sckcen
use POSIX;

# load inputfile from perl arg; $ pl file.pl "inputfile"
my $input 			= $ARGV[0];
my $read_length		 	= $ARGV[1];

# load file
open(SAM_FILE, $input) or die("file not found.");

# save file
open(RESULT, ">>" . $input . ".isize") or die("save location doesn't exist");

# save visualisation data
open(READ, ">>" . $input . ".mapped") or die("save file not found");

# debug output during run
$count_total 		= 0;
$count_proper_mapped 	= 0;
$count_proper_mapped_r 	= 0;

# read length of the sequencer
$count = 0;

# loop line b line
while(<SAM_FILE>)
{
	# store line
	my $current_line = $_;

	# split tabbed
	(
		$qname, 
		$flag,
		$rname,
		$pos,	
		$mapq,	
		$cigar,	
		$NRNM,	
		$mpos,
		$size,
		$SEQ,
		$QUAL,
		@rest
	) = split('\t', $current_line);	
	
	# dec flag to bin values
	(
		$second_read,
		$first_read,
		$strand_mate, 	$strand_quer,
		$mate_unmapped,	$quer_unmapped,
		$proper_mapped,
		$paired_seq
	) = split(//, dec2bin($flag));
	
	# DELETIES
	# if size is == 0
	# there is no mapping on one of both reads
	# therefore we cannot use the read
	if ($size != 0)
	{

	
		# proper mapped holds intel about the size
		# therefor don't use propper_mapped here !
		if ($first_read == 1)			
		{			
			print RESULT $pos . "\t" . abs($size). "\n";	
			$count_proper_mapped++;
		}

	}#size!=0
	$count_total++;

	# INSERTS
	# can't be propper mapped
	# 1 of them isn't aligned
	if($proper_mapped == 0)
	{
		# only 1 is properly mapped
		if ($strand_quer == 0)
		{
			#print $paired_seq . "\n";
			# from this position + read_length
			for($i = 0; $i <= $read_length; $i++)
			{
				$t = $pos + $i;	
				$bad_read[$t]++;
			}
		}
		if ($strand_quer == 1)
		{	

			#print $paired_seq . "\n";
			# from this position + read_length
			for($i = 0; $i <= $read_length; $i++)
			{
				$t = $pos - $i;	
				$bad_read_back[$t]++;
			}
		}
	}
	else
	{
		# only 1 is properly mapped
		if ($strand_quer == 0)
		{
			#print $paired_seq . "\n";
			# from this position + read_length
			for($i = 0; $i <= $read_length; $i++)
			{
				$t = $pos + $i;	
				$good_read[$t]++;
			}
		}
		if ($strand_quer == 1)
		{	

			#print $paired_seq . "\n";
			# from this position + read_length
			for($i = 0; $i <= $read_length; $i++)
			{
				$t = $pos - $i;	
				$good_read_back[$t]++;
			}
		}
	}
	$count++;

}# endloop
print "		# totaal (final) : " . $count_total . " mapped : " . $count_proper_mapped . " (" . ceil(($count_proper_mapped/$count_total)*100) . "%)\n";


# INSERTIES POST-LOOP
print "	# " . $count . " reads processed in " . $input . "\n";
print "		# now writing result to " . $input . ".mapped \n";
my $i = 0;

	# pos bad_forward bad_reverse good_forward good_reverse diff_forward diff_reverse
while ( $i <= $#bad_read_back )
{
	if ($good_read[$i] eq "") 	{$good_read[$i] = 0;}
	if ($good_read_back[$i] eq "") 	{$good_read_back[$i] = 0;}
	if ($bad_read[$i] eq "") 	{$bad_read[$i] = 0;}
	if ($bad_read_back[$i] eq "") 	{$bad_read_back[$i] = 0;}
	
	$diff_forward = (($bad_read[$i] - $good_read[$i]) > 0) 			? ($bad_read[$i] - $good_read[$i]) : 0;
	$diff_reverse = (($bad_read_back[$i] - $good_read_back[$i]) > 0 ) 	? ($bad_read_back[$i] - $good_read_back[$i]) : 0;
	
	
	print READ 
			$i . "\t" .
			$bad_read[$i] . "\t" .
			$bad_read_back[$i] . "\t" .
			$good_read[$i] . "\t" .
			$good_read_back[$i] . "\t" .
			$diff_forward . "\t" .
			$diff_reverse .			
			"\n";
    	$i++;
}

close(READ);
close(SAM_FILE);
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


# svenn dhert @ sckcen
use warnings;

my $input 		= $ARGV[0];
my $low_treshold	= $ARGV[1];
my $search_limit	= $ARGV[2];
my $max_dist		= $ARGV[3];

# load file
open(SAM_FILE, $input) or die("file not found.");

# couples (*result*)
open(RESULT, ">>result/roi_inserties_couple") or die("file not found.");

# all peaks (*just cause of errors*)
open(RESULT_DEBUG, ">>result/roi_inserties_peak") or die("file not found.");

print RESULT ">> ". $input  . "\n";
print RESULT_DEBUG ">> ". $input  . "\n";

my $count 		= 1;
my $forward_max		= 0;
my $reverse_max 	= 0;
my $forward_pos_max	= 0;
my $reverse_pos_max	= 0;


# loop line b line
while(<SAM_FILE>)
{
	# store line
	my $current_line = $_;

	# split tabbed
	(
		my $pos,
		my $bad_forward,
		my $bad_reverse,
		my $good_forward,
		my $good_reverse,
		my $diff_forward,
		my $diff_reverse
	) = split('\t', $current_line);	
	
	chomp($pos, $bad_forward, $bad_reverse, $good_forward, $good_reverse, $diff_forward, $diff_reverse);


	# new value is bigger
	if ($forward_max < $diff_forward)
	{
		$forward_max 		= $diff_forward;
		$forward_pos_max 	= $pos;
	}
	if ($reverse_max < $diff_reverse)
	{
		$reverse_max 		= $diff_reverse;
		$reverse_pos_max 	= $pos;
	}
	

	if ( $count % $search_limit == 0)
	{
		if ($forward_max > $low_treshold && $reverse_max > $low_treshold)
		{
			# piek
			print RESULT $forward_pos_max . "\t" . $reverse_pos_max. "\n";
		}
		if ($forward_max > $low_treshold)
		{
			# piek
			print RESULT_DEBUG "pos1 : ". $pos . " size :" . $forward_max. "\n";

			$forward_max	= 0;
		}
		
		if ($reverse_max > $low_treshold)
		{
			# piek
			print RESULT_DEBUG "pos2 : ". $pos . " size :" . $reverse_max. "\n";
			
			$reverse_max	= 0;
		}
		

		
	}
	$count++;
}# endloop


close(SAM_FILE);

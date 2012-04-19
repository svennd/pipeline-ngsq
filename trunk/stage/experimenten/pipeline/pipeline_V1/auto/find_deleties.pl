# svenn dhert @ sckcen

$input 		= $ARGV[0];
$group_size 	= $ARGV[1];	# 100
$min_cut_off	= $ARGV[2];	# min_cut_off 3
$max_cut_off	= $ARGV[3];	# max_cut_off 4

# load file
open(INFILE, $input) or die("file not found.");

# save file
open(RESULT, ">>result/roi_deletions") or die("file not found.");

# loop line b line
$count = 1;
$total_interested_regions_found = 0;

# what file are we handeling
($rname, @trash) = split('\.', $input);
	print RESULT ">> " . $rname . "\n";

while(<INFILE>)
{
	# store line
	my $current_line = $_;

	# split tabbed
	(
		$pos,
		$size
	) = split('\t', $current_line);	
		
	$total += log10($size);

	if ($count % $group_size == 0)
	{
		$avg = $total / $group_size;

		if ($avg > $min_cut_off && $avg < $max_cut_off)
		{
			$total_interested_regions_found++;
			print RESULT $pos ."\t" . $avg . "\n";
		}

		$total = 0;
	}
	$count++;
}# endloop

print "\t # Total ROI for " . $input . ": " . $total_interested_regions_found . "\n";

close(INFILE);
close(RESULT);

sub log10 {
  my $n = shift;
  return log($n)/log(10);
}



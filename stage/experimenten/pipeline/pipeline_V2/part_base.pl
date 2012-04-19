# svenn dhert @ sckcen
use warnings;

# load file
open(INPUT_FILE, "S1_Cleandata_2.fq") or die("file not found.");

# couples (*result*)
open(RESULT, ">>seq2.fq") or die("file not found.");
open(CUT, ">>first_15.fasta") or die("file not found.");

$count = 1;

# loop line b line
while(<INPUT_FILE>)
{

	my $current_line = $_;
	
	if ($count % 2 == 0 && $count % 4 != 0)
	{
		print RESULT substr($current_line, 15, 40);
		print CUT substr($current_line, 0, 15);
	}
	else
	{
	print RESULT $current_line;
	}
	$count++;

}# endloop

close(INPUT_FILE);
close(RESULT);
close(CUT);

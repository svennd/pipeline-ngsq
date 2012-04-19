# svenn dhert @ sckcen
use warnings;

$input 		= $ARGV[0];

# load file
open(SAM_FILE, $input) or die("file not found.");

# couples (*result*)
open(RESULT, ">>result/qcheck") or die("file not found.");

$count = 1;
$total_reads = 0;

# loop line b line
while(<SAM_FILE>)
{
	if ($count > 100000){last;}
	
	my $current_line = $_;
	
	if ($count % 4 == 0)
	{
		@chars = split(//, $current_line);
		
		my $i = 0;
		foreach my $char (@chars)
		{
			my $nr = ord($char);
			my $score = $nr - 66;
			
			$scores[$i] += $score;
			print STDERR $scores[$i], "\t";
			$i++;
		}
		system('clear');
		$total_reads++;
	}
	$count++;


}# endloop

foreach $score (@scores)
{
	print RESULT ($score/$total_reads) . "\n";
}

close(SAM_FILE);
close(RESULT);

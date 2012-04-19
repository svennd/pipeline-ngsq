# svenn dhert @ sckcen
use strict;
use warnings;

open(FASTQ, our $input) or die("file not found. ". $input);
Log::make_entry("quality analyse for ". $input);
print $input;

my $count = 1;
my $total_reads = 0;

my @scores;

while(<FASTQ>)
{
	if ($count > 100000){last;}

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

open(RESULT, ">>result/quality_$input") or die("file not found.");
my $position = 1;
foreach my $score (@scores)
{
	my $point = $score/$total_reads;
	if ( $score < 30 )
	{
		Log::make_entry("Low avg read quality for base " . $position . " @ " . $input . " (" . $point . ")");
	}
	
	print RESULT $point . "\n";
	$position++;
}
close(RESULT);

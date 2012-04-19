# svenn dhert @ sckcen
use warnings;
use strict;

# load file
open(FIRST, "seq1.txt") or die("file not found.");
open(SECOND, "seq2.txt") or die("file not found.");

# save file
open(RESULT, ">>TO_VELVET") or die("file not found.");

my $count = 1;
my $seq_pars = 0;
my $found = 0;
while(<FIRST>)
{

	# store line
		my $inden	= $_;
	my $line_first	= <FIRST>;
		my $inden2	= <FIRST>;
		my $qual	= <FIRST>;
	
	# store second line
		my $sinden	= <SECOND>;
	my $line_second	= <SECOND>;
		my $sinden2	= <SECOND>;
		my $squal	= <SECOND>;
	
	#print $inden . "\n >>>> " . $line_first. "\n" . $inden2 . "\n" . $qual . "\n--------------------\n";
	#print $sinden . "\n >>>> " . $line_second. "\n" . $sinden2 . "\n" . $squal . "\n--------------------\n";
	
	chomp($line_first, $line_second);
	open(DATA, "ROI") or die("can't open file");
		my $location = 1;
		while(<DATA>)
		{
			chomp;
			my $seq = $_;
			if ($line_first eq $seq)
			{	
				#print $line_first . '(M) - ' . $line_second . "\n";
				print RESULT ">first_" . $location . "\n";
				print RESULT $seq . "\n";
				print RESULT ">second_" . $location . "\n";
				print RESULT $line_second . "\n";
				$found++;
			}
			elsif ($line_second eq $seq)
			{
				#print $line_first . ' - ' . $line_second . "(M)\n";
				print RESULT ">first_" . $location . "\n";
				print RESULT $seq . "\n";
				print RESULT ">second_" . $location . "\n";
				print RESULT $line_first . "\n";
				$found++;
			}
			$location++;
		}
	close(DATA);
	
	$seq_pars++;
	if ($seq_pars % 100000 == 0)
	{
		print "found / sequenced parsed : ". $found ." / " . $seq_pars . "\n";
	}

}# endloop

close(RESULT);
close(FIRST);
close(SECOND);

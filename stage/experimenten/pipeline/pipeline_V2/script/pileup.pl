# svenn dhert @ sckcen
# will clean the SNP's
# we throw them in 3 bins
	# high SNP : >95

# default library's
use POSIX;
use warnings;

# required modules
require "modules/Log.pm";

# open the required files
open(PILEUP_SHIFT, "raw.pileup") or die("read error cannot find pileup file");
open(INDEL, 	">>result/indel.pileup") or die("trying :-).");
open(SNP_HIGH, 	">>result/high.snp") or die("trying :-).");
open(SNP_LOW, 	">>result/low.snp") or die("trying :-).");

my $total_snp;
my $total_indel;

while(<PILEUP_SHIFT>)
{
	# store line
	my $current_line = $_;
	
	(my $rname, my $pos, my $rbase, my $nbase, my $int1, my $int2, my $int3, my $int4, my $coverage, my $phred) = split("\t", $current_line);
	
	# not a snp :(
	if ($rbase eq "*")
	{
		print INDEL $current_line;
		$total_indel++;
	}
	# snp ! :)
	else
	{
		@coverage 	= split(//, $coverage);
		$trust 		= 0;
		$no_trust	= 0;
		#print $coverage . " \n";
		foreach $info (@coverage)
		{
			# ref
			if ($info eq "." || $info eq ",")
			{
				$no_trust++;
			}
			# snp
			elsif ($info eq "a" || $info eq "t" || $info eq "c" || $info eq "g" || $info eq "A" || $info eq "T" || $info eq "C" || $info eq "G" )
			{
				$trust++;
			}
			else
			{
				# some info is not used
				# $ ^ [^ ... maybe later
				#print $info;
			}
		}
		
		$trust_calculation = (($no_trust+$trust) > 0) ? floor($trust/($no_trust+$trust)*100) : 0;

		if ($trust_calculation > 95)
		{
			print SNP_HIGH $rname. "\t" . $pos ."\t". $rbase . "\t". $nbase . "\t" . $trust_calculation . "\t" . ($no_trust+$trust) . "\n";
			$total_snp++;
		}
		elsif ($trust_calculation > 60)
		{
			print SNP_LOW $rname. "\t" . $pos ."\t". $rbase . "\t". $nbase . "\t" . $trust_calculation . "\t" . ($no_trust+$trust) . "\n";
		}
	}
}
	print "total snp : ". $total_snp . " total indel : ". $total_indel . "\n";
	Log::make_entry("Total SNP : " . $total_snp, "log/result.txt");
	Log::make_entry("Total Indel : " . $total_indel, "log/result.txt");

close(PILEUP_SHIFT);
close(INDEL);
close(SNP_HIGH);
close(SNP_LOW);

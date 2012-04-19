# svenn dhert @ sckcen

# used for ceil/floor (basic stats) 
use POSIX;

print "#4) Shifting data ... \n";

	print "\t # shifting into seperate files \n";
	open(SHIFT_SAM, "seq.sam") or die("read error cannot find sam file");

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

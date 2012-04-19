# svenn dhert @ sckcen

# config
my $index_method= "is"; 		# [is, bwasw]
my $bwa_log	= "bwa.log";		# default : bwa.log
my $sam_log	= "sam.log";		# default : sam.log

# start of script
print "#1) Requirements ... \n";

	# getting the files & locations
	print "\t# Where can I find the first sequence file ? \n\t";
	my $first_file 		= <STDIN>;

	print "\t# Where can I find the second sequence file ? \n\t";
	my $second_file 	= <STDIN>;

	print "\t# Where can I find the reference sequence file ? \n\t";
	my $ref_file 		= <STDIN>;

	chomp($first_file, $second_file, $ref_file);

	# checking if gz files or plain (not 100% safe!)
	(my $ffile, my $fext, my $fgz) = split(/\./, $first_file);
	(my $sfile, my $sext, my $sgz) = split(/\./, $second_file);
	(my $rfile, my $rext, my $rgz) = split(/\./, $ref_file);
	
	# setting some file names
	my $first_sai = $ffile . ".sai";
	my $second_sai = $sfile . ".sai";
	
	# gz file
	if ($fgz eq "gz")
	{
		print "\t\t# gunzipping " . $first_file . "\n";
		print `gunzip $first_file`;
	}
	if ($sgz eq "gz")
	{
		print "\t\t# gunzipping " . $second_file . "\n";
		print `gunzip $second_file`;
	}
	if ($rgz eq "gz")
	{
		print "\t\t# gunzipping " . $ref_file . "\n";
		print `gunzip $ref_file`;
	}
	
	# can we read the files (?)
	if (!(-T $first_file) && !(-T $second_file) && !(-T $ref_file))
	{
		die("\n\n\t\t ## error : some of the files cannot be read ###");
	}

print "#2A) Alignment ... \n";

	# index ref
	print "\t# indexing reference \n";
	print `bwa index -a $index_method $ref_file >log/index_$bwa_log 2>&1`;
	
	# align 
	print "\t# align first sequence file \n";
	print `bwa aln $ref_file $first_file 1> $first_sai 2>log/first_aln_$bwa_log`;
	
	print "\t# align second sequence file \n";
	print `bwa aln $ref_file $second_file 1> $second_sai 2>log/second_aln_$bwa_log`;
	
	# sampe
	print "\t# recompile to sam file \n";
	print `bwa sampe $ref_file $first_sai $second_sai $first_file $second_file 1>seq.sam 2>log/sampe_$bwa_log`;
	
	# sam -> bam
	print "\t# compile sam to bam \n";
	print `samtools view -uS seq.sam | samtools sort - seq 2>log/sam_to_bam_$sam_log`;
	
	# index alignment
	print "\t# index alignment \n";
	print `samtools faidx $ref_file 2>log/faidx_$sam_log`;
	print `samtools index seq.bam 2>log/index_$sam_log`;
		
	print "#2B) SNP calling ... \n";
		print `samtools pileup -vcf $ref_file seq.bam > raw.pileup 2>log/pileup_log`;
		#print `perl auto/samtools.pl varFilter raw.pileup | awk '\$6>=20' 1> result/final.pileup 2>log/pileup_filter_log`;

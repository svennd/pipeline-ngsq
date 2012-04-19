# svenn dhert @ sckcen

# required modules
require "modules/Log.pm";
require "modules/GunZip.pm";

# config
my $index_method	= "is"; 		# [is, bwasw]
my $bwa_log		= "bwa.log";		# default : bwa.log
my $quality_check 	= 1;

# start of script
print "#1) Requirements ... \n";

	# make directory's
	mkdir "result" or die $!;
	mkdir "log" or die $!;
	Log::make_entry("directory's made");
	
	# getting the files & locations
	print "\t# Where can I find the first sequence file ? \n\t";
	my $first_file 		= <STDIN>;

	print "\t# Where can I find the second sequence file ? \n\t";
	my $second_file 	= <STDIN>;

	print "\t# Where can I find the reference sequence file ? \n\t";
	my $ref_file 		= <STDIN>;

	chomp($first_file, $second_file, $ref_file);

	# unzipping should it be needed
	$first_file 	= GunZip::is_gunzip($first_file);
	$second_file 	= GunZip::is_gunzip($second_file);
	$ref_file 	= GunZip::is_gunzip($ref_file);
		
	# can we read the files (?)
	if (!(-T $first_file) && !(-T $second_file) && !(-T $ref_file))
	{
		die("\n\n\t\t ## error : some of the files cannot be read ###");
	}
	Log::make_entry("files are ready");
	
	if ($quality_check)
	{
		require "modules/QualityCheck.pm";
		QualityCheck::check_quality($first_file);
		QualityCheck::check_quality($second_file);
		Log::make_entry("checked quality");
	}

print "#2) Alignment ... \n";

	# index ref
	print "\t# indexing reference \n";
	print `bwa index -a $index_method $ref_file >log/$bwa_log 2>&1`;
	Log::make_entry("index for reference file made");
	
	# align 
	print "\t# align first sequence file \n";
	print `bwa aln $ref_file $first_file 1> $first_file.sai 2>log/$bwa_log`;
	Log::make_entry("parsed first sequence file");
	
	print "\t# align second sequence file \n";
	print `bwa aln $ref_file $second_file 1> $second_file.sai 2>log/$bwa_log`;
	Log::make_entry("parsed second sequence file");
	
	# sampe
	print "\t# compile to sam file \n";
	print `bwa sampe $ref_file $first_sai $second_sai $first_file $second_file 1>seq.sam 2>log/$bwa_log`;
	Log::make_entry("made SAM file");
	
	# sam -> bam
	print "\t# compile sam to bam \n";
	print `samtools view -uS seq.sam 2>log/$sam_log | samtools sort - seq 2>log/$sam_log`;
	Log::make_entry("made BAM file");
	
	# index alignment
	print "\t# index alignment \n";
	print `samtools faidx $ref_file 2>log/$sam_log`;
	print `samtools index seq.bam 2>log/$sam_log`;
	Log::make_entry("index alignment");
		
print "#3) SNP calling ... \n";
		print `samtools pileup -vcf $ref_file seq.bam > raw.pileup 2>log/$bwa_log`;
		require "script/pileup.pl";
		Log::make_entry("sorted pileup");

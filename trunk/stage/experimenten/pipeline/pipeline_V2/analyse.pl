#!/usr/bin/perl
# svenn dhert @ sckcen
# version 2.0

# default library's
use warnings;
use strict;
use POSIX;
use Getopt::Long;

# required modules
require "modules/Log.pm";
require "modules/GunZip.pm";
require "modules/FileFormat.pm";
require "modules/PipeLine.pm";
require "modules/SplitData.pm";
require "modules/Screen.pm";

# config
# default parameters	
my $index_method 	= "is";			# [is, bwasw]
my $bwa_log		= "bwa.log";		# log name
my $quality_check	= 1;			# 1: do quality check
my $os			= "linux";		# [linux, windows]
my $snp_calling		= 1;			# 1: compile to BAM, then find SNP

# deleties
my $group_size		= 300;			# search deleties group size
my $min_cut_off		= 3;			# min_cut_off for deleties (log, avg)
my $max_cut_off		= 5;			# max_cut_off for deleties (log, avg)
	
# inserties
my $read_length		= 50;			# depends on the sequencing system. length of the reads
my $peak_treshold	= 10;			# under this value there is no peak detected (unmapped - mapped)
my $search_limit	= 500;			# every 500 positions a peak check (local max)
my $max_dist		= 1000;			# max distance between a forward & reverse peak

# input files
my $first_file		= 0;			# first FastQ file
my $second_file		= 0;			# second FastQ file
my $ref_file		= 0;			# reference multi-fasta file
my $sam_file		= 0;			# SAM file

# draw
my $draw_images		= 1;			# 1 : visualise results (using R) 
my $draw_insertion_size	= 10000;		# amount of positions to draw per plot 
my $draw_deletion_size	= 10000;		# amount of positions to draw per plot
my $draw_y_top		= 7;			# standardize plot y-max (if larger will be raised automaticly)

# get paramets from console line
# all these are optional
# GetOptions
	# name= (must)
	# name: (optional)
	# i 	(integer)
	# f	(float)
	# s	(string)
	# !	(negatief, --foo kan dan --nofoo of --no-foo
	# + 	(increase, --more --more --more ==> +3)
	
GetOptions(		
			'index_method=s' 	=> \$index_method, 
			'quality_check!'	=> \$quality_check,
			'snp_calling!'		=> \$snp_calling,
			'os=s'			=> \$os,
			'group_size=i'		=> \$group_size,
			'min_cut_off=i'		=> \$min_cut_off,
			'max_cut_off=i'		=> \$max_cut_off,
			'read_length=i'		=> \$read_length,
			'peak_treshold=i'	=> \$peak_treshold,
			'search_limit=i'	=> \$search_limit,
			'max_dist=i'		=> \$max_dist,
			'first_file=s'		=> \$first_file,
			'second_file=s'		=> \$second_file,
			'ref_file=s'		=> \$ref_file,
			'sam_file=s'		=> \$sam_file,
			'draw_images!'		=> \$draw_images,
			'draw_insertion_size=i'	=> \$draw_insertion_size,
			'draw_deletion_size=i'	=> \$draw_deletion_size,
			'draw_y_top=i'		=> \$draw_y_top
		);

# start of script
Screen::show_done("#1) Pre-process", $os);

	# make directory's
	mkdir "result";
	mkdir "log";
	mkdir "r_data";
	Log::make_entry("directory\'s made");
	print "\t# Diretory's made\n";
	
	if ($sam_file eq 0)
	{
		# no files given, ask for fastQ files
		if ($first_file eq 0 || $second_file eq 0 || $ref_file eq 0)
		{	
			# getting the files & locations
			print "\t# Where can I find the first sequence file ? \n\t";
			$first_file 		= <STDIN>;

			print "\t# Where can I find the second sequence file ? \n\t";
			$second_file 		= <STDIN>;

			print "\t# Where can I find the reference sequence file ? \n\t";
			$ref_file 		= <STDIN>;
	
			chomp($first_file, $second_file, $ref_file);
		}
	
		# unzipping should it be needed
		$first_file 	= GunZip::is_gunzip($first_file);
		$second_file 	= GunZip::is_gunzip($second_file);
		$ref_file 	= GunZip::is_gunzip($ref_file);
		Log::make_entry("files are ready");
		print "\t# files ready\n";
		
		# quality check
		if ($quality_check)
		{
			require "modules/QualityCheck.pm";
			print "\t# quality check ...\n";
			print $first_file;
			QualityCheck::check_quality($first_file);
			QualityCheck::check_quality($second_file);
			Log::make_entry("checked quality");
		}
		
		print "\r#1) Post-process\n#2) Alignment ... \n";

		# index ref
		print "\t# indexing reference \n";
		print `bwa index -a $index_method $ref_file >log/$bwa_log 2>&1`;
		Log::make_entry("index for reference file made");
	
		# align 
		my $fbase = ($first_file =~ m/^(.*?)\./)[0];
		my $sbase = ($second_file =~ m/^(.*?)\./)[0];
	
		print "\t# align first sequence file \n";
		print `bwa aln $ref_file $first_file 1> $first_file.sai 2>log/$bwa_log`;
		Log::make_entry("parsed first sequence file");
	
		print "\t# align second sequence file \n";
		print `bwa aln $ref_file $second_file 1> $second_file.sai 2>log/$bwa_log`;
		Log::make_entry("parsed second sequence file");
	
		# sampe
		print "\t# compile to sam file \n";
		print `bwa sampe $ref_file $first_file.sai $second_file.sai $first_file $second_file 1>seq.sam 2>log/$bwa_log`;
		Log::make_entry("made SAM file");
		$sam_file = "seq.sam";
	}
	else
	{
		Screen::show_done("#2) Alignment -- not_done", $os);
	}
	if ($snp_calling)
	{
		# sam -> bam
		print "\t# compile sam to bam \n";
		print `samtools view -uS $sam_file 2>log/$bwa_log | samtools sort - seq 2>log/$bwa_log`;
		Log::make_entry("made BAM file");

		# index alignment
		print "\t# index alignment \n";
		print `samtools faidx $ref_file 2>log/$bwa_log`;
		print `samtools index seq.bam 2>log/$bwa_log`;
		Log::make_entry("index alignment");
	
		Screen::show_done("#3) SNP calling", $os);
				print `samtools pileup -vcf $ref_file seq.bam >raw.pileup 2>log/$bwa_log`;
				require "script/pileup.pl";
	}
	else
	{
		Screen::show_done("#3) SNP calling -- not_done", $os);
	}
Screen::show_done("#4) split data", $os);
	SplitData::split_sam($sam_file);		
		
Screen::show_done("#5) processing SAM file", $os);
	PipeLine::process_sam($read_length);
		
Screen::show_done("#6) finding deleties", $os);
	# we use bash sorting to sort
	# windows won't be able to this *sorry*
	PipeLine::sort_isize();
		
	# find deleties
	PipeLine::find_deleties($group_size, $min_cut_off, $max_cut_off);
			
Screen::show_done("#6) finding inserties", $os);
		# find inserties
		PipeLine::find_inserties($peak_treshold, $search_limit, $max_dist);
		
if ($draw_images == 0)
{
	Screen::show_done("#6) making images", $os);
			print "	## generating images ... (insertions)\n";
			# script img_size treshold
			print `Rscript script/draw_inserts_peak.r $draw_insertion_size $peak_treshold`;
	
			print "	## generating images ... (deletions)\n";
			# script limit y_top treshold
			print `Rscript script/draw_deleties_loop.r $draw_deletion_size $draw_y_top $min_cut_off`;
}	

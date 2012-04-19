# PipeLine
# svenn dhert @ sckcen
#
# use :
#

package PipeLine;

use strict;
use warnings;
use POSIX;

# required modules
require "modules/Log.pm";
require "modules/FileFormat.pm";

our $VERSION = '1.00';
our @EXPORT  = qw(process_sam sort_isize find_deleties find_deleties);

#
sub find_inserties
{	
	my @para	= @_;
	my $treshold	= $para[0];
	my $search_limit= $para[1];
	my $max_dist	= $para[2];
	
	my @mapped_files = FileFormat::get_files('./', 'mapped');
	foreach my $input (@mapped_files)
	{
		inserties($input, $treshold, $search_limit, $max_dist);
		Log::make_entry("find peak : ". $input);
		
		my $base = ($input =~ m/^(.*?)\.ssam$/)[0];
			mkdir "r_data/". $base;
			mkdir "r_data/". $base . "/deleties";
			mkdir "r_data/". $base . "/inserties";
	}
	Log::make_entry("all files have been searched for peaks.");
	
}

sub inserties
{	
	my @para	= @_;
	my $input	= $para[0];
	my $treshold	= $para[1];
	my $search_limit= $para[2];
	my $max_dist	= $para[3];
	
	# load file
	open(SAM_FILE, $input) or die("file not found.");

	# couples (*result*)
	open(RESULT, ">>result/roi_inserties_couple") or die("file not found.");

	# all peaks (*just cause of errors*)
	open(RESULT_DEBUG, ">>result/roi_inserties_peak") or die("file not found.");

	print RESULT ">> ". $input  . "\n";
	print RESULT_DEBUG ">> ". $input  . "\n";

	my $count 		= 1;
	my $forward_max		= 0;
	my $reverse_max 	= 0;
	my $forward_pos_max	= 0;
	my $reverse_pos_max	= 0;


	# loop line b line
	while(<SAM_FILE>)
	{
		# store line
		my $current_line = $_;

		# split tabbed
		(
			my $pos,
			my $bad_forward,
			my $bad_reverse,
			my $good_forward,
			my $good_reverse,
			my $diff_forward,
			my $diff_reverse
		) = split('\t', $current_line);	
	
		chomp($pos, $bad_forward, $bad_reverse, $good_forward, $good_reverse, $diff_forward, $diff_reverse);


		# new value is bigger
		if ($forward_max < $diff_forward)
		{
			my $forward_max 		= $diff_forward;
			my $forward_pos_max 	= $pos;
		}
		if ($reverse_max < $diff_reverse)
		{
			$reverse_max 		= $diff_reverse;
			$reverse_pos_max 	= $pos;
		}
	

		if ( $count % $search_limit == 0)
		{
			if ($forward_max > $treshold && $reverse_max > $treshold)
			{
				# piek
				print RESULT $forward_pos_max . "\t" . $reverse_pos_max. "\n";
			}
			if ($forward_max > $treshold)
			{
				# piek
				print RESULT_DEBUG "pos1 : ". $pos . " size :" . $forward_max. "\n";

				$forward_max	= 0;
			}
		
			if ($reverse_max > $treshold)
			{
				# piek
				print RESULT_DEBUG "pos2 : ". $pos . " size :" . $reverse_max. "\n";
			
				$reverse_max	= 0;
			}
		

		
		}
		$count++;
	}# endloop


	close(SAM_FILE);
}

# loop for parsing all .isize.sort files (deletie hunting)
sub find_deleties
{
	my @para	= @_;
	my $group_size	= $para[0];
	my $min_cut_off	= $para[1];
	my $max_cut_off	= $para[2];
	
	my @sort_files = FileFormat::get_files('./', 'sort');
	foreach our $input (@sort_files)
	{
		deleties($input, $group_size, $min_cut_off, $max_cut_off);
		Log::make_entry("searched for deletion in " . $input);
	}
	Log::make_entry("searched for deletion in all files.");
}

# sort the isize files (for image generation + deletion detection)
sub sort_isize
{
	my @isize_files = FileFormat::get_files('./', 'isize');
	foreach my $input (@isize_files)
	{
		print `sort -nk 1 $input > $input".sort"`;
		Log::make_entry("sorted : ". $input);
	}
	Log::make_entry("sorted all files.");
}

# loop for all files
sub process_sam
{
	my @para	= @_;
	my $read_length	= $para[0];
	my @ssam_files = FileFormat::get_files('./', 'samm');
	foreach our $input (@ssam_files)
	{
		process($input, $read_length);
		Log::make_entry("process_sam : " . $input);
	}
	Log::make_entry("all sam files processed.");
}

# proces file
sub process
{
	my @para	= @_;
	my $input 	= $para[0];
	my $read_length	= $para[1];
	
	# load file
	open(SAM_FILE, $input) or die("file not found.");

	# save file
	open(RESULT, ">>" . $input . ".isize") or die("save location doesn't exist");

	# save visualisation data
	open(READ, ">>" . $input . ".mapped") or die("save file not found");

	# debug output during run
	my $count_total 		= 0;
	my $count_proper_mapped 	= 0;
	my $count_proper_mapped_r 	= 0;

	# init vars
	my @good_read_back;
	my @good_read;
	my @bad_read;
	my @bad_read_back;
	
	# loop line b line
	while(<SAM_FILE>)
	{
		# store line
		my $current_line = $_;

		# split tabbed
		(
			my $qname, 
			my $flag,
			my $rname,
			my $pos,	
			my $mapq,	
			my $cigar,	
			my $NRNM,	
			my $mpos,
			my $size,
			my $SEQ,
			my $QUAL,
			my @rest
		) = split('\t', $current_line);	
	
		# dec flag to bin values
		(
			my $second_read,
			my $first_read,
			my $strand_mate, 	my $strand_quer,
			my $mate_unmapped,	my $quer_unmapped,
			my $proper_mapped,
			my $paired_seq
		) = split(//, dec2bin($flag));
	
		# DELETIES
		# if size is == 0
		# there is no mapping on one of both reads
		# therefore we cannot use the read
		if ($size != 0)
		{

			# proper mapped holds intel about the size
			# therefor don't use propper_mapped here !
			if ($first_read == 1)			
			{			
				print RESULT $pos . "\t" . abs($size). "\n";	
				$count_proper_mapped++;
			}

		}#size!=0

		# INSERTS
		# can't be propper mapped
		# 1 of them isn't aligned
		if($proper_mapped == 0)
		{
			# only 1 is properly mapped
			if ($strand_quer == 0)
			{
				# from this position + read_length
				for(my $i = 0; $i <= $read_length; $i++)
				{
					my $t = $pos + $i;	
					$bad_read[$t]++;
				}
			}
			if ($strand_quer == 1)
			{	
				# from this position + read_length
				for(my $i = 0; $i <= $read_length; $i++)
				{
					my $t = $pos - $i;	
					$bad_read_back[$t]++;
				}
			}
		}
		else
		{
			# only 1 is properly mapped
			if ($strand_quer == 0)
			{
				#print $paired_seq . "\n";
				# from this position + read_length
				for(my $i = 0; $i <= $read_length; $i++)
				{
					my $t = $pos + $i;	
					$good_read[$t]++;
				}
			}
			if ($strand_quer == 1)
			{	

				#print $paired_seq . "\n";
				# from this position + read_length
				for(my $i = 0; $i <= $read_length; $i++)
				{
					my $t = $pos - $i;	
					$good_read_back[$t]++;
				}
			}
		}
		$count_total++;

	}# endloop
	Log::make_entry("Total reads : " . $count_total, "log/result.txt");
	Log::make_entry("Total mapped reads : " . $count_proper_mapped. " ("  . ceil(($count_proper_mapped/$count_total)*100) . "%)", "log/result.txt");
	print "		# totaal (final) : " . $count_total .
			 " mapped : " . $count_proper_mapped . " (" 
			 . ceil(($count_proper_mapped/$count_total)*100) . "%)\n";


	# INSERTIES POST-LOOP
	print "		# now writing result to " . $input . ".mapped \n";
	my $i = 0;

	# pos bad_forward bad_reverse good_forward good_reverse diff_forward diff_reverse
	while ( $i <= $#bad_read_back )
	{
		if ($good_read[$i] eq "") 	{$good_read[$i] = 0;}
		if ($good_read_back[$i] eq "") 	{$good_read_back[$i] = 0;}
		if ($bad_read[$i] eq "") 	{$bad_read[$i] = 0;}
		if ($bad_read_back[$i] eq "") 	{$bad_read_back[$i] = 0;}
	
		my $diff_forward = (($bad_read[$i] - $good_read[$i]) > 0) 			? ($bad_read[$i] - $good_read[$i]) : 0;
		my $diff_reverse = (($bad_read_back[$i] - $good_read_back[$i]) > 0 ) 	? ($bad_read_back[$i] - $good_read_back[$i]) : 0;
	
	
		print READ 
				$i . "\t" .
				$bad_read[$i] . "\t" .
				$bad_read_back[$i] . "\t" .
				$good_read[$i] . "\t" .
				$good_read_back[$i] . "\t" .
				$diff_forward . "\t" .
				$diff_reverse .			
				"\n";
	    	$i++;
	}

	close(READ);
	close(SAM_FILE);
	close(RESULT);
}

sub deleties
{
	my @para	= @_;
	my $input 	= $para[0];
	my $group_size 	= $para[1];
	my $min_cut_off = $para[2];
	my $max_cut_off	= $para[3];
	
	# load file
	open(INFILE, $input) or die("file not found. ");

	# save file
	open(RESULT, ">>result/roi_deletions") or die("file not found.");

	# loop line b line
	my $count = 1;
	my $total_interested_regions_found = 0;

	# what file are we handeling
	(my $rname, my @trash) = split('\.', $input);
		print RESULT ">> " . $rname . "\n";

	while(<INFILE>)
	{
		# store line
		my $current_line = $_;

		# split tabbed
		(
			my $pos,
			my $size
		) = split('\t', $current_line);	
		
		my $total += log10($size);

		if ($count % $group_size == 0)
		{
			my $avg = $total / $group_size;

			if ($avg > $min_cut_off && $avg < $max_cut_off)
			{
				$total_interested_regions_found++;
				print RESULT $pos . "\n";
			}

			$total = 0;
		}
		$count++;
	}# endloop

	print "\t # Total ROI for " . $input . ": " . $total_interested_regions_found . "\n";
	Log::make_entry("Total deleted ROI for " . $input . " : " . $total_interested_regions_found, "log/result.txt");
	
	close(INFILE);
	close(RESULT);
}

# geeft log10 van int waarde terug
# bron : onbekend / unknown
#sub log10
#{
#	my $n = shift;
#	return log($n)/log(10);
#}

# Monsieurs Pieter - sckcen
sub dec2bin
{
     my $str = unpack("B32", pack("N", shift));
     $str =~ s/^0+(?=\d)//;   # otherwise you'll get leading zeros
     if (length($str) < 8) {
        $str = "0"x(8-length($str)).$str;
     }
     return $str;
}



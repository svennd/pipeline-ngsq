#!/bin/bash
# svenn dhert @ sckcen
# we need :
	# sequence1.plaintext || sequence1.gzip
	# sequence2.plaintext || sequence2.gzip
	# ref.plaintext || ref.gzip

# does bwa + shifts bad reads (unknown position on ref)

perl auto/show_time.pl 1>> log_analyse
echo "Initialising analyse" >> log_analyse;

if [ ! -d log ]
	then
		mkdir log
		mv log_analyse log/analyse
		echo "mkdir log" >> log/analyse;
fi

if [ ! -d result ]
	then
		mkdir result
		echo "result log" >> log/analyse;
fi

perl auto/show_time.pl 1>> log/analyse
echo "running BWA tools" >> log/analyse;

if perl auto/bwa.pl
then
	perl auto/show_time.pl >> log/analyse;
	echo "BWA finished" >> log/analyse;
	echo "SNP calling" >> log/analyse;	
	echo "calling snp ...";
	perl auto/pileup.pl;
	
	perl auto/show_time.pl >> log/analyse;
	echo "SNP calling finished" >> log/analyse;
	echo "quality check" >> log/analyse;	
	echo "quality check ...";
	perl auto/pileup.pl;
		
	perl auto/show_time.pl >> log/analyse;
	echo "quality check finished" >> log/analyse;
	echo "Splitting data" >> log/analyse;
	
		perl auto/split_data.pl;
	
	perl auto/show_time.pl >> log/analyse;
	echo "finished splitting data" >> log/analyse;
	echo "starting processing SAM file for inserties/deleties" >> log/analyse;
	
	# isize method to find deleties
	echo "#4) processing sam ...";

		echo "	#a) making size tables + mapped/unmapped/lunmapped";
		for f in *.ssam; 
		do 
			echo "	## processing $f ...";
			perl auto/process_sam.pl $f 50
		done

		echo "	#b) sorting size tables";
		for f in *.isize; 
		do 
			echo "	## sorting $f ...";
			sort -nk 1 $f > $f".sort"
		done

	
	perl auto/show_time.pl >> log/analyse;
	echo "SAM processing finished" >> log/analyse;
	echo "finding deleties" >> log/analyse;
	
	# scanning for interesting regions
	echo "#5) finding deleties ...";
		for f in *.sort; 
		do 
			perl auto/find_deleties.pl $f 500 3 7
		done
	
	perl auto/show_time.pl >> log/analyse;
	echo "deleties finding finished" >> log/analyse;
	echo "finding inserties" >> log/analyse;
	
	# scanning for interesting regions
	echo "#7) scanning inserties regions ...";
		for f in *.mapped; 
		do 
			perl auto/find_peaks.pl $f 10 500 1000
		done
		
	perl auto/show_time.pl >> log/analyse;
	echo "finding inserties finished" >> log/analyse;
	echo "making images" >> log/analyse;
	
	# making images
	echo "#8) making structure for images ...";
	
		for f in *.mapped;
		do
			mkdir -p r_data/`expr match "$f" '\([A-Z_|a-zA-Z].*[0-9]\)'`
			mkdir -p r_data/`expr match "$f" '\([A-Z_|a-zA-Z].*[0-9]\)'`/deleties
			mkdir -p r_data/`expr match "$f" '\([A-Z_|a-zA-Z].*[0-9]\)'`/inserties
		done
	
		echo "	## generating images ... (insertions)";
		# script img_size treshold
		Rscript auto/draw_inserts_peak.r 10000 5;
	
		echo "	## generating images ... (deletions)";
		# script limit y_top treshold
		Rscript auto/draw_deleties_loop.r 1000 7 3;

	perl auto/show_time.pl >> log/analyse;
	echo "finished image creation" >> log/analyse;
	
else
	echo "Some error occurred.";
fi
	


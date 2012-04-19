#!/usr/bin/perl

use strict;
use DBI;

my $myDEBUG = 0;
my $readL = 75;
my $dir = './';
my $file = defined($ARGV[0]) ? $ARGV[0] : $dir.'s_6_1_FC70G05AAXX_46053_18_Na4.txt';

my $qfile = $dir.'qualityperposition.read1.txt';
my $readqfile =  $dir.'qualityperread.read1.txt';

open (Q, ">$qfile") || die "unable to open file => ", $qfile, " for writing: $!\n";
open (QREAD, ">$readqfile") || die "unable to open file => ", $readqfile, " for writing: $!\n";

open (FILE, "<$file") || die "unable to open file => ", $file, " for reading: $!\n";
my $count = 0;
my $seqcount = 0;
while (<FILE>) {
    if ($seqcount > 100000) {last;}
    chomp;
    my $line = $_;
    $count++;
    if ($count == 4) {
	$seqcount++;
	print STDERR $seqcount, "\r";
	#print $line, "\n";
	$count = 0;
	my $sum = 0;
	my @char = split(//, $line);
	foreach my $char (@char) {
	    my $nr = ord($char);
	    my $score = $nr - 66;
	    $sum += $score;
	    $myDEBUG && print "converting ", $char, " ==> ", $nr, " :: Q-score ", $score, "\n";
	    print Q $score."\t";
	}
	print Q "\n";
	my $readscore = $sum / $readL;
	$myDEBUG && print "average readscore => ", $readscore, "\n";
	print QREAD $readscore."\n";
	
    }

    
}

close Q;
close QREAD;

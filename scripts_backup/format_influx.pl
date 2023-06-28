#!/usr/bin/perl
#
#format_influx.pl (filename)
#File must contain data from only one source (IP)
#how to write from 
use warnings;
use strict;
use List::MoreUtils 'first_index';
use File::Basename;
use List::Util 'any';
use Scalar::Util 'looks_like_number';


#IP to location arrays
my @iplist = qw( 128.104.128.132 205.213.249.2 205.213.249.133 205.213.249.125 205.213.249.26 205.213.110.66);
my @loclist = qw( mad1-milw mad2-chic milw-mad1 chic-mad2 stpl-mad2 lab1);			

#Read in fineame argument and get basename
my $infile = $ARGV[0];
my ($outfile, $path, $suffix) = fileparse ($infile, ".data");
print STDERR "Outfile: $outfile \n";

#used for filesize mgmt: files under 10MB limit
my $datapoint_limit = 5000; 
my $datapoint_ctr = 0;
my $fileblock = 1;

#set to "X" before finding first IP -- ALL in file comes from same IP
my $loc = "X" ;

#open read and write files
open(READIN,"$infile") || die $!;
open(WRITEOUT, '>>', "lp_data/${outfile}_${fileblock}.lp") || die $!;
	
while(<READIN>){
	#entries expected in format: [timestamp(9)] [IP] [OID.instance] [value]
	my ($Time, $Node, $fullOid, $Value);
	eval{
		($Time, $Node, $fullOid, $Value) = split;
		} or do {
			print STDERR "Read failed on line $datapoint_ctr\n";
			next;
		};

	#set location and array references only once 
	if($loc =~ "X"){
		my $loc_index = first_index {$_ eq $Node} @iplist;
		$loc = $loclist[$loc_index];
	}

	#separates OID group and instance number
	my ($Oid, $instance);
	eval{
		($Oid, $instance) = split(/\./, $fullOid);
		} or do {
			print STDERR "Read failed on line $datapoint_ctr\n";
			next;
		};
	#Ignore NULL value
	next if(!(defined $Value) || ($Value eq ""));
	#next if($Value =~ /NULL/);
	#Ignore non-number value
	next if(!(looks_like_number($Value)));
	
		

	#convert time to useable format
	$Time =~ s/\.//;

	printf(WRITEOUT"%s,location=%s,inst=%s value=%s %s\n", $Oid, $loc, $instance, $Value, $Time);

	#Check if we need a new outfile
	$datapoint_ctr++;
	if ($datapoint_ctr>$datapoint_limit){
		$datapoint_ctr=0;
		$fileblock++;
		close(WRITEOUT);
		open(WRITEOUT, '>>', "lp_data/${outfile}_${fileblock}.lp") || die $!;
		print STDERR "${outfile}_${fileblock}.lp full...\n";
	}

}
close(READIN);
close(WRITEOUT);
print STDERR " ${outfile}_${fileblock}.lp last file -- done. \n";



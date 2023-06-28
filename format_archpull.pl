#!/usr/bin/perl
#
#format_archpull.pl (filename)
#File must be from Infinera PM archive
#how to write from 
use warnings;
use strict;
use List::MoreUtils 'first_index';
use File::Basename;
use List::Util 'any';
use Time::Local;


#IP to location arrays
my @locarch = qw( MDSNWI1 MDSNWI2 MlLWWl1 CHCGIL1 STPLMN1);
my @loclist = qw( mad1-milw mad2-chic milw-mad1 chic-mad2 stpl-mad2);

#Instance to port arrays--by location
my @mad1inst = qw( 3-B-1-L1-1 3-B-1-L1-3 3-B-1-L1-5 3-B-1-L1-7 3-B-1-L1-9);
my @mad1port = qw( 3B1-L1-1 3B1-L1-3 3B1-L1-5 3B1-L1-7 3B1-L1-9);

my @mad2inst = qw( 3-B-1-L1-1 3-B-1-L1-3 3-B-1-L1-5 3-B-1-L1-7 3-B-1-L1-9);
my @mad2port = qw( 3B1-L1-1 3B1-L1-3 3B1-L1-5 3B1-L1-7 3B1-L1-9);

my @milwinst = qw( 3-A-1-L1-1 3-A-1-L1-3 3-A-1-L1-5 3-A-1-L1-7 3-A-1-L1-9);
my @milwport = qw( 3A1-L1-1 3A1-L1-3 3A1-L1-5 3A1-L1-7 3A1-L1-9);

my @chicinst = qw( 2-A-2-L1-1 2-A-2-L1-3 2-A-2-L1-5 2-A-2-L1-7 2-A-2-L1-9);
my @chicport = qw( 2A2-L1-1 2A2-L1-3 2A2-L1-5 2A2-L1-7 2A2-L1-9);

my @stplinst = qw( 3-B-1-L1-1 3-B-1-L1-3 3-B-1-L1-5 3-B-1-L1-7 3-B-1-L1-9);
my @stplport = qw( 3B1-L1-1 3B1-L1-3 3B1-L1-5 3B1-L1-7 3B1-L1-9);

#location index to port/instance array references
my @loc_inst_ref = (\@mad1inst, \@mad2inst, \@milwinst, \@chicinst, \@stplinst);
my @loc_port_ref = (\@mad1port, \@mad2port, \@milwport, \@chicport, \@stplport);

#OID to measurement arrays
my @OIDlist = qw( ChanOchChromaticDispersionMin
					ChanOchChromaticDispersionMax
					ChanOchChromaticDispersionAve
					PmdMin
					PmdMax
					PmdAve
					SoPmdMin
					SoPmdMax
					SoPmdAve);
my @measurelist = qw( CDMin CDMax CDAve PmdMin PmdMax PmdAve 2PmdMin 2PmdMax 2PmdAve);					
my @indexlist = ();

#Read in fineame argument and get basename
my $infile = $ARGV[0];
my ($outfile, $path, $suffix) = fileparse ($infile, ".csv");
#print STDERR "Outfile: $outfile \n";

#used for keeping files under 10MB limit
my $datapoint_limit = 4990; 
my $datapoint_ctr = 0;
my $fileblock = 1;
my $writeflag = 0;

#open read and write files
open(READIN,"$infile") || die $!;
open(WRITEOUT, '>>', "lp_data/${outfile}_${fileblock}.lp") || die $!;

#used to map tag variables for formatting
my $loc;

#Find location of file data 
my $junk;
($loc, $junk) = split (/_/, $outfile, 2);

#load location and respective instances for tagging
my $loc_index = first_index {$_ eq $loc} @locarch;
$loc = $loclist[$loc_index];
#print STDERR "Loc: $loc \n";

my @instancearray = @{$loc_inst_ref[$loc_index]};
my @portarray = @{$loc_port_ref[$loc_index]}; 

#Read down to where we want to search
while (<READIN>)
{
	#chomp;
	my @line = split (/,/);

	#Once we meet the correct section...
	if ($line[0] eq "h_OCHCTP")
	{
		##print STDERR "h_OCHCTP found \n";
		#Identify the index for each measurement we want to grab
		foreach my $measure (@OIDlist)
		{
			push (@indexlist, first_index {$_ eq $measure} @line);
		}
		##print STDERR "Indexlist: @indexlist \n";
		last;
	}
}

#Identify lines that match the instances we want
while(<READIN>)
{
	#chomp;
	my @line = split (/,/);

	#If line was empty, we are done here
	last if($line[0] eq "");

	#Look for instance match
	my $port_index = first_index {$_ eq $line[0]} @instancearray;

	#Once we identify a line with our instance
	if ($port_index > -1)
	{
		my $port = $portarray[$port_index];
		#Grab the values we want and store them by OID/measure/index list
		my $badtime = $line[2];
		my @values = ();
		foreach my $index (@indexlist)
		{
			push (@values, $line[$index]);
		}

		#format time to ns timestamp
		my ($year, $month, $day, $hour, $minute, $second) = split (/[.]/, $badtime);
		my $Time = timelocal ($second,$minute,$hour,$day,$month-1,$year);
		#second to ns precision
		$Time = $Time * 1000000000;
		#And print out the return
		for (my $i=0; $i < @values; $i++)
		{
			my $Value = $values[$i];
			#ensure that the value is valid
			next if ($Value eq "");
			$Value = sprintf("%.2f", $Value);
			my $measurement = $measurelist[$i];
			#then print out
			printf(WRITEOUT"%s,location=%s,port=%s value=%s %s\n", 
			$measurement, $loc, $port, $Value, $Time);
			$datapoint_ctr++;

			#if we need to start a new file
			if ($datapoint_ctr>$datapoint_limit)
			{
				$datapoint_ctr=0;
				$fileblock++;
				close(WRITEOUT);
				open(WRITEOUT, '>>', "lp_data/${outfile}_${fileblock}.lp") || die $!;
			}
		}

	}

}

close(READIN);
close(WRITEOUT);
#print STDERR " done. \n";


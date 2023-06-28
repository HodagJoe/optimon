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


#IP to location arrays
my @iplist = qw( 128.104.128.132 205.213.249.2 205.213.249.133 205.213.249.125 205.213.249.26 205.213.110.66);
my @loclist = qw( mad1-milw mad2-chic milw-mad1 chic-mad2 stpl-mad2 lab1);

#Instance to port arrays--by location
my @mad1inst = qw( 12582986 12582987 12582988 12582989 12582990);
my @mad1port = qw( 3B1-L1-1 3B1-L1-3 3B1-L1-5 3B1-L1-7 3B1-L1-9);

my @mad2inst = qw( 12582985 12582986 12582987 12582988 12582989);
my @mad2port = qw( 3B1-L1-1 3B1-L1-3 3B1-L1-5 3B1-L1-7 3B1-L1-9);

my @milwinst = qw( 12584941 12584942 12584943 12584944 12584945);
my @milwport = qw( 3A1-L1-1 3A1-L1-3 3A1-L1-5 3A1-L1-7 3A1-L1-9);

my @chicinst = qw( 8399916 8399917 8399918 8399919 8399920);
my @chicport = qw( 2A2-L1-1 2A2-L1-3 2A2-L1-5 2A2-L1-7 2A2-L1-9);

my @stplinst = qw( 12585048 12585049 12585050 12585051 12585052);
my @stplport = qw( 3B1-L1-1 3B1-L1-3 3B1-L1-5 3B1-L1-7 3B1-L1-9);

my @lab1inst = qw( 12622106 12621930 12621931 12621932 12621933 12621934
			12621935 12621936 12621937 12621938 12621939 
			12621981 4208306 4211305 
			12621940 12621941 12621942 12621943 12621944
			12622105
			12622094 12622095 12622096 12622097 12622098
			12622099 12622100 12622101 12622102 12622103);
my @lab1port = qw( SCH 3A1-L1-1 3A1-L1-10 3A1-L1-2 3A1-L1-3 3A1-L1-4
			3A1-L1-5 3A1-L1-6 3A1-L1-7 3A1-L1-8 3A1-L1-9 
			OFXSCG BAND-1 BAND-2 
			3A1-L1-1 3A1-L1-3 3A1-L1-5 3A1-L1-7 3A1-L1-9 
			XTN-LAB1
			3A1-L1-1 3A1-L1-10 3A1-L1-2 3A1-L1-3 3A1-L1-4
			3A1-L1-5 3A1-L1-6 3A1-L1-7 3A1-L1-8 3A1-L1-9);

#location index to port/instance array references
my @loc_inst_ref = (\@mad1inst, \@mad2inst, \@milwinst, \@chicinst, \@stplinst, \@lab1inst);
my @loc_port_ref = (\@mad1port, \@mad2port, \@milwport, \@chicport, \@stplport, \@lab1port);

#OID to measurement arrays
my @OIDlist = qw( schCtpPmRealPmd schCtpPmRealSoPmd carrierCtpPmRealPmd ochCtpPmRealPmd ochCtpPmBerPreFec
		bandCtpPmRealBandOchOpr ochCtpPmRealBerPostFec);
my @measurelist = qw( PMD 2oPMD PMD PMD BER
		OchOpr BERpost);
#my @OIDlist = qw( 	otuKiPmRealNumberOfCorrectedZeros
#			otuKiPmRealNumberOfCorrectedOnes
#			otuKiPmRealCorrectedBits
#			otuKiPmRealQValue
#			
#			schCtpPmRealPmd
#			schCtpPmRealSoPmd
#			schCtpPmRealChanSchOpt
#			
#			ochCtpPmRealChanOchCD
#			ochCtpPmBerPreFec
#			ochCtpPmRealChanOchQValue
#
#			ofxScgPtpPmRealChanScgOpr
#			ofxScgPtpPmRealTxEdfaOpr
#
#			bandCtpPmRealOchSpanLoss
#			bandCtpPmRealNetSpanLoss
#			bandCtpPmRealBandOchOpr
#			bandCtpPmRealBandOpr
#			bandCtpPmRealBmmPostEdfa
#			);
#			#ochCtpPmRealPhaseCorrection (PhaseCor)
#			#bmmOcgPtpPmRealBmmOcgOpt 4211306/7/8/9/4211313/4217305/6/7/4239385/6/7/8
#			
#my @measurelist = qw( Cor0 Cor1 CorBit QVal 
#			PMD 2oPMD OpTx 
#			CD BER QVal
#			OFXSCG-Opr OFXSCG-TxEdfa-Opr
#			OchSpanLoss NetSpanLoss BandOchOpr BandOpr BmmPostEdfa);
#
#			#BMMOCG-Opr				

#Read in fineame argument and get basename
my $infile = $ARGV[0];
my ($outfile, $path, $suffix) = fileparse ($infile, ".data");
print STDERR "Outfile: $outfile \n";

#used for keeping files under 10MB limit
my $datapoint_limit = 5000; 
my $datapoint_ctr = 0;
my $fileblock = 1;
my $writeflag = 0;

#Will format data by measurement (delta requires it)
foreach my $item (@OIDlist) {
	format_data($item);
}

#format_data("Cor0");

print STDERR "$outfile complete\n";


#split_file searches the file for matching entries and outputs to csv
sub format_data {
	#start formatting common values
	my ($oidscan) =@_;
	my $index = first_index {$_ eq $oidscan} @OIDlist;
	my $measurement = $measurelist[$index];
	print STDERR "Working: $oidscan...";

	#used to map tag variables for formatting
	my $loc = "X" ;
	my @instancearray = ();
	my @portarray = ();

	#used when converting counters to delta value
	my $usedelta = 0;
	if ($measurement =~ /Cor0|Cor1|CorBit/){
		$usedelta = 1;
	}
	my @delta_instance = (); #instance_array
	my @delta_last = (); #last_value
	my $delta_index; #inst_index
	my $delta;

	#open read and write files
	open(READIN,"$infile") || die $!;
	open(WRITEOUT, '>>', "lp_data/${outfile}_${fileblock}.lp") || die $!;
	
	while(<READIN>){
		#entries expected in timestamp(9), IP, OID, and value format
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
			@instancearray = @{$loc_inst_ref[$loc_index]};
			@portarray = @{$loc_port_ref[$loc_index]};
		}

		#separates OID group and instance number
		my ($Oid, $instance);
		eval{
			($Oid, $instance) = split(/\./, $fullOid);
			} or do {
				print STDERR "Read failed on line $datapoint_ctr\n";
				next;
			};

		#skip datapoints if wrong OID
		next unless ($Oid =~ $oidscan);

		#determine if instance is valid
		my $inst_index = first_index {$_ eq $instance} @instancearray;
		#next if ( $inst_index eq -1);

		#find port name
		my $port;
		if ($inst_index eq -1){
			#print STDERR "No named instance found for $instance\n";
			$port = substr($instance, -4);
			#print STDERR "Substituted: $port\n";
		} else {
			$port = $portarray[$inst_index];
		}
		
		#convert time to useable format
		$Time =~ s/\.//;

		$writeflag=0;
		if($usedelta==0){
			#non-delta operations (currently only float)
		printf(WRITEOUT"%s,location=%s,port=%s value=%s %s\n", 
			$measurement, $loc, $port, $Value, $Time);
			$writeflag=1;
		} else {
			#delta operations here

			# look for instance in delta_array
			$delta_index = first_index {$_ eq $instance} @delta_instance;

			# If we have previous values for an instance, calulate delta and write
			if ($delta_index > -1){
				$delta = $Value - $delta_last[$delta_index];
				
				#overflow behavior-saturate value
				$delta_last[$delta_index] = $Value;
				if($delta>4294444444){
					$delta = 4294444444; # saturate value
				}

				if($delta>0){
				     printf(WRITEOUT"%s,location=%s,port=%s value=%su %s\n", 
			$measurement, $loc, $port, $delta, $Time);
				     $writeflag=1;
				}
			
			} else {
				push (@delta_instance, $instance);
				push (@delta_last, $Value);
			}

		}
		#If we wrote, then check to see if we need a new outfile
		if ($writeflag==1){
			$datapoint_ctr++;
			if ($datapoint_ctr>$datapoint_limit){
				$datapoint_ctr=0;
				$fileblock++;
				close(WRITEOUT);
				open(WRITEOUT, '>>', "lp_data/${outfile}_${fileblock}.lp") || die $!;
			}
		}
		
	}
	close(READIN);
	close(WRITEOUT);
	print STDERR " done. \n";
	return 1;
}


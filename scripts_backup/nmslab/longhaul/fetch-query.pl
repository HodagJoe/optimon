#!/bin/perl
use POSIX qw(strftime);

$DEBUG = 0;
$file = $ARGV[0];

while ( -e 'runnit' ) {

# open up a file containing a space delimited host, OID, instances
open(QUERY,"$file.poll") || die;
my $date= strftime "%y%m%d", localtime;
open(DATA,'>>',"${file}_${date}.data") || die;

# read in the list of SNMP queries
while (<QUERY>) {
   next if /^#/;
   ($Node, $snmpQuery, $Instance) = split;
   next if not $Node;
   printf("Node=%s, snmpQuery=%s, Instance=%s\n",$Node, $snmpQuery, $Instance) if $DEBUG > 1;
   if ( $Instance ){
      $snmpCmd = sprintf("snmpwalk -v3 %s %s.%s -Oqse", $Node, $snmpQuery, $Instance);
   } else {
      $snmpCmd = sprintf("snmpwalk -v3 %s %s -Oqse", $Node, $snmpQuery);
   }
   printf("%s\n", $snmpCmd) if $DEBUG > 1;
   @results = `$snmpCmd`;
   print @results if $DEBUG > 2;
  foreach $line (@results) {
   #if ( ($Oid, @Value) = split('\s+', `$snmpCmd`) ){
   $line =~ s/Wrong Type \(should be INTEGER\): //;
   if ( ($Oid, @Value) = split('\s+', $line) ){
      $eTime = `date +%s.%N`; $eTime =~ s/\n//;
      $friendlyDate = `date +%D_%T.%N`; $friendlyDate =~ s/\n//;
      $OidValue = $Value[$#Value];
      if ( $OidValue =~ /"/ ) {
         $OidValue =~ s/"//g;
         #$OidHundreths = sprintf("%.f", $OidValue);
         #$OidHundreths = sprintf("%.f", $OidValue);
         # print "$OidHundreths \n";
         #$OidValue = $OidHundreths;
      }
      next if ( $OidValue =~ /NULL/ );
      printf("%s %s %s %s\n", $friendlyDate, $Node, $Oid, $OidValue) if $DEBUG > 0;
      printf("friendlyDate=%s, Node=%s, Oid=%s, Value=%s\n", $friendlyDate, $Node, $Oid, $OidValue) if $DEBUG > 2;
      $dataItem = sprintf("%s %s %s %s", $eTime, $Node, $Oid, $OidValue);
      printf("dataItem=%s\n", $dataItem) if $DEBUG > 2; 
      printf(DATA"%s\n", $dataItem);
   }
  }
}
close(QUERY);
close(DATA);
#sleep 1;
}

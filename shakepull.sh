#!/usr/bin/expect

set timeout 20

set password [lindex $argv 0]

eval spawn "sftp -pr myshake@seismograph.cs.wisc.edu:/opt/data/archive /u/c/a/catudal/DataFiles/RShake/"
expect "assword:"
send "$password\r";
interact

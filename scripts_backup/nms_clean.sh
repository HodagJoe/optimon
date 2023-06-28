#!/usr/bin/expect

set timeout 20

eval spawn "ssh -i /u/c/a/catudal/.ssh/id_rsa_np wej@nms-lab.boreas.net"
expect "$ "
send "cd /home/wej/joec/longhaul\r"
expect "$ "
send "pwd\r"
expect "/home/wej/joec/longhaul\r"
send "./cleanup.sh\r"
expect "doneskis.\r"
send "exit\r"

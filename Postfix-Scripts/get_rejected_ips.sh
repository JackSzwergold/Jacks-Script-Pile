#!/bin/bash
#
# Peter Kiem          .^.   | E-Mail    : <zordah@zordah.net>
# Zordah IT           /V\   | Mobile    : +61 0414 724 766
# IT Consultancy &  /(   )\ | WWW       : www.zordah.net
# Internet Hosting   ^^-^^  | ICQ       : "Zordah" 866661
# 

CURRLOG=/var/log/postfix
LASTLOG=/var/log/postfix.1

cat $LASTLOG $CURRLOG | grep "reject: RCPT from" | cut -d "[" -f 3 | cut
-d "]" -f 1 | sort | uniq -c | awk '
BEGIN {
  print("IP subnets with more than 5 mail rejections in the last 2 postfix
logs");
  print("");
  print("# Rejects     IP Address");
  print("=========     ==========");
  lastsubnet = "";
  rejects = 0;
}

{
  split($2, octet, ".");
  subnet = octet[1] "." octet[2] "." octet[3];
  if (subnet != lastsubnet) {
    if (rejects > 5) {
      for (Loop = 1; Loop < ipindex; Loop++) {
        printf("%9d     %s\n", RejectCount[Loop], IPAddress[Loop]);
      }
      printf("\n");
    }
    lastsubnet = subnet;
    rejects = 0;
    ipindex = 1;
  }
  RejectCount[ipindex] = $1;
  IPAddress[ipindex] = $2;
  rejects += $1;
  ipindex++;
}

END {
  if (rejects > 5) {
    for (Loop = 1; Loop < ipindex; Loop++) {
      printf("%9d     %s\n", RejectCount[Loop], IPAddress[Loop]);
    }
  }
}
' | mail -s "SMTP rejected IP addresses" root

exit 0
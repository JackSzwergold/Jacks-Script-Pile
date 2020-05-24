#!/usr/bin/perl
# A simple Perl script to flood a target server with HTTP requests.
# Useful for basic DDoS protection system testing.

use IO::Socket;
use strict;

my $how_many = 30;
my $target_host = "sandbox.local:80";

for (0..$how_many) {
  my($response);
  my($SOCKET) = new IO::Socket::INET(Proto => "tcp", PeerAddr=> $target_host);
  if (!defined $SOCKET) { die $!; }
  print $SOCKET "GET /?$_ HTTP/1.0\n\n";
  $response = <$SOCKET>;
  print $response;
  close($SOCKET);
}

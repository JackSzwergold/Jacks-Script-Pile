#!/usr/bin/perl -n -w
# filter from stdin or given file all "expected" errors/warnings
# so that we can see if something serious happens.
# use it like this for example:
# tail -f /var/log/mail.log | postfix_errors

# 2004-05-20, dws@ee.ethz.ch


m{^.{16}\S+\ postfix\/(\w+)\[\d+\]:
    \ (?:\[ID\ \d+\ \w+\.\w+\]\ )?
    (?:[A-Z]+:\ )?
    (?:reject|warning|error|fatal|panic):
}gx or next;
my $s=$1;
> >
if($s eq 'smtpd') {
    m{\G.*(?:
     Invalid\ domain
    |Greylisted
    |User\ unknown
    |Host\ not\ found
    |Illegal\ address
    |Obsolete\ address
    |Host\ name\ has\ no\ address
    |Relay\ access\ denied
    |need\ fully-qualified\ address
    |bad\ certificate
    |unknown\ ca
    |network_biopair_interop # SSL error
    |SASL\ (?:LOGIN|PLAIN)\ authentication\ failed
    |Password\ verification\ failed
    |with\ my\ own\ hostname
    |sent\ non-SMTP
    |numeric\ result
    )}x and next;
}
elsif($s eq 'smtp') {
    m{\G.*(?:
     \ said:
    |numeric\ domain\ name
    |malformed\ domain
    |empty\ hostname
    |no\ MX\ host
    |my\ own\ hostname
    )}x and next;
}
elsif($s eq 'cleanup') {
    m{\G.*(?:
    too\ many\ comments
    )}x and next;
}
print;

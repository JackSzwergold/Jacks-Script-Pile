#!/bin/sh
# System dependent settings
ALTERMIME=/usr/local/bin/altermime
ALTERMIME_DIR=/var/spool/altermime
SENDMAIL=/usr/sbin/sendmail

# Exit codes of commands invoked by Postfix are expected
# to follow the conventions defined in <sysexits.h>.
TEMPFAIL=75
UNAVAILABLE=69

# Change in to alterMIME's working directory
# Notify Postfix if 'cd' fails.
cd $ALTERMIME_DIR || { echo $ALTERMIME_DIR does not exist; exit $TEMPFAIL; }

# Clean up when done or when aborting.
trap "rm -f in.$$" 0 1 2 3 15

# Write mail to a temporary file
# Notify Postfix if this fails
cat >in.$$ || { echo Cannot write to $ALTERMIME_DIR; exit $TEMPFAIL; }

# Call alterMIME, hand over the message and
# tell alterMIME what to do with it
$ALTERMIME  --input=in.$$ \
            --disclaimer=/etc/postfix/disclaimer.txt \
            --disclaimer-html=/etc/postfix/disclaimer.txt \
            --xheader="X-Copyrighted-Material: Please visit http://www.example.com/message_disclaimer.html" || \
            { echo Message content rejected; exit $UNAVAILABLE; }

# Call sendmail to reinject the message into Postfix
$SENDMAIL "$@" <in.$$

# Use sendmail's EXIT STATUS to tell Postfix
# how things went.
exit $?

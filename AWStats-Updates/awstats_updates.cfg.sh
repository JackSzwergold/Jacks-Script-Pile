#!/bin/bash -l

################################################################################
# Configuration options.
################################################################################

DOMAIN_ARRAY=();
DOMAIN_ARRAY[0]='prod0.preworn.com';
DOMAIN_ARRAY[1]='www.preworn.com';
DOMAIN_ARRAY[2]='staging.preworn.com';

AWSTATS_SCRIPT='/usr/share/awstats/wwwroot/cgi-bin/awstats.pl';

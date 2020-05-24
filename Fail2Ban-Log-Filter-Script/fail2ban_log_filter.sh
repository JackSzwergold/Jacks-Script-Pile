#!/bin/bash

##########################################################################################
#
# Fail2Ban Log Filter (fail2ban_log_filter.sh) (c) by Jack Szwergold
#
# Fail2Ban Log Filter is licensed under a
# Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
#
# You should have received a copy of the license along with this
# work. If not, see <http://creativecommons.org/licenses/by-nc-sa/4.0/>.
#
# w: http://www.preworn.com
# e: me@preworn.com
#
# Created: 2015-10-27, js
# Version: 2015-10-27, js: creation
#          2015-10-27, js: development
#
##########################################################################################

awk '/WARNING/ && /Ban/ { split($2,split_2,","); printf "%s %s %s %s %s\n", $1, split_2[1], substr($5, 2, length($5) - 2), $6, $7 }' < /dev/stdin

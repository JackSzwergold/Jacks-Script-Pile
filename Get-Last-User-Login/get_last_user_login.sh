#!/bin/bash

##########################################################################################
#
# Get Last User Login (get_last_user_login.sh) (c) by Jack Szwergold
#
# Get Last User Login is licensed under a
# Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
#
# You should have received a copy of the license along with this
# work. If not, see <http://creativecommons.org/licenses/by-nc-sa/4.0/>. 
#
# w: http://www.preworn.com
# e: me@preworn.com
#
# Created: 2011-11-29, js
# Version: 2011-11-29, js: creation
#          2011-11-29, js: development
#
##########################################################################################

(
   for USERNAME in $(sed 's/:.*//' /etc/passwd)
   do
     echo '--------------------------------------------------------------------------------'
     finger $USERNAME
     echo ''
   done
)

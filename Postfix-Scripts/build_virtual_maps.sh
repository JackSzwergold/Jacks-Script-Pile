# !/bin/bash
#
# Build all virtual mailbox maps from one source

# section: paths
SOURCE=/etc/postfix/virtual_build_map_source
VMAP=/etc/postfix/virtual_mailbox_recipients
VUID=/etc/postfix/virtual_uid_map
VGID=/etc/postfix/virtual_gid_map
AWK=/usr/bin/awk
POSTMAP=/usr/sbin/postmap

# section: build
# build $virtual_mailbox_maps
$AWK '{printf("%s %s\n",$1,$2)}' $SOURCE > $VMAP
$POSTMAP hash:$VMAP

# build $virtual_uid_maps
$AWK '{printf("%s %s\n",$1,$3)}' $SOURCE > $VUID
$POSTMAP hash:$VUID

# build $virtual_gid_maps
$AWK '{printf("%s %s\n",$1,$4)}' $SOURCE > $VGID
$POSTMAP hash:$VGID

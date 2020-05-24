# IPTables-IPSet-Rules

A repository of some IPTables and IPSet rules I use. Includes a patch to `iptables-persistent` that allows it to reload IPSet stuff on reboot.

### Patching `iptables-persistent`.

I created the patch by running this command comparing a modified file to the source file:

    diff -Naur /etc/init.d/iptables-persistent iptables-persistent-ipset > iptables-persistent-ipset.patch

And the patch can be applied to a production machine like this:

    sudo patch -fsb /etc/init.d/iptables-persistent < iptables-persistent-ipset.patch



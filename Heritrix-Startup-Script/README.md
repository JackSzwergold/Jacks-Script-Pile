Heritrix-Startup-Script
============

A Linux/Unix startup script for `heritrix` since it doesn’t come with one & it’s nice to have one. Tested & works on Ubuntu 12.04 using a Java 1.6.x install via the WebUpd8 team’s repository.

### Installation

#### Create an “init.d” script

First, using your Linux/Unix text editor of choice, create the startup script. In this example I am using `nano`:

    sudo nano /etc/init.d/heritrix

Place the contents of the `heritrix_init_d.sh` in this repo into that file. Be sure to edit local environment variables to match your setup. Here is a breakdown of the most common variables you should adjust:

- **HERITRIX_USER:** The name of the Linux/Unix system user that will be running `heritrix` on the system. Rememeber, `heritrix` does not need to be run by the `root` user and the `root` user can use `su` to run a script as another user.
- **HERITRIX_CREDENTIALS:** These are the credentials for the `heritrix` web interface. Simply change `[username]:[password]` to match your desired `[username]` & `[password]`.
- **HERITRIX_HOME:** The installation home for the actual `heritrix` install. In this case, I like to install programs like this in `/opt/`.
- **JAVA_HOME:** Set this to the appropriate Java JRE install on your system.

#### Set proper permsissions

With that set, now change the user & group ownerships of that file to `root` like this:

    sudo chown root:root /etc/init.d/heritrix

Be sure to give it proper execute permissions:

    sudo chmod 755 /etc/init.d/heritrix

#### Set System-V style init script links

Now run `update-rc.d` to create the proper Unix System-V style init links like this:

    sudo update-rc.d heritrix defaults

#### Remove System-V style init script links

If for some reason you need to remove the init scripts created by `update-rc.d` so as to prevent starting on starup, just delete these files:

	sudo rm /etc/rc0.d/K20heritrix
	sudo rm /etc/rc1.d/K20heritrix
	sudo rm /etc/rc6.d/K20heritrix
	sudo rm /etc/rc2.d/S20heritrix
	sudo rm /etc/rc3.d/S20heritrix
	sudo rm /etc/rc4.d/S20heritrix
	sudo rm /etc/rc5.d/S20heritrix

### Usage

Startup scripts like this can be simple or complex. In this case, all I wanted to do is create a script that will properly start `heritrix` on starup/reboot as well as provide me with a clean way to start/stop it—as well as check runing status—from the command line.

So if you want to check the running status of `heritrix` just type in the following:

    sudo service heritrix status

Want to stop `heritrix`? Just do this:

    sudo service heritrix stop

Now that you stopped `heritrix` you can start it up again like this:

    sudo service heritrix start




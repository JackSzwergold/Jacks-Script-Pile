Unicorn-Startup-Script
============

A Linux/Unix startup script for the Ruby GEM `unicorn` since it’s nice to have one. Tested & works on Ubuntu 12.04 using a Ruby 2.1.5 install from source code.

### Installation

#### Create an “init.d” script

First, using your Linux/Unix text editor of choice, create the startup script. In this example I am using `nano`:

    sudo nano /etc/init.d/unicorn

Place the contents of the `unicorn_init_d.sh` in this repo into that file. Be sure to edit local environment variables to match your setup. Here is a breakdown of the most common variables you should adjust:

- **UNICORN_USER:** The name of the Linux/Unix system user that will be running `unicorn` on the system. Rememeber, `unicorn` does not need to be run by the `root` user and the `root` user can use `su` to run a script as another user.
- **UNICORN_HOME:** The installation home for the actual `unicorn` Ruby applictaion install.
- **BUNDLE_HOME:** Set this to the appropriate path where `bundle` is installed on your system. You can easilly get this using `which bundle` from the command line.

#### Set proper permsissions

With that set, now change the user & group ownerships of that file to `root` like this:

    sudo chown root:root /etc/init.d/unicorn

Be sure to give it proper execute permissions:

    sudo chmod 755 /etc/init.d/unicorn

#### Set System-V style init script links

Now run `update-rc.d` to create the proper Unix System-V style init links like this:

    sudo update-rc.d unicorn defaults

#### Remove System-V style init script links

If for some reason you need to remove the init scripts created by `update-rc.d` so as to prevent starting on starup, just delete these files:

	sudo rm /etc/rc0.d/K20unicorn
	sudo rm /etc/rc1.d/K20unicorn
	sudo rm /etc/rc6.d/K20unicorn
	sudo rm /etc/rc2.d/S20unicorn
	sudo rm /etc/rc3.d/S20unicorn
	sudo rm /etc/rc4.d/S20unicorn
	sudo rm /etc/rc5.d/S20unicorn

### Usage

Startup scripts like this can be simple or complex. In this case, all I wanted to do is create a script that will properly start `unicorn` on starup/reboot as well as provide me with a clean way to start/stop it—as well as check runing status—from the command line.

So if you want to check the running status of `unicorn` just type in the following:

    sudo service unicorn status

Want to stop `unicorn`? Just do this:

    sudo service unicorn stop

Now that you stopped `unicorn` you can start it up again like this:

    sudo service unicorn start



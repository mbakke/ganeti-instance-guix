# ganeti-instance-guix

Create Guix instances on Ganeti!

## Usage:

    $ gnt-instance add -o guix+default my-instance

The default configuration assumes gnt-network is configured and will
create an instance with static networking, a serial console, and an SSH
server that reuses the hosts */root/.ssh/authorized_keys* for `root`.

It is possible to use a specific Guix commit via an OS parameter:

    $ gnt-instance add -o guix+default \
      -O "commit=ecd5db37ff,filesystem=ext4,layout=basic"

Other supported parameters are *branch*, *repo_uri*, and
*disable_authentication*.  If any of these parameters are set,
`guix time-machine` will be used to build the image.  Otherwise the hosts
(root user) Guix version will be used.

You can also build for a specific architecture by passing the 'system'
parameter, and even cross-compile a disk image by passing 'target'.

    $ gnt-instance add -o guix+default -O system=i686-linux

Behind the scenes, this uses `guix system init` to deploy a configuration
that matches a filesystem and partitioning layout combination.

## Installation:

    $ ./configure --sysconfdir=/etc --localstatedir=/var
    $ make && sudo make install

## Dependencies:

* Guix
* util-linux
* multipath-tools
* e2fsprogs
* parted

These are optional:

* xfsprogs
* btrfs-progs
* lvm2, for LVM support (experimental)

## Limitations:

* No import and export functionality yet.
* Runs with elevated privileges on the host.
  * Do not use this with untrusted configuration files!

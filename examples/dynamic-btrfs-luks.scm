(use-modules (gnu)) ;; needed for "device" below
(load (string-append (dirname (current-filename)) "/config-base.scm"))
(operating-system
 (inherit default-os)
 (mapped-devices (let ((mycryptuuid (getenv "LUKS_UUID")))
		   (list
		    (mapped-device
		     (source (uuid mycryptuuid))
		     (targets (list "cryptroot"))
		     (type luks-device-mapping)))))
 (file-systems
  (let* ((mylabel (string-append (getenv "INSTANCE_NAME") "-system"))
	 (%my-filesystems
	  (list
	   (file-system
	    (device (file-system-label mylabel))
	    (mount-point "/")
	    (dependencies mapped-devices)
	    (type "btrfs")
	    (options "subvol=/system-root"))
	   (file-system
	    (device (file-system-label mylabel))
	    (needed-for-boot? #t)
	    (mount-point "/gnu/store")
	    (dependencies mapped-devices)
	    (type "btrfs")
	    (options "subvol=system-root/gnu/store"))
	   (file-system
	    (device (file-system-label mylabel))
	    (mount-point "/var/log")
	    (needed-for-boot? #t)
	    (dependencies mapped-devices)
	    (type "btrfs")
	    (options "subvol=system-root/var/log"))
	   (file-system
	    (device (file-system-label mylabel))
	    (mount-point "/var/lib/mysql")
	    (needed-for-boot? #t)
	    (dependencies mapped-devices)
	    (type "btrfs")
	    (options "subvol=system-root/var/lib/mysql"))
	   (file-system
	    (device (file-system-label mylabel))
	    (mount-point "/home")
	    (needed-for-boot? #t)
	    (dependencies mapped-devices)
	    (type "btrfs")
	    (options "subvol=system-root/home"))
	   (file-system
	    (device (file-system-label mylabel))
	    (mount-point "/swap")
	    (dependencies mapped-devices)
	    (needed-for-boot? #t)
	    (type "btrfs")
	    (flags '(no-atime))
	    (options "subvol=/system-root/swap,compress=none")))))
    (append
     %my-filesystems
     %base-file-systems)))
 (swap-devices
  (list (swap-space
	 (target "/swap/swapfile")))))

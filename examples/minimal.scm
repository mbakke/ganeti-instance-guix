(use-modules (gnu))
(use-service-modules networking ssh)
(use-package-modules disk nvi)

(define vm-image-motd (plain-file "motd" "
Welcome to GuixSD on Ganeti!

This configuration file is available at /etc/current-config.scm.  You
probably want to make a copy of this file, tweak it to your needs, and
run `guix system reconfigure my-config.scm`.

Remember to `guix pull` first to fetch the latest package definitions.

Have fun!\n"))

(operating-system
  (host-name "gnu")
  (timezone "Etc/UTC")
  (locale "en_US.utf8")

  ;; Assuming /dev/sdX is the target hard disk, and "my-root" is
  ;; the label of the target root file system.
  (bootloader (grub-configuration (device "/dev/sda")
                                  (terminal-outputs '(console))))
  (file-systems (cons (file-system
                        (device "my-root")
                        (title 'label)
                        (mount-point "/")
                        (type "ext4"))
                      %base-file-systems))

  ;; This is where user accounts are specified.  The "root"
  ;; account is implicit, and is initially created with the
  ;; empty password.
  (users %base-user-accounts)

  ;; Globally-installed packages.
  (packages (cons* nvi parted
                   %base-packages))

  (services (cons*
	     (simple-service 'store-current-config
			     etc-service-type
			     `(("current-config.scm"
				,(local-file (assoc-ref
					      (current-source-location)
					      'filename)))))
	     (dhcp-client-service)
	     (service openssh-service-type
		      (openssh-configuration
		       (permit-root-login #t)))
	     (modify-services %base-services
              (login-service-type config =>
                                  (login-configuration
                                    (inherit config)
                                    (motd vm-image-motd)))))))

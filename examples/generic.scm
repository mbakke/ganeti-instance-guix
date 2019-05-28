(use-modules (gnu))
(use-service-modules networking ssh)
(use-package-modules disk nvi)

(define vm-image-motd (plain-file "motd" "
Welcome to Guix on Ganeti!

This configuration file is available at /etc/current-config.scm.  You
probably want to make a copy of this file, tweak it to your needs, and
run `guix system reconfigure my-config.scm`.

Remember to `guix pull` first to fetch the latest package definitions.

Have fun!\n"))

(operating-system
  (host-name "gnu")
  (timezone "Etc/UTC")
  (locale "en_US.utf8")

  (kernel-arguments '("console=ttyS0"))
  (bootloader (grub-configuration (target "/dev/sda")
                                  (terminal-outputs '(console))))

  (file-systems (cons (file-system
                        (device "/dev/sda1")
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
	     (service dhcp-client-service-type)
	     (service openssh-service-type
		      (openssh-configuration
		       (permit-root-login 'without-password)
                       (authorized-keys
                        `(("root" ,(local-file "/root/.ssh/authorized_keys"))))))
	     (modify-services %base-services
              (login-service-type config =>
                                  (login-configuration
                                    (inherit config)
                                    (motd vm-image-motd)))))))

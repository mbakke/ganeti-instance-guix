(use-modules (gnu)
             (ice-9 match)
             (srfi srfi-60)
	     (ice-9 textual-ports)
	     (guix build utils)
             (rnrs io ports))
(use-package-modules certs screen linux)
(use-service-modules networking ssh sysctl)

(let ((envfile (string-append (dirname (current-filename)) "/config.env")))
  (if (file-exists? envfile)
      (call-with-input-file envfile
	(lambda (port)
	  (let ((lines (get-string-all port)))
	    (environ
	     (append (delete "" (string-split lines #\newline))
		     (environ))))))))

(define (cidr->netmask address)
  "Convert a CIDR specification such as 10.0.0.0/24 to 255.255.255.0."
  (let ((mask (string->number (match (string-split address #\/)
                                     ((address mask) mask)
                                     (_ "32")))))
    (inet-ntop AF_INET
               (arithmetic-shift (inet-pton AF_INET "255.255.255.255")
                                 (- 32 mask)))))

(define default-os
  (operating-system
   (host-name (getenv "INSTANCE_NAME"))
   ;; Take the hosts time zone, sans trailing newline if present.
   (timezone (string-trim-right
              (call-with-input-file "/etc/timezone"
		(lambda (port)
                  (get-string-all port)))
              #\newline))
   (locale "en_US.utf8")
   
   (kernel-arguments '("console=ttyS0"))

   ;; Boot in "legacy" BIOS mode, assuming /dev/sdX is the
   ;; target hard disk
   ;; (bootloader (bootloader-configuration
   ;;              (bootloader grub-bootloader)
   ;;              (targets '("/dev/vda"))))
   (bootloader (bootloader-configuration
                (bootloader grub-bootloader)
                (targets `(,(getenv "TARGET_DEVICE")))))
   (file-systems
    (cons*
     (file-system
      (device (file-system-label (string-append (getenv "INSTANCE_NAME") "-system")))
      (mount-point "/")
      (type "ext4"))
     %base-file-systems))
   ;; This is where user accounts are specified.  The "root"
   ;; account is implicit, and is initially created with the
   ;; empty password.
   (users %base-user-accounts)

   ;; Globally-installed packages.
   (packages (cons* lvm2 screen nss-certs btrfs-progs xfsprogs %base-packages))

   ;; Add services to the baseline
   (services
    (let ((myip (getenv "NIC_0_IP"))
          (mysubnet (getenv "NIC_0_NETWORK_SUBNET"))
          (mygateway (getenv "NIC_0_NETWORK_GATEWAY"))
          (root-authorizations
           (cond ((file-exists? "/etc/ssh/authorized_keys.d/root")
                  "/etc/ssh/authorized_keys.d/root")
                 ((file-exists? "/root/.ssh/authorized_keys")
                  "/root/.ssh/authorized_keys")
                 (else #f))))
      (cons* (service static-networking-service-type
		      (list (static-networking
			     (addresses
			      (list (network-address
			             (device "eth0")
			             (value (string-append myip "/" (cadr (string-split mysubnet #\/)))))))
			     (routes
			      (list (network-route
				     (destination "default")
				     (gateway mygateway))))
			     (name-servers (list mygateway)))))

	     (service openssh-service-type
                      (openssh-configuration
                       (permit-root-login 'prohibit-password)
		       (x11-forwarding? #t)
                       (authorized-keys
                        (if root-authorizations
                            `(("root" ,(local-file root-authorizations)))
                            '()))))
             (modify-services %base-services
			      (sysctl-service-type config =>
                                                   (sysctl-configuration
                                                    (settings (append '(("vm.swappiness" . "10"))
								      %default-sysctl-settings))))))))
   ;; Allow resolution of '.local' host names with mDNS.
   (name-service-switch %mdns-host-lookup-nss)))

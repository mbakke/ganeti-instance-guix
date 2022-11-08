(use-modules (gnu)
             (ice-9 match)
             (ice-9 textual-ports)
             (guix build utils)
             (rnrs io ports))
(use-service-modules networking ssh sysctl)

(define %target-uuid (getenv "TARGET_UUID"))

(define %mapped-devices
  (let ((luks-devices
         (if (getenv "LUKS_UUID")
             (list (mapped-device
                    (source (uuid (getenv "LUKS_UUID")))
                    (targets '("luks_root"))
                    (type luks-device-mapping)))
             '()))
        (lvm-devices
         (if (and (string=? "advanced" (getenv "OSP_LAYOUT"))
                  (not (string=? "btrfs" (getenv "FS_TYPE"))))

             (let ((myvg (string-append (getenv "INSTANCE_NAME") "_vg01")))
               (list (mapped-device
                      (source myvg)
                      (targets (list (string-append myvg "-lv_root")
                                     (string-append myvg "-lv_home")
                                     (string-append myvg "-lv_gnu_store")
                                     (string-append myvg "-lv_var_lib")
                                     (string-append myvg "-lv_var_log")
                                     (string-append myvg "-lv_swap")))
                      (type lvm-device-mapping))))
             '())))
    (append luks-devices lvm-devices)))

(define %file-systems
  (match (getenv "OSP_LAYOUT")
    ("advanced"
     (if (string=? "btrfs" (getenv "FS_TYPE"))
         (list (file-system
                 (device (uuid %target-uuid))
                 (dependencies %mapped-devices)
                 (mount-point "/")
                 (type "btrfs")
                 (options "subvol=/system-root"))
               (file-system
                 (device (uuid %target-uuid))
                 (dependencies %mapped-devices)
                 (mount-point "/gnu/store")
                 (type "btrfs")
                 (options "subvol=system-root/gnu/store"))
               (file-system
                 (device (uuid %target-uuid))
                 (dependencies %mapped-devices)
                 (mount-point "/var/log")
                 (type "btrfs")
                 (options "subvol=system-root/var/log"))
               (file-system
                 (device (uuid %target-uuid))
                 (dependencies %mapped-devices)
                 (mount-point "/var/lib")
                 (type "btrfs")
                 (options "subvol=system-root/var/lib"))
               (file-system
                 (device (uuid %target-uuid))
                 (dependencies %mapped-devices)
                 (mount-point "/home")
                 (type "btrfs")
                 (options "subvol=system-root/home"))
               (file-system
                 (device (uuid %target-uuid))
                 (dependencies %mapped-devices)
                 (mount-point "/swap")
                 (needed-for-boot? #t)
                 (type "btrfs")
                 (flags '(no-atime))
                 (options "subvol=/system-root/swap,compress=none")))
         ;; Assume LVM.
         (list (file-system
                 (device (string-append "/dev/" (getenv "INSTANCE_NAME")
                                        "_vg01/lv_root"))
                 (mount-point "/")
                 (dependencies %mapped-devices)
                 (needed-for-boot? #t)
                 (type (getenv "FS_TYPE")))
               (file-system
                 (device (string-append "/dev/" (getenv "INSTANCE_NAME")
                                        "_vg01/lv_home"))
                 (mount-point "/home")
                 (dependencies %mapped-devices)
                 (needed-for-boot? #t)
                 (type (getenv "FS_TYPE")))
               (file-system
                 (device (string-append "/dev/" (getenv "INSTANCE_NAME")
                                        "_vg01/lv_var_log"))
                 (mount-point "/var/log")
                 (dependencies %mapped-devices)
                 (needed-for-boot? #t)
                 (type (getenv "FS_TYPE")))
               (file-system
                 (device (string-append "/dev/" (getenv "INSTANCE_NAME")
                                        "_vg01/lv_var_lib"))
                 (mount-point "/var/lib")
                 (dependencies %mapped-devices)
                 (needed-for-boot? #t)
                 (type (getenv "FS_TYPE")))
               (file-system
                 (device (string-append "/dev/" (getenv "INSTANCE_NAME")
                                        "_vg01/lv_gnu_store"))
                 (mount-point "/gnu/store")
                 (dependencies %mapped-devices)
                 (needed-for-boot? #t)
                 (type (getenv "FS_TYPE"))))))
    (_
     (list (file-system
             (device (uuid %target-uuid))
             (mount-point "/")
             (dependencies %mapped-devices)
             (needed-for-boot? #t)
             (type (getenv "FS_TYPE")))))))

(define %swap-devices
  (if (and (string=? "advanced" (getenv "OSP_LAYOUT"))
           (not (string=? "btrfs" (getenv "FS_TYPE"))))
      (list (swap-space
             (dependencies %mapped-devices)
             (target (file-system-label
                      (string-append (getenv "INSTANCE_NAME")
                                     "-swap")))))
      '()))

(define default-os
  (operating-system
    (host-name (getenv "INSTANCE_NAME"))
    ;; Take the hosts time zone, sans trailing newline if present.
    (timezone (string-trim-right (call-with-input-file "/etc/timezone"
                                   (lambda (port)
                                     (get-string-all port)))
                                 #\newline))
    (locale "en_US.utf8")

    ;; Add ttyS0 for gnt-instance console <myinstance> and tty0 for
    ;; virt-viewer/remote-viewer (needed for entering LUKS-password)
    (kernel-arguments '("console=ttyS0" "console=tty0"))

    ;; Boot in "legacy" BIOS mode, assuming /dev/sdX is the
    ;; target hard disk
    ;; (bootloader (bootloader-configuration
    ;; (bootloader grub-bootloader)
    ;; (targets '("/dev/vda"))))
    (bootloader (bootloader-configuration
                  (bootloader grub-bootloader)
                  (targets `(,(getenv "TARGET_DEVICE")))))

    (mapped-devices %mapped-devices)
    (file-systems (append %file-systems %base-file-systems))
    (swap-devices %swap-devices)

    ;; This is where user accounts are specified.  The "root"
    ;; account is implicit, and is initially created with the
    ;; empty password.
    (users %base-user-accounts)

    ;; Globally-installed packages.
    (packages
     (append (map specification->package
                  '("nss-certs"))
             %base-packages))

    ;; Add services to the baseline
    (services
     (let ((myip (getenv "NIC_0_IP"))
           (mysubnet (getenv "NIC_0_NETWORK_SUBNET"))
           (mygateway (getenv "NIC_0_NETWORK_GATEWAY"))
           (root-authorizations (cond
                                  ((file-exists?
                                    "/etc/ssh/authorized_keys.d/root")
                                   "/etc/ssh/authorized_keys.d/root")
                                  ((file-exists? "/root/.ssh/authorized_keys")
                                   "/root/.ssh/authorized_keys")
                                  (else #f))))
       (append
        (list (service static-networking-service-type
                       (list (static-networking
                              (addresses
                               (list (network-address
                                      (device "eth0")
                                      (value (string-append
                                              myip "/"
                                              (cadr (string-split mysubnet
                                                                  #\/)))))))
                              (routes
                               (list (network-route
                                      (destination "default")
                                      (gateway mygateway))))
                              (name-servers (list mygateway)))))

              (service openssh-service-type
                       (openssh-configuration
                        (permit-root-login 'prohibit-password)
                        (x11-forwarding? #t)
                        (authorized-keys (if root-authorizations
                                             `(("root" ,(local-file
                                                         root-authorizations)))
                                             '())))))
        (modify-services %base-services
          (sysctl-service-type
           config =>
           (sysctl-configuration
            (settings (append '(("vm.swappiness" . "10"))
                              %default-sysctl-settings))))))))

    ;; Allow resolution of '.local' host names with mDNS.
    (name-service-switch %mdns-host-lookup-nss)))

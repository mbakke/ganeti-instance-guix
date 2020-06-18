(use-modules (gnu)
             (ice-9 match)
             (srfi srfi-60)
             (rnrs io ports))
(use-package-modules certs)
(use-service-modules networking ssh)

(define (cidr->netmask address)
  "Convert a CIDR specification such as 10.0.0.0/24 to 255.255.255.0."
  (let ((mask (string->number (match (string-split address #\/)
                                ((address mask) mask)
                                (_ "32")))))
    (inet-ntop AF_INET
               (arithmetic-shift (inet-pton AF_INET "255.255.255.255")
                                 (- 32 mask)))))

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
  (bootloader (grub-configuration (target "/dev/sda")
                                  (terminal-outputs '(console))))

  (file-systems (cons (file-system
                        (device "/dev/sda1")
                        (mount-point "/")
                        (type "ext4"))
                      %base-file-systems))

  (users %base-user-accounts)
  (packages (append (list nss-certs)
                    %base-packages))

  (services
   (let ((ip (getenv "NIC_0_IP"))
         (subnet (getenv "NIC_0_NETWORK_SUBNET"))
         (gateway (getenv "NIC_0_NETWORK_GATEWAY"))
         (root-authorizations
          (cond ((file-exists? "/etc/ssh/authorized_keys.d/root")
                 "/etc/ssh/authorized_keys.d/root")
                ((file-exists? "/root/.ssh/authorized_keys")
                 "/root/.ssh/authorized_keys")
                (else #f))))
     (append (list (static-networking-service
                    "eth0" ip
                    #:netmask (if subnet
                                  (cidr->netmask subnet)
                                  #f)
                    #:gateway (if gateway gateway #f)
                    #:name-servers (if gateway (list gateway) '()))
                   (service openssh-service-type
                            (openssh-configuration
                             (permit-root-login 'without-password)
                             (authorized-keys
                              (if root-authorizations
                                  `(("root" ,(local-file root-authorizations)))
                                  '())))))
             %base-services))))

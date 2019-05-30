(use-modules (gnu)
             (srfi srfi-60)
             (rnrs io ports))
(use-package-modules certs)
(use-service-modules networking)

(define (cidr->netmask address)
  "Convert a CIDR specification such as 10.0.0.0/24 to 255.255.255.0."
  (let ((mask (string->number (cadr (string-split address #\/)))))
    (inet-ntop AF_INET
               (arithmetic-shift (inet-pton AF_INET "255.255.255.255")
                                 (- 32 mask)))))

(operating-system
  (host-name (getenv "INSTANCE_NAME"))
  ;; Take the hosts time zone, sans trailing newline.
  (timezone (string-drop-right
             (call-with-input-file "/etc/timezone"
               (lambda (port)
                 (get-string-all port)))
             1))
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

  (services (cons (static-networking-service
                   "eth0"
                   (getenv "NIC_0_IP")
                   #:netmask (cidr->netmask (getenv "NIC_0_NETWORK_SUBNET"))
                   #:gateway (getenv "NIC_0_NETWORK_GATEWAY")
                   #:name-servers (list (getenv "NIC_0_NETWORK_GATEWAY")))
                  %base-services)))

(use-modules (gnu)
             (gnu bootloader grub)
             (gnu packages ssh)
             (gnu services base)
             (gnu services ssh)
             (gnu system hurd)
             (ice-9 match))

(define %cache.gexp.no-key
  (plain-file "cache.gexp.no.pub" "
(public-key
 (ecc
  (curve Ed25519)
  (q #07F59B9831390BCC3FB6CA33A4E1AC21197EA3122456751BCF53D62BD80E3366#)))
"))

(define %ssh-authorized-key
  (plain-file "admin.pub"
              "ssh-ed25519 \
AAAAC3NzaC1lZDI1NTE5AAAAIFoN0V4dObmbaLBUvHDs4OKPpSSJBrtOW3aNdoJn2hfD"))

(define %cool-stuff
  '("curl"
    ;; "emacs-minimal"
    "gdb"
    "git-minimal"
    "nss-certs"
    "openssh-sans-x"
    "parted"
    "python"
    "wget"))

(define %hurd-vm-operating-system
  (operating-system
    (inherit %hurd-default-operating-system)
    ;;(kernel-arguments '("console=com0"))
    (host-name "cloudhurd")
    (timezone "Europe/Amsterdam")
    (bootloader (bootloader-configuration
                 (bootloader grub-minimal-bootloader)
                 (targets '("/dev/vda"))
                 (timeout 0)))
    (packages (append (map specification->package %cool-stuff)
                      (operating-system-packages
                       %hurd-default-operating-system)))
    (services
     (append
      (list (service openssh-service-type
                     (openssh-configuration
                      (openssh openssh-sans-x)
                      (permit-root-login #t)
                      (authorized-keys
                       `(("root" ,%ssh-authorized-key)))
                      (allow-empty-passwords? #f)
                      (password-authentication? #t))))
      (modify-services %base-services/hurd
        (static-networking-service-type
         config =>
         (list %loopback-static-networking
               (static-networking
                (requirement '())
                (name-servers '("9.9.9.9" "8.8.8.8"))
                (addresses
                 (list (network-address
                        (device "eth0")
                        (value (string-append
                                (getenv "NIC_0_IP") "/"
                                (match (string-split
                                        (getenv "NIC_0_NETWORK_SUBNET")
                                        #\/)
                                  ((addr mask) mask)))))))
                (routes
                 (list (network-route
                        (destination "default")
                        (gateway (getenv "NIC_0_NETWORK_GATEWAY"))))))))
        (guix-service-type
         config =>
         (guix-configuration
          (inherit config)
          (authorized-keys (cons %cache.gexp.no-key %default-authorized-guix-keys))
          (substitute-urls (cons "https://cache.gexp.no"
                                 %default-substitute-urls)))))))))

%hurd-vm-operating-system

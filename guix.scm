;;; Copyright © 2017, 2019, 2020, 2022 Marius Bakke <marius@gnu.org>
;;;
;;; This program is free software: you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation, either version 3 of the License, or
;;; (at your option) any later version.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

(use-modules (ice-9 rdelim)
             (ice-9 match)
             (ice-9 regex)
             (guix build-system gnu)
             (guix gexp)
             ((guix git-download) #:select (git-predicate))
             ((guix licenses) #:select (gpl3+))
             (guix packages)
             (gnu packages autotools)
             (gnu packages cryptsetup)
             (gnu packages disk)
             (gnu packages linux)
             (gnu packages virtualization)
             (gnu packages web))

(define %source-dir (dirname (current-filename)))

(define version
  (call-with-input-file "configure.ac"
    (lambda (port)
      (let loop ((line (read-line port)))
        (if (or (eof-object? line)
                (string-prefix? "AC_INIT" line))
            (match line
              ((? string?)
               (match:substring
                (string-match "[0-9]+\\.[0-9a-z\\.-]+" line)))
              (_ "???"))
            (loop (read-line port)))))))

(define ganeti-instance-guix
  (package
    (name "ganeti-instance-guix")
    (version version)
    (source (local-file %source-dir
                        #:recursive? #t
                        #:select? (git-predicate %source-dir)))
    (build-system gnu-build-system)
    (native-inputs
     (list autoconf automake
           ;; For tests.
           jq))
    (inputs
     (list cryptsetup
           e2fsprogs
           lvm2
           multipath-tools
           parted
           qemu-minimal                 ;for qemu-img
           util-linux))
    (home-page "https://github.com/mbakke/ganeti-instance-guix")
    (synopsis "Create Guix instances on Ganeti")
    (description
     "@code{instance-guix} is a Ganeti OS definition that creates Guix instances.")
    (license gpl3+)))

ganeti-instance-guix

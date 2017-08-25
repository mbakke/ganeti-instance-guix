;;; Copyright © 2017 Marius Bakke
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

(use-modules (guix build-system gnu)
             (guix gexp)
             (guix git-download)
             (guix licenses)
             (guix packages)
             (gnu packages autotools)
             (gnu packages linux)
             (gnu packages package-management)
             (gnu packages virtualization))

(define %source-dir (dirname (current-filename)))

(define ganeti-instance-guix
  (package
   (name "ganeti-instance-guix")
   (version "git")
   (source (local-file %source-dir
                       #:recursive? #t
                       #:select? (git-predicate %source-dir)))
   (build-system gnu-build-system)
   (arguments
    `(#:phases
      (modify-phases %standard-phases
        (add-after 'unpack 'bootstrap
          (lambda _ (zero? (system* "sh" "bootstrap")))))))
   (native-inputs
    `(("autoconf" ,autoconf)
      ("automake" ,automake)))
   (inputs
    `(("guix" ,guix)
      ("util-linux" ,util-linux)
      ("qemu" ,qemu)))
   (home-page "https://github.com/mbakke/ganeti-instance-guix")
   (synopsis "Create GuixSD instances on Ganeti")
   (description
    "@code{instance-guix} is a Ganeti OS definition that creates GuixSD instances.")
   (license gpl3+)))

ganeti-instance-guix

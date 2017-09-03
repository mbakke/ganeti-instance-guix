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

(use-modules (guix git-download)
             (guix packages)
             (gnu packages package-management))

(define guix-commit
  (getenv "GUIX_COMMIT"))

(define guix-repo-uri
  (or (getenv "GUIX_REPO_URI")
      "https://git.savannah.gnu.org/git/guix.git"))

(define guix-source-checksum
  ;; As returned by `guix hash -rx ...`.
  (getenv "GUIX_SOURCE_CHECKSUM"))

(define fixed-guix
  (package
    (inherit guix)
    (version guix-commit)
    (source (origin
	      (method git-fetch)
	      (uri (git-reference
		    (url guix-repo-uri)
		    (commit version)))
	      (file-name (string-append "guix-checkout-" version))
	      (sha256 (base32 guix-source-checksum))))))
fixed-guix

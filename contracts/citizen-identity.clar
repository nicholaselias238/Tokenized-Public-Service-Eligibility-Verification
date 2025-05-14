;; Citizen Identity Contract
;; Manages resident information and verification status

(define-data-var admin principal tx-sender)

;; Data structure for citizen information
(define-map citizens
  { id: (string-ascii 36) }  ;; Unique identifier for each citizen
  {
    name: (string-ascii 100),
    birth-date: uint,  ;; Unix timestamp
    address: (string-ascii 200),
    verified: bool,
    verification-date: uint  ;; Unix timestamp
  }
)

;; Initialize admin
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (ok (var-set admin new-admin))
  )
)

;; Register a new citizen
(define-public (register-citizen
    (id (string-ascii 36))
    (name (string-ascii 100))
    (birth-date uint)
    (address (string-ascii 200))
  )
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u2))
    (asserts! (is-none (map-get? citizens { id: id })) (err u3))
    (ok (map-set citizens
      { id: id }
      {
        name: name,
        birth-date: birth-date,
        address: address,
        verified: false,
        verification-date: u0
      }
    ))
  )
)

;; Verify a citizen's identity
(define-public (verify-citizen (id (string-ascii 36)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u4))
    (asserts! (is-some (map-get? citizens { id: id })) (err u5))
    (ok (map-set citizens
      { id: id }
      (merge (unwrap-panic (map-get? citizens { id: id }))
        {
          verified: true,
          verification-date: block-height
        }
      )
    ))
  )
)

;; Get citizen information
(define-read-only (get-citizen (id (string-ascii 36)))
  (map-get? citizens { id: id })
)

;; Check if a citizen is verified
(define-read-only (is-citizen-verified (id (string-ascii 36)))
  (default-to false (get verified (map-get? citizens { id: id })))
)

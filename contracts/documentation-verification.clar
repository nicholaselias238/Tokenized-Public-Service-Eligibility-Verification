;; Documentation Verification Contract
;; Validates supporting materials for service eligibility

(define-data-var admin principal tx-sender)

;; Data structure for document submissions
(define-map document-submissions
  {
    citizen-id: (string-ascii 36),
    service-id: (string-ascii 36),
    document-type: (string-ascii 100)
  }
  {
    document-hash: (buff 32),  ;; Hash of the document for verification
    submission-date: uint,     ;; Block height when submitted
    verified: bool,
    verification-date: uint,   ;; Block height when verified
    verifier: principal        ;; Who verified the document
  }
)

;; Initialize admin
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (ok (var-set admin new-admin))
  )
)

;; Submit a document for verification
(define-public (submit-document
    (citizen-id (string-ascii 36))
    (service-id (string-ascii 36))
    (document-type (string-ascii 100))
    (document-hash (buff 32))
  )
  (begin
    ;; Anyone can submit documents, but typically the citizen or an authorized representative
    (ok (map-set document-submissions
      {
        citizen-id: citizen-id,
        service-id: service-id,
        document-type: document-type
      }
      {
        document-hash: document-hash,
        submission-date: block-height,
        verified: false,
        verification-date: u0,
        verifier: tx-sender
      }
    ))
  )
)

;; Verify a submitted document
(define-public (verify-document
    (citizen-id (string-ascii 36))
    (service-id (string-ascii 36))
    (document-type (string-ascii 100))
  )
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u2))
    (asserts! (is-some (map-get? document-submissions
      {
        citizen-id: citizen-id,
        service-id: service-id,
        document-type: document-type
      })) (err u3))
    (ok (map-set document-submissions
      {
        citizen-id: citizen-id,
        service-id: service-id,
        document-type: document-type
      }
      (merge (unwrap-panic (map-get? document-submissions
        {
          citizen-id: citizen-id,
          service-id: service-id,
          document-type: document-type
        }))
        {
          verified: true,
          verification-date: block-height,
          verifier: tx-sender
        }
      )
    ))
  )
)

;; Check if a document is verified
(define-read-only (is-document-verified
    (citizen-id (string-ascii 36))
    (service-id (string-ascii 36))
    (document-type (string-ascii 100))
  )
  (default-to
    false
    (get verified (map-get? document-submissions
      {
        citizen-id: citizen-id,
        service-id: service-id,
        document-type: document-type
      }
    ))
  )
)

;; Get document submission details
(define-read-only (get-document-submission
    (citizen-id (string-ascii 36))
    (service-id (string-ascii 36))
    (document-type (string-ascii 100))
  )
  (map-get? document-submissions
    {
      citizen-id: citizen-id,
      service-id: service-id,
      document-type: document-type
    }
  )
)

;; Provider Verification Contract
;; This contract validates legitimate tourism businesses

(define-data-var admin principal tx-sender)

;; Map to store verified providers
(define-map verified-providers principal
  {
    name: (string-utf8 100),
    description: (string-utf8 500),
    location: (string-utf8 100),
    verified: bool,
    registration-date: uint
  }
)

;; Public function to register a new provider
(define-public (register-provider (name (string-utf8 100)) (description (string-utf8 500)) (location (string-utf8 100)))
  (let ((provider tx-sender))
    (if (is-none (map-get? verified-providers provider))
        (ok (map-set verified-providers provider {
          name: name,
          description: description,
          location: location,
          verified: false,
          registration-date: block-height
        }))
        (err u1) ;; Provider already registered
    )
  )
)

;; Admin function to verify a provider
(define-public (verify-provider (provider principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403)) ;; Only admin can verify
    (match (map-get? verified-providers provider)
      provider-data (ok (map-set verified-providers provider
                          (merge provider-data { verified: true })))
      (err u404) ;; Provider not found
    )
  )
)

;; Read-only function to check if a provider is verified
(define-read-only (is-verified (provider principal))
  (match (map-get? verified-providers provider)
    provider-data (get verified provider-data)
    false
  )
)

;; Read-only function to get provider details
(define-read-only (get-provider-details (provider principal))
  (map-get? verified-providers provider)
)

;; Function to transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (ok (var-set admin new-admin))
  )
)

;; Micro-Lending Protocol for Gig Workers
;; Dynamic interest rates based on work history and performance

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-insufficient-balance (err u102))
(define-constant err-loan-exists (err u103))
(define-constant err-invalid-amount (err u104))
(define-constant err-loan-not-active (err u105))
(define-constant err-already-repaid (err u106))
(define-constant err-invalid-work-score (err u107))
(define-constant err-minimum-work-history (err u108))

;; Data Variables
(define-data-var total-loans-issued uint u0)
(define-data-var total-amount-lent uint u0)
(define-data-var platform-fee-rate uint u250) ;; 2.5% in basis points
(define-data-var max-loan-amount uint u10000000000) ;; 10,000 STX in microSTX
(define-data-var min-work-score uint u60) ;; Minimum work score required

;; Data Maps
(define-map borrowers 
  principal 
  {
    work-score: uint,
    total-gigs: uint,
    successful-gigs: uint,
    total-borrowed: uint,
    total-repaid: uint,
    default-count: uint,
    last-activity: uint,
    reputation-level: (string-ascii 10)
  }
)

(define-map loans
  uint
  {
    borrower: principal,
    amount: uint,
    interest-rate: uint,
    issue-date: uint,
    due-date: uint,
    status: (string-ascii 10),
    repaid-amount: uint,
    collateral-type: (string-ascii 20),
    work-commitment: uint
  }
)

(define-map loan-counter principal uint)
(define-map work-history 
  {borrower: principal, gig-id: uint}
  {
    completion-date: uint,
    rating: uint,
    earnings: uint,
    category: (string-ascii 20)
  }
)

(define-map platform-pool principal uint)

;; Private Functions
(define-private (calculate-interest-rate (borrower principal))
  (let (
    (borrower-data (unwrap! (map-get? borrowers borrower) u1500)) ;; Default 15% if no history
    (work-score (get work-score borrower-data))
    (success-rate (if (> (get total-gigs borrower-data) u0)
                    (/ (* (get successful-gigs borrower-data) u100) (get total-gigs borrower-data))
                    u0))
    (default-rate (if (> (get total-borrowed borrower-data) u0)
                    (/ (* (get default-count borrower-data) u100) (get total-borrowed borrower-data))
                    u0))
  )
  (let (
    (base-rate u800) ;; 8% base rate
    (score-adjustment (if (>= work-score u80) u-200 
                      (if (>= work-score u60) u0 u300)))
    (success-adjustment (if (>= success-rate u90) u-100
                        (if (>= success-rate u70) u0 u200)))
    (default-adjustment (* default-rate u50))
  )
  (+ base-rate score-adjustment success-adjustment default-adjustment)))
)

(define-private (calculate-max-loan-amount (borrower principal))
  (let (
    (borrower-data (unwrap! (map-get? borrowers borrower) u1000000)) ;; Default 10 STX
    (work-score (get work-score borrower-data))
    (avg-earnings (if (> (get total-gigs borrower-data) u0)
                    (/ (get total-repaid borrower-data) (get total-gigs borrower-data))
                    u0))
  )
  (let (
    (base-amount u5000000000) ;; 5,000 STX base
    (score-multiplier (if (>= work-score u90) u3
                      (if (>= work-score u80) u2
                      (if (>= work-score u70) u1 u0))))
    (earnings-factor (min (/ avg-earnings u100000000) u5)) ;; Cap at 5x
  )
  (min (+ base-amount (* score-multiplier earnings-factor u1000000000)) (var-get max-loan-amount))))
)

(define-private (update-reputation (borrower principal))
  (let (
    (borrower-data (unwrap! (map-get? borrowers borrower) false))
    (work-score (get work-score borrower-data))
    (success-rate (if (> (get total-gigs borrower-data) u0)
                    (/ (* (get successful-gigs borrower-data) u100) (get total-gigs borrower-data))
                    u0))
  )
  (let (
    (reputation (if (and (>= work-score u90) (>= success-rate u95)) "platinum"
                (if (and (>= work-score u80) (>= success-rate u85)) "gold"
                (if (and (>= work-score u70) (>= success-rate u75)) "silver"
                (if (and (>= work-score u60) (>= success-rate u65)) "bronze" "basic")))))
  )
  (map-set borrowers borrower (merge borrower-data {reputation-level: reputation}))))
)

;; Public Functions
(define-public (register-borrower (work-score uint) (total-gigs uint) (successful-gigs uint))
  (begin
    (asserts! (>= work-score (var-get min-work-score)) err-invalid-work-score)
    (asserts! (>= total-gigs u5) err-minimum-work-history)
    (asserts! (<= successful-gigs total-gigs) err-invalid-work-score)
    (map-set borrowers tx-sender {
      work-score: work-score,
      total-gigs: total-gigs,
      successful-gigs: successful-gigs,
      total-borrowed: u0,
      total-repaid: u0,
      default-count: u0,
      last-activity: block-height,
      reputation-level: "basic"
    })
    (update-reputation tx-sender)
    (ok true)
  )
)

(define-public (add-work-history (gig-id uint) (completion-date uint) (rating uint) (earnings uint) (category (string-ascii 20)))
  (let (
    (borrower-data (unwrap! (map-get? borrowers tx-sender) err-not-found))
  )
  (begin
    (asserts! (and (>= rating u1) (<= rating u5)) err-invalid-work-score)
    (map-set work-history {borrower: tx-sender, gig-id: gig-id} {
      completion-date: completion-date,
      rating: rating,
      earnings: earnings,
      category: category
    })
    (if (>= rating u4)
      (map-set borrowers tx-sender (merge borrower-data {
        successful-gigs: (+ (get successful-gigs borrower-data) u1),
        total-gigs: (+ (get total-gigs borrower-data) u1),
        last-activity: block-height
      }))
      (map-set borrowers tx-sender (merge borrower-data {
        total-gigs: (+ (get total-gigs borrower-data) u1),
        last-activity: block-height
      }))
    )
    (update-reputation tx-sender)
    (ok true)
  ))
)

(define-public (request-loan (amount uint) (duration-blocks uint) (collateral-type (string-ascii 20)) (work-commitment uint))
  (let (
    (borrower-data (unwrap! (map-get? borrowers tx-sender) err-not-found))
    (loan-id (+ (default-to u0 (map-get? loan-counter tx-sender)) u1))
    (max-amount (calculate-max-loan-amount tx-sender))
    (interest-rate (calculate-interest-rate tx-sender))
    (due-date (+ block-height duration-blocks))
  )
  (begin
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (<= amount max-amount) err-invalid-amount)
    (asserts! (>= (get work-score borrower-data) (var-get min-work-score)) err-invalid-work-score)
    (asserts! (> duration-blocks u0) err-invalid-amount)
    
    (map-set loans loan-id {
      borrower: tx-sender,
      amount: amount,
      interest-rate: interest-rate,
      issue-date: block-height,
      due-date: due-date,
      status: "active",
      repaid-amount: u0,
      collateral-type: collateral-type,
      work-commitment: work-commitment
    })
    
    (map-set loan-counter tx-sender loan-id)
    (var-set total-loans-issued (+ (var-get total-loans-issued) u1))
    (var-set total-amount-lent (+ (var-get total-amount-lent) amount))
    
    (try! (stx-transfer? amount (as-contract tx-sender) tx-sender))
    (ok loan-id)
  ))
)

(define-public (repay-loan (loan-id uint))
  (let (
    (loan-data (unwrap! (map-get? loans loan-id) err-not-found))
    (borrower (get borrower loan-data))
    (amount (get amount loan-data))
    (interest-rate (get interest-rate loan-data))
    (repayment-amount (+ amount (/ (* amount interest-rate) u10000)))
    (platform-fee (/ (* repayment-amount (var-get platform-fee-rate)) u10000))
    (net-repayment (- repayment-amount platform-fee))
  )
  (begin
    (asserts! (is-eq tx-sender borrower) err-owner-only)
    (asserts! (is-eq (get status loan-data) "active") err-loan-not-active)
    
    (try! (stx-transfer? repayment-amount tx-sender (as-contract tx-sender)))
    (try! (stx-transfer? platform-fee (as-contract tx-sender) contract-owner))
    
    (map-set loans loan-id (merge loan-data {
      status: "repaid",
      repaid-amount: repayment-amount
    }))
    
    (let (
      (borrower-data (unwrap! (map-get? borrowers borrower) err-not-found))
    )
    (map-set borrowers borrower (merge borrower-data {
      total-repaid: (+ (get total-repaid borrower-data) repayment-amount),
      last-activity: block-height
    })))
    
    (update-reputation borrower)
    (ok true)
  ))
)

(define-public (default-loan (loan-id uint))
  (let (
    (loan-data (unwrap! (map-get? loans loan-id) err-not-found))
    (borrower (get borrower loan-data))
  )
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (is-eq (get status loan-data) "active") err-loan-not-active)
    (asserts! (>= block-height (get due-date loan-data)) err-loan-not-active)
    
    (map-set loans loan-id (merge loan-data {status: "defaulted"}))
    
    (let (
      (borrower-data (unwrap! (map-get? borrowers borrower) err-not-found))
    )
    (map-set borrowers borrower (merge borrower-data {
      default-count: (+ (get default-count borrower-data) u1),
      work-score: (max (- (get work-score borrower-data) u10) u0)
    })))
    
    (update-reputation borrower)
    (ok true)
  ))
)

(define-public (update-work-score (borrower principal) (new-score uint))
  (let (
    (borrower-data (unwrap! (map-get? borrowers borrower) err-not-found))
  )
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (<= new-score u100) err-invalid-work-score)
    (map-set borrowers borrower (merge borrower-data {work-score: new-score}))
    (update-reputation borrower)
    (ok true)
  ))
)

(define-public (fund-platform (amount uint))
  (let (
    (current-balance (default-to u0 (map-get? platform-pool tx-sender)))
  )
  (begin
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (map-set platform-pool tx-sender (+ current-balance amount))
    (ok true)
  ))
)

;; Read-only functions
(define-read-only (get-borrower-info (borrower principal))
  (map-get? borrowers borrower)
)

(define-read-only (get-loan-info (loan-id uint))
  (map-get? loans loan-id)
)

(define-read-only (get-work-history (borrower principal) (gig-id uint))
  (map-get? work-history {borrower: borrower, gig-id: gig-id})
)

(define-read-only (get-interest-rate (borrower principal))
  (calculate-interest-rate borrower)
)

(define-read-only (get-max-loan-amount (borrower principal))
  (calculate-max-loan-amount borrower)
)

(define-read-only (get-platform-stats)
  {
    total-loans: (var-get total-loans-issued),
    total-amount: (var-get total-amount-lent),
    platform-fee-rate: (var-get platform-fee-rate)
  }
)
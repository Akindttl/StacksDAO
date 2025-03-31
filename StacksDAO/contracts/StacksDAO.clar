;; StacksDAO: Advanced Governance Token Contract
;; Features:
;; - Token minting and burning
;; - Role-based access control
;; - Proposal and voting mechanism
;; - Token transfer with advanced checks

(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-INSUFFICIENT-BALANCE (err u101))
(define-constant ERR-INVALID-PROPOSAL (err u102))
(define-constant ERR-ALREADY-VOTED (err u103))
(define-constant ERR-TRANSFER-LIMIT-EXCEEDED (err u104))
(define-constant ERR-INVALID-TRANSFER-AMOUNT (err u105))

;; Constants for transfer limits
(define-constant DAILY-TRANSFER-LIMIT u10000)
(define-constant BLOCKS-PER-DAY u144)

;; Token parameters
(define-fungible-token governance-token u1000000)

;; User roles
(define-map user-roles 
  { user: principal }
  { is-admin-role: bool, is-minter-role: bool }
)

;; Proposal structure
(define-map proposals
  { id: uint }
  {
    title: (string-utf8 100),
    description: (string-utf8 500),
    proposed-by: principal,
    creation-block: uint,
    votes-for: uint,
    votes-against: uint,
    executed: bool
  }
)

;; Vote tracking
(define-map proposal-votes
  { proposal-id: uint, voter: principal }
  { has-voted: bool, vote-type: bool }
)

;; Transfer limits tracking
(define-map transfer-limits 
  { user: principal }
  { 
    daily-limit: uint, 
    last-transfer-block: uint, 
    total-transferred-today: uint 
  }
)

;; Track last proposal ID
(define-data-var last-proposal-id uint u0)

;; Check if user is an admin
(define-read-only (check-user-is-admin (user principal))
  (default-to false 
    (get is-admin-role (map-get? user-roles { user: user }))))

;; Check if user is a minter
(define-read-only (check-user-is-minter (user principal))
  (default-to false 
    (get is-minter-role (map-get? user-roles { user: user }))))

;; Token management functions
(define-public (mint-tokens (amount uint) (recipient principal))
  (begin
    (try! (validate-admin-access))
    (try! (ft-mint? governance-token amount recipient))
    (ok true)))

(define-public (burn-tokens (amount uint))
  (begin
    (asserts! (>= (ft-get-balance governance-token tx-sender) amount) ERR-INSUFFICIENT-BALANCE)
    (try! (ft-burn? governance-token amount tx-sender))
    (ok true)))

;; Role management
(define-public (set-user-role (user principal) (is-admin bool) (is-minter bool))
  (begin
    (try! (validate-admin-access))
    (map-set user-roles 
      { user: user } 
      { is-admin-role: is-admin, is-minter-role: is-minter })
    (ok true)))

;; Proposal management
(define-public (create-proposal 
  (title (string-utf8 100)) 
  (description (string-utf8 500))
)
  (let 
    (
      (proposal-id (+ (var-get last-proposal-id) u1))
    )
    (begin
      (map-insert proposals 
        { id: proposal-id }
        {
          title: title,
          description: description,
          proposed-by: tx-sender,
          creation-block: block-height,
          votes-for: u0,
          votes-against: u0,
          executed: false
        }
      )
      (var-set last-proposal-id proposal-id)
      (ok proposal-id))))

(define-public (vote-on-proposal (proposal-id uint) (vote bool))
  (let 
    (
      (proposal (unwrap! (map-get? proposals { id: proposal-id }) ERR-INVALID-PROPOSAL))
      (voter-balance (ft-get-balance governance-token tx-sender))
      (existing-vote (map-get? proposal-votes { proposal-id: proposal-id, voter: tx-sender }))
    )
    (begin
      ;; Check voter hasn't already voted
      (asserts! (is-none existing-vote) ERR-ALREADY-VOTED)
      
      ;; Record vote
      (map-set proposal-votes 
        { proposal-id: proposal-id, voter: tx-sender }
        { has-voted: true, vote-type: vote }
      )
      
      ;; Update proposal vote count
      (if vote
        (map-set proposals 
          { id: proposal-id }
          (merge proposal { votes-for: (+ (get votes-for proposal) voter-balance) })
        )
        (map-set proposals 
          { id: proposal-id }
          (merge proposal { votes-against: (+ (get votes-against proposal) voter-balance) })
        )
      )
      
      (ok true))))

;; Utility functions
(define-private (validate-admin-access)
  (if (check-user-is-admin tx-sender)
    (ok true)
    ERR-UNAUTHORIZED))

;; Get the last proposal ID
(define-read-only (get-last-proposal-id)
  (some (var-get last-proposal-id)))

;; Optional: Function to adjust transfer limits for specific users
(define-public (set-user-transfer-limit 
  (user principal) 
  (new-daily-limit uint)
)
  (begin
    ;; Only admins can modify transfer limits
    (try! (validate-admin-access))
    
    ;; Update transfer limits for the user
    (map-set transfer-limits 
      { user: user }
      { 
        daily-limit: new-daily-limit, 
        last-transfer-block: block-height, 
        total-transferred-today: u0 
      }
    )
    
    (ok true)
))

;; Contract initialization
(map-set user-roles 
  { user: CONTRACT-OWNER }
  { is-admin-role: true, is-minter-role: true }
)

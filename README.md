#  Micro-Lending Protocol for Gig Workers

##  Overview

A decentralized micro-lending protocol built on the Stacks blockchain that provides fair, performance-based lending opportunities for gig workers. The protocol features dynamic interest rates calculated based on work history, success rates, and reputation scores.

##  Problem Statement

Traditional lending institutions often fail to serve gig workers due to:
- Irregular income patterns
- Lack of traditional credit history
- High-risk perception of gig work
- Limited access to fair interest rates

##  Solution

Our micro-lending protocol addresses these challenges by:
- **Performance-Based Assessment**: Interest rates based on actual work performance
- **Reputation System**: 5-tier reputation system rewarding consistent performers
- **Dynamic Risk Calculation**: Real-time risk assessment using work history data
- **Decentralized Architecture**: No central authority, reduced overhead costs
- **Transparent Lending**: All terms and calculations visible on-chain

##  Key Features

### 🔄 Dynamic Interest Rates
- **Base Rate**: 8% starting point
- **Work Score Adjustment**: ±2-3% based on performance metrics
- **Success Rate Bonus**: Up to -1% for high-performing workers
- **Default Penalty**: Up to +5% for poor repayment history
- **Final Range**: 8-18% based on individual performance

###  Borrower Management
- **Registration System**: Comprehensive profile creation with work history
- **Work History Tracking**: Detailed gig performance and earnings data
- **Reputation Levels**: Basic → Bronze → Silver → Gold → Platinum
- **Real-time Updates**: Automatic reputation and score adjustments

###  Loan Features
- **Flexible Amounts**: Up to 10,000 STX based on performance
- **Multiple Collateral Types**: Support for various collateral options
- **Work Commitments**: Loans tied to specific work commitments
- **Automated Repayment**: Smart contract-based repayment processing

###  Risk Management
- **Minimum Work Score**: 60+ required for loan eligibility
- **History Requirements**: Minimum 5 completed gigs
- **Default Tracking**: Automatic default handling and reputation impact
- **Collateral Support**: Multiple collateral types for risk mitigation

##  Technical Architecture

### Smart Contract Structure
```
micro-lending-protocol.clar
├── Constants & Error Codes
├── Data Variables (Platform Configuration)
├── Data Maps (Borrowers, Loans, Work History)
├── Private Functions (Interest Calculation, Reputation Management)
├── Public Functions (Core Protocol Logic)
└── Read-only Functions (Data Access)
```

### Core Functions

#### Public Functions
- `register-borrower`: Register new borrowers with work history
- `add-work-history`: Track gig completion and performance
- `request-loan`: Submit loan requests with dynamic terms
- `repay-loan`: Process loan repayments with fee collection
- `default-loan`: Handle loan defaults and reputation updates
- `fund-platform`: Provide liquidity to the lending pool

#### Read-only Functions
- `get-borrower-info`: Retrieve borrower profile data
- `get-loan-info`: Access loan details and status
- `get-interest-rate`: Calculate personalized interest rates
- `get-max-loan-amount`: Determine individual lending limits
- `get-platform-stats`: Platform performance metrics

##  Interest Rate Calculation

```
Final Rate = Base Rate (8%) + Work Score Adjustment + Success Rate Adjustment + Default Penalty

Where:
- Work Score Adjustment: -2% (score ≥80) | 0% (score 60-79) | +3% (score <60)
- Success Rate Adjustment: -1% (≥90%) | 0% (70-89%) | +2% (<70%)
- Default Penalty: +5% per 10% default rate
```

##  Reputation System

| Level | Requirements | Benefits |
|-------|-------------|----------|
| **Platinum** | Work Score ≥90, Success Rate ≥95% | Lowest rates, highest limits |
| **Gold** | Work Score ≥80, Success Rate ≥85% | Reduced rates, increased limits |
| **Silver** | Work Score ≥70, Success Rate ≥75% | Standard rates, good limits |
| **Bronze** | Work Score ≥60, Success Rate ≥65% | Basic rates, moderate limits |
| **Basic** | Below Bronze requirements | Higher rates, lower limits |

##  Development Setup

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) - Stacks smart contract development tool
- [Node.js](https://nodejs.org/) - For running tests
- [Git](https://git-scm.com/) - Version control

### Installation
```bash
# Clone the repository
git clone https://github.com/cheges11/micro-lending-protocol.git
cd micro-lending-protocol

# Install Clarinet (if not already installed)
curl -L https://github.com/hirosystems/clarinet/releases/latest/download/clarinet-linux-x64.tar.gz | tar xz
sudo mv clarinet /usr/local/bin/

# Verify installation
clarinet --version
```

### Running Tests
```bash
# Run all tests
clarinet test

# Check contract syntax
clarinet check

# Deploy to devnet
clarinet deploy --devnet
```

##  Usage Examples

### Register as a Borrower
```clarity
(contract-call? .micro-lending-protocol register-borrower u75 u20 u18)
;; Register with work score 75, 20 total gigs, 18 successful
```

### Add Work History
```clarity
(contract-call? .micro-lending-protocol add-work-history u1 u12345 u5 u1000000 "delivery")
;; Add gig ID 1, completed at block 12345, 5-star rating, 1 STX earnings, delivery category
```

### Request a Loan
```clarity
(contract-call? .micro-lending-protocol request-loan u5000000000 u1440 "none" u3)
;; Request 5,000 STX loan for 1,440 blocks (~10 days), no collateral, 3 work commitments
```

### Repay Loan
```clarity
(contract-call? .micro-lending-protocol repay-loan u1)
;; Repay loan with ID 1
```

##  Security Features

- **Owner-only Functions**: Administrative functions restricted to contract owner
- **Input Validation**: Comprehensive validation on all user inputs
- **Overflow Protection**: Safe arithmetic operations throughout
- **State Management**: Proper loan status tracking and transitions
- **Error Handling**: Detailed error codes for all failure scenarios

##  Platform Economics

### Fee Structure
- **Platform Fee**: 2.5% of repayment amount
- **No Origination Fees**: Borrowers pay only interest + platform fee
- **Transparent Pricing**: All fees calculated and displayed on-chain

### Liquidity Management
- **Platform Funding**: Investors can provide liquidity to the lending pool
- **Automated Distribution**: Smart contract manages loan distribution
- **Risk-based Allocation**: Loans allocated based on risk assessment

##  Roadmap

### Phase 1: Core Protocol (Current)
- ✅ Basic lending functionality
- ✅ Dynamic interest rates
- ✅ Reputation system
- ✅ Work history tracking

### Phase 2: Enhanced Features
- 🔄 Advanced analytics dashboard
- 🔄 Mobile app integration
- 🔄 Multi-token support
- 🔄 Automated work verification

### Phase 3: Ecosystem Integration
- 🔄 Integration with major gig platforms
- 🔄 Insurance products
- 🔄 Savings and investment products
- 🔄 Cross-chain compatibility

##  Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

- **Developer**: cheges11
- **Email**: chegeschima@gmail.com
- **GitHub**: [@cheges11](https://github.com/cheges11)

##  Acknowledgments

- Stacks Foundation for the blockchain infrastructure
- Clarinet team for the development tools
- Gig economy workers who inspire this solution

##  Platform Stats

### Target Metrics
- **Active Borrowers**: 10,000+ gig workers
- **Total Loans Issued**: $1M+ in STX
- **Average Interest Rate**: 12% (performance-based)
- **Repayment Rate**: 95%+ target
- **Platform Utilization**: 80%+ of available liquidity

### Performance Indicators
- **Loan Processing Time**: <10 minutes (blockchain confirmation)
- **Interest Rate Calculation**: Real-time based on latest data
- **Reputation Updates**: Automatic with each transaction
- **Platform Uptime**: 99.9% (blockchain dependent)

---

*Built with  for the gig economy community*
# StacksDAO: Advanced Governance Token Contract

A robust, feature-rich governance token implementation for decentralized autonomous organizations on the Stacks blockchain.

## Overview

StacksDAO is a comprehensive governance token contract built on the Stacks blockchain that enables decentralized community governance with sophisticated token management capabilities. The contract implements a complete solution for DAOs (Decentralized Autonomous Organizations) with role-based access control, proposal creation, voting mechanisms, and configurable transfer limitations.

## Features

### Token Management
- **Fungible Token Implementation**: Built using Stacks' native fungible token standard
- **Minting & Burning**: Controlled token supply management with role-based permissions
- **Secure Transfer System**: Advanced transfer validation with customizable limits

### Governance Framework
- **Proposal System**: Create, track and manage community proposals
- **Voting Mechanism**: Token-weighted voting with vote tracking
- **Execution Tracking**: Monitor proposal execution status

### Security & Access Control
- **Role-Based Permissions**: Granular control with admin and minter roles
- **Transfer Limits**: Configurable daily transfer limits to prevent token dumping
- **Authorization Checks**: Comprehensive validation throughout all operations

## Contract Functions

### Administrative Functions
- `set-user-role`: Assign admin or minter privileges to a user
- `validate-admin-access`: Private function to verify admin privileges
- `check-user-is-admin`: Check if a user has admin role
- `check-user-is-minter`: Check if a user has minter role

### Token Operations
- `mint-tokens`: Create new tokens and assign them to a recipient
- `burn-tokens`: Remove tokens from circulation
- `safe-transfer`: Transfer tokens with additional security checks
- `set-user-transfer-limit`: Adjust the daily transfer limit for a specific user

### Governance Operations
- `create-proposal`: Submit a new governance proposal
- `vote-on-proposal`: Cast votes on existing proposals
- `get-last-proposal-id`: Retrieve the most recent proposal ID

## Error Codes
- `ERR-UNAUTHORIZED (u100)`: User lacks required permissions
- `ERR-INSUFFICIENT-BALANCE (u101)`: Token balance too low for operation
- `ERR-INVALID-PROPOSAL (u102)`: Referenced proposal doesn't exist
- `ERR-ALREADY-VOTED (u103)`: User already voted on the proposal
- `ERR-TRANSFER-LIMIT-EXCEEDED (u104)`: Transfer exceeds configured daily limit
- `ERR-INVALID-TRANSFER-AMOUNT (u105)`: Transfer amount is invalid (zero or too large)

## Technical Implementation

### Data Structures
- `user-roles`: Maps user principals to their assigned roles
- `proposals`: Stores proposal details including votes and execution status
- `proposal-votes`: Tracks which users have voted on which proposals
- `transfer-limits`: Manages daily transfer restrictions per user

### Constants
- `CONTRACT-OWNER`: Initial administrator (set to contract deployer)
- `DAILY-TRANSFER-LIMIT`: Default maximum tokens transferable in 24 hours
- `BLOCKS-PER-DAY`: Block count approximating one day (144 blocks)

## Getting Started

### Prerequisites
- Clarity language knowledge
- Stacks blockchain development environment
- [Clarinet](https://github.com/hirosystems/clarinet) for testing

### Deployment
1. Deploy the contract to a Stacks network using Clarinet or another deployment tool
2. The deploying address becomes the initial admin and minter
3. Set up additional admin and minter roles as needed using `set-user-role`

### Setting Up Your DAO
1. Mint initial tokens to founding members using `mint-tokens`
2. Establish governance parameters and transfer limits
3. Create initial proposals to define governance practices

## Development

### Testing
Test the contract thoroughly with unit tests covering:
- Role assignment and verification
- Token minting and burning
- Proposal creation and voting
- Transfer limits and security checks

### Security Considerations
- Carefully manage admin access to prevent centralization
- Consider implementing time-locks for sensitive operations
- Test extensively for potential vulnerabilities or logic errors

## License

MIT

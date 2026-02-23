## About
FundMe is a minimal crowdfunding smart contract written in Solidity. It allows users to fund the contract with ETH, as long as the sent amount meets a minimum USD threshold. The USD value is calculated using a Chainlink price feed.

The contract:
Uses a Chainlink AggregatorV3Interface price feed

Enforces a minimum contribution (MINIMUM_USD = 5e18)

Tracks funders and their funded amounts

Restricts withdrawals to the contract owner

Uses call for secure ETH transfers

Implements receive() and fallback() to handle direct ETH transfers

It integrates the Chainlink interface:
https://chain.link/

## Getting Started
To use this contract, you need a Solidity development environment such as:
Foundry (recommended)
Hardhat
Remix
This contract expects a valid Chainlink ETH/USD price feed address during deployment.


```

constructor(address priceFeed)

```

## Requirements
Solidity ^0.8.18

Chainlink contracts installed

A deployed ETH/USD price feed address

A PriceConverter library (used for ETH → USD conversion)

Foundry (if using Forge for testing)

## Quick Start
# 1. Install dependencies

If using Foundry:
```
forge install smartcontractkit/chainlink-brownie-contracts
```

Or install Chainlink contracts via npm if using Hardhat:
```
npm install @chainlink/contracts
```

# 2. Deploy the contract

Deploy `FundMe` and pass the price feed address:

`FundMe fundMe = new FundMe(priceFeedAddress);`

# 3. Fund the contract

Call:
`fund()`

Must send at least $5 worth of ETH.

If the ETH value is below the minimum, the transaction reverts.
You can also send ETH directly to the contract — receive() and fallback() will automatically call fund().

# 4. Withdraw funds

Only the owner (the deployer) can call:

`withdraw()`

Resets all funded balances
Clears funders array
Transfers full contract balance using `call`

If a non-owner calls it, the custom error `NotOwner()` is triggered.

## Running the Test
If using Foundry:

# 1. Run all tests:

```
forge test
```

# 2. Run with verbosity:

```
forge test -vvv
```

# 3. Run a specific test:

```
forge test --match-test testFunctionName

```
 
# 4. Check gas usage:

```
forge test --gas-report

```
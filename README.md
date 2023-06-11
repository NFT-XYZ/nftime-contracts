# Contracts

## Local Setup

Consolidate ```.env.local``` fill out ```.env```

## Deployed Contracts (Legacy)

| Contract      | Network | Contract address |
| ------------- | ------- | ---------------- |
| DateTime    | goerli       | 0xaB61CF0300722007Ff10881062374776E13a097c |
| Renderer    | goerli       | 0x1D98b5C92064AD4A6391D2807f7D526b9aFF1b8B |
| SVG    | goerli       | 0x1D98b5C92064AD4A6391D2807f7D526b9aFF1b8B |
| Utils    | goerli       | 0x1D98b5C92064AD4A6391D2807f7D526b9aFF1b8B |
| NFTIME-SVG | goerli      | 0xaB61CF0300722007Ff10881062374776E13a097c |

## Deployed Contracts

| Contract      | Network | Contract address |
| ------------- | ------- | ---------------- |
| NFTIME | goerli      | 0x950ff76f6f7b73f393bdfa39e631e226007740db |

### Deploy contracts

```shell
# To give our shell access to our environment variables
source .env
# To deploy and verify our contract
forge script script/<scriptname>.s.sol:<contractname> --rpc-url goerli || mainnet --broadcast

# concatenate the following if you want to verify the contract
# --verify -vvvvv

```

### Test contracts

Using foundry

```shell
forge test
# for more details, logging with emit, add verbosity 1 up to 5 v's
forge test -vvvv
```

### Local Blockchain with Anvil (Foundry)

Set up a local blockchain like this

```shell
# set up fresh local blockchain
anvil

# if you want to fork an existing blockchain, because you need to interact with existing contracts, e.g on goerli testnet
anvil -f https://eth-goerli.g.alchemy.com/v2/<your_api_keys>
```

### Research
https://www.web3.university/article/flavours-of-on-chain-svg-nfts-on-ethereum

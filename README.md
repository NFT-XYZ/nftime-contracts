# Contracts

## Local Setup

Consolidate `.env.local` fill out `.env`

## Deployed Contracts (V1)

| Contract   | Network | Contract address                           |
| ---------- | ------- | ------------------------------------------ |
| DateTime   | goerli  | 0xaB61CF0300722007Ff10881062374776E13a097c |
| Renderer   | goerli  | 0x1D98b5C92064AD4A6391D2807f7D526b9aFF1b8B |
| SVG        | goerli  | 0x1D98b5C92064AD4A6391D2807f7D526b9aFF1b8B |
| Utils      | goerli  | 0x1D98b5C92064AD4A6391D2807f7D526b9aFF1b8B |
| NFTIME-SVG | goerli  | 0xaB61CF0300722007Ff10881062374776E13a097c |

## Deployed Contracts

| Contract       | Network | Contract address                           |
| -------------- | ------- | ------------------------------------------ |
| NFTIME         | goerli  | 0x4f31199D088e3781bACe408541fdfb7B585Ff83B |
| NFTIMEMetadata | goerli  | 0x8E071387198BD397bB6751bEF81c46F29F16b522 |
| NFTIMEArt      | goerli  | 0xC5DCfc82898A1a95503ce997912fD646cd58d682 |

| Contract       | Network | Contract address                           |
| -------------- | ------- | ------------------------------------------ |
| NFTIME         | mainnet  | 0x19e43efda0c02ea7049a6be91b49ef1ad1bc1a1d |
| NFTIMEMetadata | mainnet  | 0x0fd5c9544ca451c69a4ce300390ebb6ec1882a58 |
| NFTIMEArt      | mainnet  | 0xc96d610af9ac71a018c5be041188003b45e95447 |

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

### Font

#### numbers

// U+0030,U+0031,U+0032,U+0033,U+0034,U+0035,U+0036,U+0037,U+0038,U+0039,

#### chars

U+004D U+004F U+004E U+0054 U+0055 U+0045 U+0057 U+0044 U+0048 U+0046 U+0052 U+0049 U+0053 U+0041 U+004A U+0042 U+0050 U+0059 U+004C U+0047 U+0043 U+0056

U+0030,U+0031,U+0032,U+0033,U+0034,U+0035,U+0036,U+0037,U+0038,U+0039,U+004D,U+004F,U+004E,U+0054,U+0055,U+0045,U+0057,U+0044,U+0048,U+0046,U+0052,U+0049,U+0053,U+0041,U+004A,U+0042,U+0050,U+0059,U+004C,U+0047,U+0043,U+0056

pyftsubset font.ttf --flavor=woff2 --output-file="font.woff2" --unicodes="U+0030,U+0031,U+0032,U+0033,U+0034,U+0035,U+0036,U+0037,U+0038,U+0039,U+004D,U+004F,U+004E,U+0054,U+0055,U+0045,U+0057,U+0044,U+0048,U+0046,U+0052,U+0049,U+0053,U+0041,U+004A,U+0042,U+0050,U+0059,U+004C,U+0047,U+0043,U+0056"

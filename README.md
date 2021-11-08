## Non-fungible Token Standard for the IC

This is an NFT standard implementation for the DFINITY Internet Computer, the interfaces mainly follow the ERC721 standard, and we also added support for transaction history storage and query, make NFTs(including their metadata) traceable and verifiable.

Read the [specification file](./spec.md) for details.

## Development

You need the latest DFINITY Canister SDK to be able to build and deploy a token canister:

```
sh -ci "$(curl -fsSL https://sdk.dfinity.org/install.sh)"
```

Navigate to a the sub directory and start a local development network:

```
cd motoko
dfx start --background
```

Create canister:

```
dfx canister create --all
```

Install code for the NFT canister:

```
dfx build

dfx canister install nft --argument="(\"<NAME>\", \"<SYMBOL>\", \"<DESCRIPTION>\", <YOUR_PRINCIPAL_ID>)"
e.g.:
dfx canister install token --argument="(\"Test NFT\", \"TEST\", \"Test NFT collection\", principal \"4qehi-lqyo6-afz4c-hwqwo-lubfi-4evgk-5vrn5-rldx2-lheha-xs7a4-gae\")"
```

## Contributing

Contributions are welcome, open an issue or make a PR.

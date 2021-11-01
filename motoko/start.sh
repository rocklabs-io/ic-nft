dfx stop
rm -rf .dfx

ALICE_HOME=$(mktemp -d -t alice-temp)

ALICE_PUBLIC_KEY="principal \"$( \
    HOME=$ALICE_HOME dfx identity get-principal
)\""

dfx start --background
dfx canister --no-wallet create token_ERC721
dfx build
dfx canister --no-wallet install token_ERC721 --argument="(\"Test NFT 1\", \"NFT1\",$ALICE_PUBLIC_KEY,\"First NFT on this market\",false,false)" -m=reinstall
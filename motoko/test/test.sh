#!/bin/bash

set -e

# clear
dfx stop
rm -rf .dfx

ALICE_HOME=$(mktemp -d -t alice-temp)
BOB_HOME=$(mktemp -d -t bob-temp)
HOME=$ALICE_HOME

ALICE_PUBLIC_KEY="principal \"$( \
    HOME=$ALICE_HOME dfx identity get-principal
)\""
BOB_PUBLIC_KEY="principal \"$( \
    HOME=$BOB_HOME dfx identity get-principal
)\""

echo Alice id = $ALICE_PUBLIC_KEY
echo Bob id = $BOB_PUBLIC_KEY

dfx start --background
dfx canister --no-wallet create --all
dfx build

HOME=$ALICE_HOME
eval dfx canister --no-wallet install token_ERC721 --argument="'(\"Test logo\", \"Test NFT1\", \"NFT1\", \"This is a NFT demo test!\", principal \"$(dfx identity get-principal)\")'"
eval dfx canister --no-wallet install testflow     --argument="'(principal \"$(dfx canister id token_ERC721)\", $ALICE_PUBLIC_KEY, $BOB_PUBLIC_KEY)'"

TEST_ID=$(dfx canister id testflow)
TEST_ID="principal \"$TEST_ID\""
echo testflow principal: $TEST_ID


echo == Mint 3 NFT to Alice, 3 NFT to Bob, 3 NFT to testflow canister
eval dfx canister --no-wallet call token_ERC721 mint "'($ALICE_PUBLIC_KEY, record { filetype = \"jpg\"; location = variant {IPFS = \"hash0\"}; attributes = vec {record {key = \"url\"; value = \"a.link/0\"}}})'"
eval dfx canister --no-wallet call token_ERC721 mint "'($ALICE_PUBLIC_KEY, record { filetype = \"jpg\"; location = variant {IPFS = \"hash1\"}; attributes = vec {record {key = \"url\"; value = \"a.link/1\"}}})'"
eval dfx canister --no-wallet call token_ERC721 mint "'($ALICE_PUBLIC_KEY, record { filetype = \"jpg\"; location = variant {IPFS = \"hash2\"}; attributes = vec {record {key = \"url\"; value = \"a.link/2\"}}})'"
eval dfx canister --no-wallet call token_ERC721 mint "'($BOB_PUBLIC_KEY, record { filetype = \"jpg\"; location = variant {IPFS = \"hash3\"}; attributes = vec {record {key = \"url\"; value = \"a.link/3\"}}})'"
eval dfx canister --no-wallet call token_ERC721 mint "'($BOB_PUBLIC_KEY, record { filetype = \"jpg\"; location = variant {IPFS = \"has4\"}; attributes = vec {record {key = \"url\"; value = \"a.link/4\"}}})'"
eval dfx canister --no-wallet call token_ERC721 mint "'($BOB_PUBLIC_KEY, record { filetype = \"jpg\"; location = variant {IPFS = \"has5\"}; attributes = vec {record {key = \"url\"; value = \"a.link/5\"}}})'"
eval dfx canister --no-wallet call token_ERC721 mint "'($TEST_ID, record { filetype = \"jpg\"; location = variant {IPFS = \"hash6\"}; attributes = vec {record {key = \"url\"; value = \"a.link/6\"}}})'"
eval dfx canister --no-wallet call token_ERC721 mint "'($TEST_ID, record { filetype = \"jpg\"; location = variant {IPFS = \"has7\"}; attributes = vec {record {key = \"url\"; value = \"a.link/7\"}}})'"
eval dfx canister --no-wallet call token_ERC721 mint "'($TEST_ID, record { filetype = \"jpg\"; location = variant {IPFS = \"has8\"}; attributes = vec {record {key = \"url\"; value = \"a.link/8\"}}})'"

echo == Alice approve testflow token 0
eval HOME=$ALICE_HOME dfx canister --no-wallet call token_ERC721 approve "'(0, $TEST_ID)'"

echo == Bob approve testflow all token
eval HOME=$BOB_HOME dfx canister --no-wallet call token_ERC721 setApprovalForAll  "'($TEST_ID, true)'"

echo Testing begin !!!
dfx canister call testflow testflow

dfx stop
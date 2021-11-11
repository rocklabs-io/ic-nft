#!/bin/bash

set -e

# clear
dfx stop
rm -rf .dfx

dfx start --background
dfx canister create --all
dfx build

dfx canister install token_ERC721    --argument="(\"test_logo\", \"test_name\", \"test_symbol\", \"test_desc\", principal \"$(dfx identity get-principal)\")"
dfx canister install testflow        --argument="(principal \"$(dfx canister id token_ERC721)\")"

TEST_ID=$(dfx canister id testflow)
TEST_ID="principal \"$TEST_ID\""
echo testflow principal: $TEST_ID

echo authorize testflow canister as the owner
dfx canister --no-wallet call token_ERC721 setOwner "($TEST_ID)"

echo Testing begin!
dfx canister call testflow testflow

dfx stop

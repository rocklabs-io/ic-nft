#!/bin/bash

# set -e

# clear
dfx stop
rm -rf .dfx

ALICE_HOME=$(mktemp -d -t alice-temp)
BOB_HOME=$(mktemp -d -t bob-temp)
DAN_HOME=$(mktemp -d -t dan-temp)
FEE_HOME=$(mktemp -d -t fee-temp)
HOME=$ALICE_HOME

ALICE_PUBLIC_KEY="principal \"$( \
    HOME=$ALICE_HOME dfx identity get-principal
)\""
BOB_PUBLIC_KEY="principal \"$( \
    HOME=$BOB_HOME dfx identity get-principal
)\""
DAN_PUBLIC_KEY="principal \"$( \
    HOME=$DAN_HOME dfx identity get-principal
)\""
FEE_PUBLIC_KEY="principal \"$( \
    HOME=$FEE_HOME dfx identity get-principal
)\""

echo Alice id = $ALICE_PUBLIC_KEY
echo Bob id = $BOB_PUBLIC_KEY
echo Dan id = $DAN_PUBLIC_KEY
echo Fee id = $FEE_PUBLIC_KEY

dfx start --background
dfx canister --no-wallet create --all
dfx build

TOKENID=$(dfx canister --no-wallet id nft)
TOKENID="principal \"$TOKENID\""

echo NFT id : $TOKENID

echo
echo == Install NFT canisters
echo

HOME=$ALICE_HOME
eval dfx canister --no-wallet install nft --argument="'(\"Test logo\", \"Test NFT1\", \"NFT1\", \"This is a NFT demo test!\", principal \"$(dfx identity get-principal)\")'"

echo == Get NFT metadata: name, desciption, total supply, owner
dfx canister --no-wallet call nft getMetadata

echo == Mint 3 NFT to Alice, 3 NFT to Bob 
eval dfx canister --no-wallet call nft mint "'($ALICE_PUBLIC_KEY, opt record { filetype = \"jpg\"; location = variant {IPFS = \"hash0\"}; attributes = vec {record {key = \"url\"; value = \"a.link/0\"}}})'"
eval dfx canister --no-wallet call nft mint "'($ALICE_PUBLIC_KEY, opt record { filetype = \"jpg\"; location = variant {IPFS = \"hash1\"}; attributes = vec {record {key = \"url\"; value = \"a.link/1\"}}})'"
eval dfx canister --no-wallet call nft mint "'($ALICE_PUBLIC_KEY, opt record { filetype = \"jpg\"; location = variant {IPFS = \"hash2\"}; attributes = vec {record {key = \"url\"; value = \"a.link/2\"}}})'"
eval dfx canister --no-wallet call nft mint "'($BOB_PUBLIC_KEY, opt record { filetype = \"jpg\"; location = variant {IPFS = \"hash3\"}; attributes = vec {record {key = \"url\"; value = \"a.link/3\"}}})'"
eval dfx canister --no-wallet call nft mint "'($BOB_PUBLIC_KEY, opt record { filetype = \"jpg\"; location = variant {IPFS = \"has4\"}; attributes = vec {record {key = \"url\"; value = \"a.link/4\"}}})'"
eval dfx canister --no-wallet call nft mint "'($BOB_PUBLIC_KEY, opt record { filetype = \"jpg\"; location = variant {IPFS = \"has5\"}; attributes = vec {record {key = \"url\"; value = \"a.link/5\"}}})'"
echo

echo == Get all tokens info
dfx canister --no-wallet call nft getAllTokens

echo == Get 0~5 transactions
dfx canister --no-wallet call nft getTransactions "(0,6)"

echo == Get totalSupply 6
dfx canister --no-wallet call nft totalSupply

echo == Get balance 3, 3, 0
eval dfx canister --no-wallet call nft balanceOf "'($ALICE_PUBLIC_KEY)'"
eval dfx canister --no-wallet call nft balanceOf "'($BOB_PUBLIC_KEY)'"
eval dfx canister --no-wallet call nft balanceOf "'($DAN_PUBLIC_KEY)'"

echo == setTokenMetadata: Bob change the Token 3 filetype to png
eval HOME=$BOB_HOME dfx canister --no-wallet call nft setTokenMetadata "'(3, record { filetype = \"png\"; location = variant {IPFS = \"hash0\"}; attributes = vec {record {key = \"url\"; value = \"a.link/0\"}}})'"

echo Get Token 3 info to check the filetype
dfx canister --no-wallet call nft getTokenInfo 3

echo == Get Alice Bob Dan UserInfo
eval dfx canister --no-wallet call nft getUserInfo "'($ALICE_PUBLIC_KEY)'"
eval dfx canister --no-wallet call nft getUserInfo "'($BOB_PUBLIC_KEY)'"
eval dfx canister --no-wallet call nft getUserInfo "'($DAN_PUBLIC_KEY)'"

echo == Alice transfer token 0 to Dan
eval HOME=$ALICE_HOME dfx canister --no-wallet call nft transferFrom "'($ALICE_PUBLIC_KEY, $DAN_PUBLIC_KEY, 0)'"
echo == Get Alice user info and Dan user info
eval dfx canister --no-wallet call nft getUserInfo "'($ALICE_PUBLIC_KEY)'"
eval dfx canister --no-wallet call nft getUserInfo "'($DAN_PUBLIC_KEY)'"

echo == Bob approve Alice token 3
eval HOME=$BOB_HOME dfx canister --no-wallet call nft approve "'(3, $ALICE_PUBLIC_KEY)'"
echo == get token 3 info
dfx canister --no-wallet call nft getTokenInfo 3
echo == Alice transfer Bob token 3 to Alice
eval HOME=$BOB_HOME dfx canister --no-wallet call nft transferFrom "'($BOB_PUBLIC_KEY, $ALICE_PUBLIC_KEY, 3)'"

echo == Get Alice and Bob UserInfo: Alice has 1,2,3 token , Bob has 4,5 token ,  Dan has 0 token
eval dfx canister --no-wallet call nft getUserInfo "'($ALICE_PUBLIC_KEY)'"
eval dfx canister --no-wallet call nft getUserInfo "'($BOB_PUBLIC_KEY)'"
eval dfx canister --no-wallet call nft getUserInfo "'($DAN_PUBLIC_KEY)'"


echo == Bob set Fee approval For All
eval HOME=$BOB_HOME dfx canister --no-wallet call nft setApprovalForAll "'($FEE_PUBLIC_KEY, true)'"
echo == Fee transfer token 4 from Bob
eval HOME=$FEE_HOME dfx canister --no-wallet call nft transferFrom "'($BOB_PUBLIC_KEY, $FEE_PUBLIC_KEY, 4)'"

echo == get isApprovedForAll true false false
eval dfx canister --no-wallet call nft isApprovedForAll "'($BOB_PUBLIC_KEY, $FEE_PUBLIC_KEY)'"
eval dfx canister --no-wallet call nft isApprovedForAll "'($BOB_PUBLIC_KEY, $ALICE_PUBLIC_KEY)'"
eval dfx canister --no-wallet call nft isApprovedForAll "'($ALICE_PUBLIC_KEY, $DAN_PUBLIC_KEY)'"

echo == Bob set self approved For All, False
eval HOME=$BOB_HOME dfx canister --no-wallet call nft setApprovalForAll "'($BOB_PUBLIC_KEY, true)'"
echo == get bob approved bob false
eval dfx canister --no-wallet call nft isApprovedForAll "'($BOB_PUBLIC_KEY, $BOB_PUBLIC_KEY)'"

echo == Get Alice Bob Dan Fee UserInfo: Alice has token 1,2,3,  Bob has token 5, Dan has token 0,  Fee has token 4
eval dfx canister --no-wallet call nft getUserInfo "'($ALICE_PUBLIC_KEY)'"
eval dfx canister --no-wallet call nft getUserInfo "'($BOB_PUBLIC_KEY)'"
eval dfx canister --no-wallet call nft getUserInfo "'($DAN_PUBLIC_KEY)'"
eval dfx canister --no-wallet call nft getUserInfo "'($FEE_PUBLIC_KEY)'"

echo == get balance 3,1,1,1
eval dfx canister --no-wallet call nft balanceOf "'($ALICE_PUBLIC_KEY)'"
eval dfx canister --no-wallet call nft balanceOf "'($BOB_PUBLIC_KEY)'"
eval dfx canister --no-wallet call nft balanceOf "'($DAN_PUBLIC_KEY)'"
eval dfx canister --no-wallet call nft balanceOf "'($FEE_PUBLIC_KEY)'"


echo == Alice transfer nft 3 to canister 
eval HOME=$ALICE_HOME dfx canister --no-wallet call nft transferFrom "'($ALICE_PUBLIC_KEY, $TOKENID, 3)'"
echo == owner of token3
dfx canister --no-wallet call nft ownerOf 3

echo == Alice burn token 2
eval HOME=$ALICE_HOME dfx canister --no-wallet call nft burn 2

echo == Get allTokens
dfx canister --no-wallet call nft getAllTokens

echo == Get Alice Bob Dan Fee UserInfo : Alice has token 1, Bob has token 5,  Dan has token 0,  Fee has token 4
eval dfx canister --no-wallet call nft getUserInfo "'($ALICE_PUBLIC_KEY)'"
eval dfx canister --no-wallet call nft getUserInfo "'($BOB_PUBLIC_KEY)'"
eval dfx canister --no-wallet call nft getUserInfo "'($DAN_PUBLIC_KEY)'"
eval dfx canister --no-wallet call nft getUserInfo "'($FEE_PUBLIC_KEY)'"

echo == get token owner
dfx canister --no-wallet call nft ownerOf 0
dfx canister --no-wallet call nft ownerOf 1
dfx canister --no-wallet call nft ownerOf 2
dfx canister --no-wallet call nft ownerOf 3
dfx canister --no-wallet call nft ownerOf 4
dfx canister --no-wallet call nft ownerOf 5

echo == get balance 1,1,1,1
eval dfx canister --no-wallet call nft balanceOf "'($ALICE_PUBLIC_KEY)'"
eval dfx canister --no-wallet call nft balanceOf "'($BOB_PUBLIC_KEY)'"
eval dfx canister --no-wallet call nft balanceOf "'($DAN_PUBLIC_KEY)'"
eval dfx canister --no-wallet call nft balanceOf "'($FEE_PUBLIC_KEY)'"

echo == get tx size
dfx canister --no-wallet call nft historySize

echo == get some transactions
dfx canister --no-wallet call nft getTransactions "(2,7)"

echo == get operation
dfx canister --no-wallet call nft getTransaction 3

echo == get transactions amount of a user
eval dfx canister --no-wallet call nft getUserTransactionAmount "'($ALICE_PUBLIC_KEY)'"

echo == get some operations of a user
eval dfx canister --no-wallet call nft getUserTransactions "'($ALICE_PUBLIC_KEY, 2, 6)'"

echo == demo finished!!!
dfx stop

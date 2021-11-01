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

TOKENID=$(dfx canister --no-wallet id token_ERC721)
TOKENID="principal \"$TOKENID\""

echo NFT id : $TOKENID

echo
echo == Install NFT canisters
echo

HOME=$ALICE_HOME
eval dfx canister --no-wallet install token_ERC721 --argument="'(\"Test NFT 1\", \"NFT1\",$ALICE_PUBLIC_KEY,\"First NFT on this market\",false,false)'"

echo == Get NFT metadata: name, desciption, total supply, owner
eval dfx canister --no-wallet call token_ERC721 getMetadata

echo == set mintable to be true
eval dfx canister --no-wallet call token_ERC721 setMintable true
echo

echo == Alice Mint 3 NFT to self, 3 NFT to Bob
eval dfx canister --no-wallet call token_ERC721 mint "'($ALICE_PUBLIC_KEY, vec { record { key = \"url\"; value = \"a.link/1\"}; }, \"token 1\", \"the 1 nft in here\")'"
eval dfx canister --no-wallet call token_ERC721 mint "'($BOB_PUBLIC_KEY, vec { record { key = \"url\"; value = \"a.link/2\"}; }, \"token 2\", \"the 2 nft in here\")'"
eval dfx canister --no-wallet call token_ERC721 mint "'($ALICE_PUBLIC_KEY, vec { record { key = \"url\"; value = \"a.link/3\"}; }, \"token 3\", \"the 3 nft in here\")'"
eval dfx canister --no-wallet call token_ERC721 mint "'($BOB_PUBLIC_KEY, vec { record { key = \"url\"; value = \"a.link/4\"}; }, \"token 4\", \"the 4 nft in here\")'"
eval dfx canister --no-wallet call token_ERC721 mint "'($ALICE_PUBLIC_KEY, vec { record { key = \"url\"; value = \"a.link/5\"}; }, \"token 5\", \"the 5 nft in here\")'"
eval dfx canister --no-wallet call token_ERC721 mint "'($BOB_PUBLIC_KEY, vec { record { key = \"url\"; value = \"a.link/6\"}; }, \"token 6\", \"the 6 nft in here\")'"
echo

echo == Get tokens info
eval dfx canister --no-wallet call token_ERC721 getTokenInfo 0
eval dfx canister --no-wallet call token_ERC721 getTokenInfo 1
eval dfx canister --no-wallet call token_ERC721 getTokenInfo 2
eval dfx canister --no-wallet call token_ERC721 getTokenInfo 3
eval dfx canister --no-wallet call token_ERC721 getTokenInfo 4
eval dfx canister --no-wallet call token_ERC721 getTokenInfo 5

echo == get token owner
eval dfx canister --no-wallet call token_ERC721 ownerOf 0
eval dfx canister --no-wallet call token_ERC721 ownerOf 1
eval dfx canister --no-wallet call token_ERC721 ownerOf 2
eval dfx canister --no-wallet call token_ERC721 ownerOf 3
eval dfx canister --no-wallet call token_ERC721 ownerOf 4
eval dfx canister --no-wallet call token_ERC721 ownerOf 5

echo == get balance 3, 3, 0
eval dfx canister --no-wallet call token_ERC721 balanceOf "'($ALICE_PUBLIC_KEY)'"
eval dfx canister --no-wallet call token_ERC721 balanceOf "'($BOB_PUBLIC_KEY)'"
eval dfx canister --no-wallet call token_ERC721 balanceOf "'($DAN_PUBLIC_KEY)'"

echo == Get all tokens, Success
eval dfx canister --no-wallet call token_ERC721 getAllTokens
echo == Get Alice Bob Dan tokensList, Alice, Bob Success, Dan False.
eval dfx canister --no-wallet call token_ERC721 getTokenList "'($ALICE_PUBLIC_KEY)'"
eval dfx canister --no-wallet call token_ERC721 getTokenList "'($BOB_PUBLIC_KEY)'"
eval dfx canister --no-wallet call token_ERC721 getTokenList "'($DAN_PUBLIC_KEY)'"
echo == Get total supply: 6
eval dfx canister --no-wallet call token_ERC721 totalSupply

echo == set token info: true, error
eval HOME=$ALICE_HOME dfx canister --no-wallet call token_ERC721 setTokenInfo "'(record {
    owner = principal \"yi5kz-xnqwo-7hw4c-ez34w-qw6ju-slrmj-33djx-7xm7r-q2piu-nkobp-tqe\";
    tokenMetadata = vec { record { key = \"url\"; value = \"google.com\" } };
    desc = \"the 1 nft in here\";
    name = \"token 1\";
    approval = null;
    timestamp = 1_635_736_419_981_637_001 : int;
    index = 0 : nat;
  })'"
eval HOME=$ALICE_HOME dfx canister --no-wallet call token_ERC721 setTokenInfo "'(record {
    owner = principal \"yi5kz-xnqwo-7hw4c-ez34w-qw6ju-slrmj-33djx-7xm7r-q2piu-nkobp-tqe\";
    tokenMetadata = vec { record { key = \"url\"; value = \"google.com\" } };
    desc = \"the 1 nft in here\";
    name = \"token 1\";
    approval = null;
    timestamp = 1_635_736_419_981_637_001 : int;
    index = 1 : nat;
  })'"

echo == get token info of token 1
eval dfx canister --no-wallet call token_ERC721 getTokenInfo 0

echo == Alice transfer self NFT to Bob, Dan, 0,2,True, and 1,4,5 False
eval dfx canister --no-wallet call token_ERC721 transferFrom "'($ALICE_PUBLIC_KEY, $BOB_PUBLIC_KEY, 0)'"
eval dfx canister --no-wallet call token_ERC721 transferFrom "'($ALICE_PUBLIC_KEY, $DAN_PUBLIC_KEY, 2)'"
eval dfx canister --no-wallet call token_ERC721 transferFrom "'($BOB_PUBLIC_KEY, $DAN_PUBLIC_KEY, 1)'"
eval dfx canister --no-wallet call token_ERC721 transferFrom "'($BOB_PUBLIC_KEY, $DAN_PUBLIC_KEY, 4)'"
eval dfx canister --no-wallet call token_ERC721 transferFrom "'($ALICE_PUBLIC_KEY, $DAN_PUBLIC_KEY, 5)'"

echo == Bob approve Alice token 1
eval HOME=$BOB_HOME dfx canister --no-wallet call token_ERC721 approve "'($ALICE_PUBLIC_KEY, 1)'"
echo == get approved true, error
eval dfx canister --no-wallet call token_ERC721 getApproved 1
eval dfx canister --no-wallet call token_ERC721 getApproved 2
echo == Alice transfer Bob token 1 to Alice
eval dfx canister --no-wallet call token_ERC721 transferFrom "'($BOB_PUBLIC_KEY, $ALICE_PUBLIC_KEY, 1)'"
echo == get approved of token 2
eval dfx canister --no-wallet call token_ERC721 getApproved 1
echo == get token owner
eval dfx canister --no-wallet call token_ERC721 ownerOf 1

echo == Bob set Dan approval For All
eval HOME=$BOB_HOME dfx canister --no-wallet call token_ERC721 setApprovalForAll "'($DAN_PUBLIC_KEY, true)'"
echo == get isApprovedForAll
eval dfx canister --no-wallet call token_ERC721 isApprovedForAll "'($BOB_PUBLIC_KEY, $DAN_PUBLIC_KEY)'"
eval dfx canister --no-wallet call token_ERC721 isApprovedForAll "'($BOB_PUBLIC_KEY, $ALICE_PUBLIC_KEY)'"
eval dfx canister --no-wallet call token_ERC721 isApprovedForAll "'($ALICE_PUBLIC_KEY, $DAN_PUBLIC_KEY)'"
echo == Bob set self approved For All, False
eval HOME=$BOB_HOME dfx canister --no-wallet call token_ERC721 setApprovalForAll "'($BOB_PUBLIC_KEY, true)'"
echo == get bob approved bob
eval dfx canister --no-wallet call token_ERC721 isApprovedForAll "'($BOB_PUBLIC_KEY, $BOB_PUBLIC_KEY)'"

echo == Get Alice Bob Dan tokensList, Success
eval dfx canister --no-wallet call token_ERC721 getTokenList "'($ALICE_PUBLIC_KEY)'"
eval dfx canister --no-wallet call token_ERC721 getTokenList "'($BOB_PUBLIC_KEY)'"
eval dfx canister --no-wallet call token_ERC721 getTokenList "'($DAN_PUBLIC_KEY)'"

echo == get token by owner by index
eval dfx canister --no-wallet call token_ERC721 tokenOfOwnerByIndex "'($ALICE_PUBLIC_KEY, 0)'"
eval dfx canister --no-wallet call token_ERC721 tokenOfOwnerByIndex "'($ALICE_PUBLIC_KEY, 1)'"
eval dfx canister --no-wallet call token_ERC721 tokenOfOwnerByIndex "'($ALICE_PUBLIC_KEY, 2)'"
eval dfx canister --no-wallet call token_ERC721 tokenOfOwnerByIndex "'($ALICE_PUBLIC_KEY, 3)'"
eval dfx canister --no-wallet call token_ERC721 tokenOfOwnerByIndex "'($BOB_PUBLIC_KEY, 0)'"
eval dfx canister --no-wallet call token_ERC721 tokenOfOwnerByIndex "'($BOB_PUBLIC_KEY, 1)'"
eval dfx canister --no-wallet call token_ERC721 tokenOfOwnerByIndex "'($BOB_PUBLIC_KEY, 2)'"
eval dfx canister --no-wallet call token_ERC721 tokenOfOwnerByIndex "'($BOB_PUBLIC_KEY, 3)'"

echo == get token by index 
eval dfx canister --no-wallet call token_ERC721 tokenByIndex "'(0)'"
eval dfx canister --no-wallet call token_ERC721 tokenByIndex "'(1)'"
eval dfx canister --no-wallet call token_ERC721 tokenByIndex "'(2)'"
eval dfx canister --no-wallet call token_ERC721 tokenByIndex "'(3)'"
eval dfx canister --no-wallet call token_ERC721 tokenByIndex "'(4)'"
eval dfx canister --no-wallet call token_ERC721 tokenByIndex "'(5)'"

echo == get balance 
eval dfx canister --no-wallet call token_ERC721 balanceOf "'($ALICE_PUBLIC_KEY)'"
eval dfx canister --no-wallet call token_ERC721 balanceOf "'($BOB_PUBLIC_KEY)'"
eval dfx canister --no-wallet call token_ERC721 balanceOf "'($DAN_PUBLIC_KEY)'"

echo == get balance 3,3, 0
eval dfx canister --no-wallet call token_ERC721 balanceOf "'($ALICE_PUBLIC_KEY)'"
eval dfx canister --no-wallet call token_ERC721 balanceOf "'($BOB_PUBLIC_KEY)'"
eval dfx canister --no-wallet call token_ERC721 balanceOf "'($DAN_PUBLIC_KEY)'"

echo == owner of token 3
eval dfx canister --no-wallet call token_ERC721 ownerOf 3

echo == Dan transfer nft 3 to canister 
eval HOME=$DAN_HOME dfx canister --no-wallet call token_ERC721 transferFrom "'($DAN_PUBLIC_KEY, $TOKENID, 3)'"
echo == owner of token3
eval dfx canister --no-wallet call token_ERC721 ownerOf 3

echo == set _burnable to true
eval dfx canister --no-wallet call token_ERC721 setMintable true

echo == admin bob burn token 2
eval HOME=$BOB_HOME dfx canister --no-wallet call token_ERC721 burn 2
eval HOME=$BOB_HOME dfx canister --no-wallet call token_ERC721 burn 7

echo == Get allTokens
eval dfx canister --no-wallet call token_ERC721 getAllTokens

echo == Get Alice Bob Dan tokensList, Success
eval dfx canister --no-wallet call token_ERC721 getTokenList "'($ALICE_PUBLIC_KEY)'"
eval dfx canister --no-wallet call token_ERC721 getTokenList "'($BOB_PUBLIC_KEY)'"
eval dfx canister --no-wallet call token_ERC721 getTokenList "'($DAN_PUBLIC_KEY)'"

echo == get token owner
eval dfx canister --no-wallet call token_ERC721 ownerOf "'(0)'"
eval dfx canister --no-wallet call token_ERC721 ownerOf "'(1)'"
eval dfx canister --no-wallet call token_ERC721 ownerOf "'(2)'"
eval dfx canister --no-wallet call token_ERC721 ownerOf "'(3)'"
eval dfx canister --no-wallet call token_ERC721 ownerOf "'(4)'"
eval dfx canister --no-wallet call token_ERC721 ownerOf "'(5)'"

echo == get token by owner by index
eval dfx canister --no-wallet call token_ERC721 tokenOfOwnerByIndex "'($ALICE_PUBLIC_KEY, 0)'"
eval dfx canister --no-wallet call token_ERC721 tokenOfOwnerByIndex "'($ALICE_PUBLIC_KEY, 1)'"
eval dfx canister --no-wallet call token_ERC721 tokenOfOwnerByIndex "'($ALICE_PUBLIC_KEY, 2)'"
eval dfx canister --no-wallet call token_ERC721 tokenOfOwnerByIndex "'($ALICE_PUBLIC_KEY, 3)'"
eval dfx canister --no-wallet call token_ERC721 tokenOfOwnerByIndex "'($BOB_PUBLIC_KEY, 0)'"
eval dfx canister --no-wallet call token_ERC721 tokenOfOwnerByIndex "'($BOB_PUBLIC_KEY, 1)'"
eval dfx canister --no-wallet call token_ERC721 tokenOfOwnerByIndex "'($BOB_PUBLIC_KEY, 2)'"
eval dfx canister --no-wallet call token_ERC721 tokenOfOwnerByIndex "'($BOB_PUBLIC_KEY, 3)'"

echo == get token by index 
eval dfx canister --no-wallet call token_ERC721 tokenByIndex "'(0)'"
eval dfx canister --no-wallet call token_ERC721 tokenByIndex "'(1)'"
eval dfx canister --no-wallet call token_ERC721 tokenByIndex "'(2)'"
eval dfx canister --no-wallet call token_ERC721 tokenByIndex "'(3)'"
eval dfx canister --no-wallet call token_ERC721 tokenByIndex "'(4)'"
eval dfx canister --no-wallet call token_ERC721 tokenByIndex "'(5)'"

echo == get balance 
eval dfx canister --no-wallet call token_ERC721 balanceOf "'($ALICE_PUBLIC_KEY)'"
eval dfx canister --no-wallet call token_ERC721 balanceOf "'($BOB_PUBLIC_KEY)'"
eval dfx canister --no-wallet call token_ERC721 balanceOf "'($DAN_PUBLIC_KEY)'"

echo == get user
eval dfx canister --no-wallet call token_ERC721 getUser "'($ALICE_PUBLIC_KEY)'"
eval dfx canister --no-wallet call token_ERC721 getUser "'($BOB_PUBLIC_KEY)'"
eval dfx canister --no-wallet call token_ERC721 getUser "'($DAN_PUBLIC_KEY)'"

echo == get all operations
eval dfx canister --no-wallet call token_ERC721 getAllTxs

echo == get the number of operations
eval dfx canister --no-wallet call token_ERC721 historySize

echo == get some operations
eval dfx canister --no-wallet call token_ERC721 getTransactions "'(2, 4)'"

echo == get operation
eval dfx canister --no-wallet call token_ERC721 getTransaction 3

echo == get operation amount of a user
eval dfx canister --no-wallet call token_ERC721 getUserTransactionAmount "'($ALICE_PUBLIC_KEY)'"

echo == get operations of a user
eval dfx canister --no-wallet call token_ERC721 getUserTransactions "'($ALICE_PUBLIC_KEY)'"

dfx stop
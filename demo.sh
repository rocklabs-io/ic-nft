#!/bin/bash

# set -e

# clear
dfx stop
rm -rf .dfx

ALICE_HOME=$(mktemp -d -t alice-temp)
BOB_HOME=$(mktemp -d -t bob-temp)
DAN_HOME=$(mktemp -d -t dan-temp)
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

dfx start --background
dfx canister create token_ERC721
dfx build

eval dfx canister install token_ERC721 --argument="'(\"Test NFT 1\", \"NFT1\",$ALICE_PUBLIC_KEY)'" -m=reinstall

echo Alice id = $ALICE_PUBLIC_KEY
echo Bob id = $BOB_PUBLIC_KEY
echo Dan id = $DAN_PUBLIC_KEY

NFT_ID=$(dfx canister id token_ERC721)
NFT_ID="principal \"$NFT_ID\""
echo token_erc721 principal: $NFT_ID

echo == Alice is admins, True
eval dfx canister call token_ERC721 isAdmin "'($ALICE_PUBLIC_KEY)'"
echo == Bob isnot admins, False
eval dfx canister call token_ERC721 isAdmin "'($BOB_PUBLIC_KEY)'"
echo == Set bob admin
eval dfx canister call token_ERC721 setAdmin "'($BOB_PUBLIC_KEY, true)'"
echo == Bob is admins, true
eval dfx canister call token_ERC721 isAdmin "'($BOB_PUBLIC_KEY)'"

echo == Get name, symbol
eval dfx canister call token_ERC721 name
eval dfx canister call token_ERC721 symbol


echo == Alice Mint 3 NFT to self, 3 NFT to Bob, all True
eval dfx canister call token_ERC721 mint "'($ALICE_PUBLIC_KEY, 0)'"
eval dfx canister call token_ERC721 mint "'($BOB_PUBLIC_KEY, 1)'"
eval dfx canister call token_ERC721 mint "'($ALICE_PUBLIC_KEY, 2)'"
eval dfx canister call token_ERC721 mint "'($BOB_PUBLIC_KEY, 3)'"
eval dfx canister call token_ERC721 mint "'($ALICE_PUBLIC_KEY, 4)'"
eval dfx canister call token_ERC721 mint "'($BOB_PUBLIC_KEY, 5)'"

echo == Alice Mint exists token, False 
eval dfx canister call token_ERC721 mint "'($ALICE_PUBLIC_KEY, 0)'"

echo == Bob Mint new NFT, True
eval HOME=$BOB_HOME dfx canister call token_ERC721 mint "'($ALICE_PUBLIC_KEY, 6)'"

echo == Dan Mint new NFT, not admin, False
eval HOME=$DAN_HOME dfx canister call token_ERC721 mint "'($ALICE_PUBLIC_KEY, 7)'"


echo == Get all tokens, Success
eval dfx canister call token_ERC721 getAllTokens
echo == Get Alice Bob Dan tokensList, Alice, Bob Success, Dan False.
eval dfx canister call token_ERC721 getTokenList "'($ALICE_PUBLIC_KEY)'"
eval dfx canister call token_ERC721 getTokenList "'($BOB_PUBLIC_KEY)'"
eval dfx canister call token_ERC721 getTokenList "'($DAN_PUBLIC_KEY)'"
echo == Get totalSupply 7
eval dfx canister call token_ERC721 totalSupply

echo == Bob Set Token URI, Success, False
eval HOME=$BOB_HOME dfx canister call token_ERC721 setTokenURI "'(1, \"google.com/1\")'"
eval HOME=$BOB_HOME dfx canister call token_ERC721 setTokenURI "'(0, \"google.com/0\")'"

echo == get token URI
eval dfx canister call token_ERC721 tokenURI  "'(0)'"
eval dfx canister call token_ERC721 tokenURI "'(1)'"

echo == get token owner
eval dfx canister call token_ERC721 ownerOf "'(0)'"
eval dfx canister call token_ERC721 ownerOf "'(1)'"
eval dfx canister call token_ERC721 ownerOf "'(2)'"
eval dfx canister call token_ERC721 ownerOf "'(3)'"
eval dfx canister call token_ERC721 ownerOf "'(4)'"
eval dfx canister call token_ERC721 ownerOf "'(5)'"
eval dfx canister call token_ERC721 ownerOf "'(6)'"


echo == get token by owner by index
eval dfx canister call token_ERC721 tokenOfOwnerByIndex "'($ALICE_PUBLIC_KEY, 0)'"
eval dfx canister call token_ERC721 tokenOfOwnerByIndex "'($ALICE_PUBLIC_KEY, 1)'"
eval dfx canister call token_ERC721 tokenOfOwnerByIndex "'($ALICE_PUBLIC_KEY, 2)'"
eval dfx canister call token_ERC721 tokenOfOwnerByIndex "'($ALICE_PUBLIC_KEY, 3)'"
eval dfx canister call token_ERC721 tokenOfOwnerByIndex "'($BOB_PUBLIC_KEY, 0)'"
eval dfx canister call token_ERC721 tokenOfOwnerByIndex "'($BOB_PUBLIC_KEY, 1)'"
eval dfx canister call token_ERC721 tokenOfOwnerByIndex "'($BOB_PUBLIC_KEY, 2)'"
eval dfx canister call token_ERC721 tokenOfOwnerByIndex "'($BOB_PUBLIC_KEY, 3)'"

echo == get token by index 
eval dfx canister call token_ERC721 tokenByIndex "'(0)'"
eval dfx canister call token_ERC721 tokenByIndex "'(1)'"
eval dfx canister call token_ERC721 tokenByIndex "'(2)'"
eval dfx canister call token_ERC721 tokenByIndex "'(3)'"
eval dfx canister call token_ERC721 tokenByIndex "'(4)'"
eval dfx canister call token_ERC721 tokenByIndex "'(5)'"
eval dfx canister call token_ERC721 tokenByIndex "'(6)'"

echo == get balance 4,3, error
eval dfx canister call token_ERC721 balanceOf "'($ALICE_PUBLIC_KEY)'"
eval dfx canister call token_ERC721 balanceOf "'($BOB_PUBLIC_KEY)'"
eval dfx canister call token_ERC721 balanceOf "'($DAN_PUBLIC_KEY)'"

echo == Alice transfer self NFT to Bob, Dan, True
eval dfx canister call token_ERC721 transferFrom "'($ALICE_PUBLIC_KEY, $BOB_PUBLIC_KEY, 0)'"
eval dfx canister call token_ERC721 transferFrom "'($ALICE_PUBLIC_KEY, $DAN_PUBLIC_KEY, 2)'"
eval dfx canister call token_ERC721 transferFrom "'($BOB_PUBLIC_KEY, $DAN_PUBLIC_KEY, 1)'"
eval dfx canister call token_ERC721 transferFrom "'($BOB_PUBLIC_KEY, $DAN_PUBLIC_KEY, 4)'"
eval dfx canister call token_ERC721 transferFrom "'($ALICE_PUBLIC_KEY, $DAN_PUBLIC_KEY, 5)'"

echo == Bob approve Alice token 1
eval HOME=$BOB_HOME dfx canister call token_ERC721 approve "'($ALICE_PUBLIC_KEY, 1)'"
echo == get approved
eval dfx canister call token_ERC721 getApproved "'(1)'"
eval dfx canister call token_ERC721 getApproved "'(2)'"
echo == Alice transfer Bob token 1 to Alice
eval dfx canister call token_ERC721 safeTransferFrom "'($BOB_PUBLIC_KEY, $ALICE_PUBLIC_KEY, 1)'"
echo == get approved
eval dfx canister call token_ERC721 getApproved "'(1)'"
echo == get token owner
eval dfx canister call token_ERC721 ownerOf "'(1)'"
echo == Alice Set Token URI, Success
eval dfx canister call token_ERC721 setTokenURI "'(1, \"baidu.com/1\")'"
echo == get token URI 1
eval dfx canister call token_ERC721 tokenURI  "'(1)'"

echo == Bob set Dan approval For All
eval HOME=$BOB_HOME dfx canister call token_ERC721 setApprovalForAll "'($DAN_PUBLIC_KEY, true)'"
echo == get isApprovedForAll
eval dfx canister call token_ERC721 isApprovedForAll "'($BOB_PUBLIC_KEY, $DAN_PUBLIC_KEY)'"
eval dfx canister call token_ERC721 isApprovedForAll "'($BOB_PUBLIC_KEY, $ALICE_PUBLIC_KEY)'"
eval dfx canister call token_ERC721 isApprovedForAll "'($ALICE_PUBLIC_KEY, $DAN_PUBLIC_KEY)'"
echo == Bob set self approved For All
eval HOME=$BOB_HOME dfx canister call token_ERC721 setApprovalForAll "'($BOB_PUBLIC_KEY, true)'"
echo == get bob approved bob
eval dfx canister call token_ERC721 isApprovedForAll "'($BOB_PUBLIC_KEY, $BOB_PUBLIC_KEY)'"

echo == Dan transfer Bob NFT to Dan
eval HOME=$DAN_HOME dfx canister call token_ERC721 safeTransferFromWithData "'($BOB_PUBLIC_KEY, $DAN_PUBLIC_KEY, 3, \"safetransfer\")'"


echo == Get Alice Bob Dan tokensList, Success
eval dfx canister call token_ERC721 getTokenList "'($ALICE_PUBLIC_KEY)'"
eval dfx canister call token_ERC721 getTokenList "'($BOB_PUBLIC_KEY)'"
eval dfx canister call token_ERC721 getTokenList "'($DAN_PUBLIC_KEY)'"


echo == get token owner
eval dfx canister call token_ERC721 ownerOf "'(0)'"
eval dfx canister call token_ERC721 ownerOf "'(1)'"
eval dfx canister call token_ERC721 ownerOf "'(2)'"
eval dfx canister call token_ERC721 ownerOf "'(3)'"
eval dfx canister call token_ERC721 ownerOf "'(4)'"
eval dfx canister call token_ERC721 ownerOf "'(5)'"
eval dfx canister call token_ERC721 ownerOf "'(6)'"


echo == get token by owner by index
eval dfx canister call token_ERC721 tokenOfOwnerByIndex "'($ALICE_PUBLIC_KEY, 0)'"
eval dfx canister call token_ERC721 tokenOfOwnerByIndex "'($ALICE_PUBLIC_KEY, 1)'"
eval dfx canister call token_ERC721 tokenOfOwnerByIndex "'($ALICE_PUBLIC_KEY, 2)'"
eval dfx canister call token_ERC721 tokenOfOwnerByIndex "'($ALICE_PUBLIC_KEY, 3)'"
eval dfx canister call token_ERC721 tokenOfOwnerByIndex "'($BOB_PUBLIC_KEY, 0)'"
eval dfx canister call token_ERC721 tokenOfOwnerByIndex "'($BOB_PUBLIC_KEY, 1)'"
eval dfx canister call token_ERC721 tokenOfOwnerByIndex "'($BOB_PUBLIC_KEY, 2)'"
eval dfx canister call token_ERC721 tokenOfOwnerByIndex "'($BOB_PUBLIC_KEY, 3)'"

echo == get token by index 
eval dfx canister call token_ERC721 tokenByIndex "'(0)'"
eval dfx canister call token_ERC721 tokenByIndex "'(1)'"
eval dfx canister call token_ERC721 tokenByIndex "'(2)'"
eval dfx canister call token_ERC721 tokenByIndex "'(3)'"
eval dfx canister call token_ERC721 tokenByIndex "'(4)'"
eval dfx canister call token_ERC721 tokenByIndex "'(5)'"
eval dfx canister call token_ERC721 tokenByIndex "'(6)'"

echo == get balance 3,3, error
eval dfx canister call token_ERC721 balanceOf "'($ALICE_PUBLIC_KEY)'"
eval dfx canister call token_ERC721 balanceOf "'($BOB_PUBLIC_KEY)'"
eval dfx canister call token_ERC721 balanceOf "'($DAN_PUBLIC_KEY)'"

echo == owner of token 3
eval dfx canister call token_ERC721 ownerOf "'(3)'"

echo == bob transfer nft 3 to canister 
eval HOME=$BOB_HOME dfx canister call token_ERC721 transferFrom "'($BOB_PUBLIC_KEY, $NFT_ID, 3)'"
echo == owner of token3
eval dfx canister call token_ERC721 ownerOf "'(3)'"

echo == admin alice withdraw token 3 to Dan
eval dfx canister call token_ERC721 withdraw "'(3, $DAN_PUBLIC_KEY)'"

echo == owner of token3
eval dfx canister call token_ERC721 ownerOf "'(3)'"

echo == admin bob burn token 2
eval HOME=$BOB_HOME dfx canister call token_ERC721 burn "'(2)'"
eval HOME=$BOB_HOME dfx canister call token_ERC721 burn "'(7)'"

echo == Get allTokens
eval dfx canister call token_ERC721 getAllTokens

echo == Get Alice Bob Dan tokensList, Success
eval dfx canister call token_ERC721 getTokenList "'($ALICE_PUBLIC_KEY)'"
eval dfx canister call token_ERC721 getTokenList "'($BOB_PUBLIC_KEY)'"
eval dfx canister call token_ERC721 getTokenList "'($DAN_PUBLIC_KEY)'"

echo == get token owner
eval dfx canister call token_ERC721 ownerOf "'(0)'"
eval dfx canister call token_ERC721 ownerOf "'(1)'"
eval dfx canister call token_ERC721 ownerOf "'(2)'"
eval dfx canister call token_ERC721 ownerOf "'(3)'"
eval dfx canister call token_ERC721 ownerOf "'(4)'"
eval dfx canister call token_ERC721 ownerOf "'(5)'"
eval dfx canister call token_ERC721 ownerOf "'(6)'"


echo == get token by owner by index
eval dfx canister call token_ERC721 tokenOfOwnerByIndex "'($ALICE_PUBLIC_KEY, 0)'"
eval dfx canister call token_ERC721 tokenOfOwnerByIndex "'($ALICE_PUBLIC_KEY, 1)'"
eval dfx canister call token_ERC721 tokenOfOwnerByIndex "'($ALICE_PUBLIC_KEY, 2)'"
eval dfx canister call token_ERC721 tokenOfOwnerByIndex "'($ALICE_PUBLIC_KEY, 3)'"
eval dfx canister call token_ERC721 tokenOfOwnerByIndex "'($BOB_PUBLIC_KEY, 0)'"
eval dfx canister call token_ERC721 tokenOfOwnerByIndex "'($BOB_PUBLIC_KEY, 1)'"
eval dfx canister call token_ERC721 tokenOfOwnerByIndex "'($BOB_PUBLIC_KEY, 2)'"
eval dfx canister call token_ERC721 tokenOfOwnerByIndex "'($BOB_PUBLIC_KEY, 3)'"

echo == get token by index 
eval dfx canister call token_ERC721 tokenByIndex "'(0)'"
eval dfx canister call token_ERC721 tokenByIndex "'(1)'"
eval dfx canister call token_ERC721 tokenByIndex "'(2)'"
eval dfx canister call token_ERC721 tokenByIndex "'(3)'"
eval dfx canister call token_ERC721 tokenByIndex "'(4)'"
eval dfx canister call token_ERC721 tokenByIndex "'(5)'"
eval dfx canister call token_ERC721 tokenByIndex "'(6)'"

echo == get balance 
eval dfx canister call token_ERC721 balanceOf "'($ALICE_PUBLIC_KEY)'"
eval dfx canister call token_ERC721 balanceOf "'($BOB_PUBLIC_KEY)'"
eval dfx canister call token_ERC721 balanceOf "'($DAN_PUBLIC_KEY)'"

dfx stop
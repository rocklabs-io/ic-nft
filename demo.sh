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

dfx start --background
dfx canister --no-wallet create token_ERC721
dfx canister --no-wallet create token_ERC20
dfx build

eval dfx canister --no-wallet install token_ERC721 --argument="'(\"Test NFT 1\", \"NFT1\",$ALICE_PUBLIC_KEY)'" -m=reinstall
eval dfx canister --no-wallet install token_ERC20 --argument="'(\"Test token\", \"tst\", 3, 1_000_000_000, $ALICE_PUBLIC_KEY)'" -m=reinstall

echo Alice id = $ALICE_PUBLIC_KEY
echo Bob id = $BOB_PUBLIC_KEY
echo Dan id = $DAN_PUBLIC_KEY
echo Fee id = $FEE_PUBLIC_KEY

NFT_ID=$(dfx canister --no-wallet id token_ERC721)
NFT_ID="principal \"$NFT_ID\""
TOKENID=$(dfx canister --no-wallet id token_ERC20)
TOKENID="principal \"$TOKENID\""
echo token_erc721 principal: $NFT_ID
echo token_erc20 principal: $TOKENID

echo == admin Alice set NFT Mint price and Mint fee
eval dfx canister --no-wallet call token_ERC721 setFeePrice "'(1000)'"
eval dfx canister --no-wallet call token_ERC721 setErc20 "'($TOKENID)'"
eval dfx canister --no-wallet call token_ERC721 setFeePool "'($FEE_PUBLIC_KEY)'"

echo == admin Alice Approve NFT canister transferFrom her ERC20 Token
eval dfx canister --no-wallet call token_ERC20 approve "'($NFT_ID, 1_000_000)'"


echo == Alice is admins, True
eval dfx canister --no-wallet call token_ERC721 isAdmin "'($ALICE_PUBLIC_KEY)'"
echo == Bob isnot admins, False
eval dfx canister --no-wallet call token_ERC721 isAdmin "'($BOB_PUBLIC_KEY)'"
echo == Set bob admin
eval dfx canister --no-wallet call token_ERC721 setAdmin "'($BOB_PUBLIC_KEY, true)'"
echo == Bob is admins, true
eval dfx canister --no-wallet call token_ERC721 isAdmin "'($BOB_PUBLIC_KEY)'"

echo == Get name, symbol
eval dfx canister --no-wallet call token_ERC721 name
eval dfx canister --no-wallet call token_ERC721 symbol


echo == Alice Mint 3 NFT to self, 3 NFT to Bob, all True
eval dfx canister --no-wallet call token_ERC721 mint "'($ALICE_PUBLIC_KEY, 0)'"
eval dfx canister --no-wallet call token_ERC721 mint "'($BOB_PUBLIC_KEY, 1)'"
eval dfx canister --no-wallet call token_ERC721 mint "'($ALICE_PUBLIC_KEY, 2)'"
eval dfx canister --no-wallet call token_ERC721 mint "'($BOB_PUBLIC_KEY, 3)'"
eval dfx canister --no-wallet call token_ERC721 mint "'($ALICE_PUBLIC_KEY, 4)'"
eval dfx canister --no-wallet call token_ERC721 mint "'($BOB_PUBLIC_KEY, 5)'"

echo == fee pool balance
eval dfx canister --no-wallet call token_ERC20 balanceOf "'($FEE_PUBLIC_KEY)'"

echo == Alice Mint exists token, False 
eval dfx canister --no-wallet call token_ERC721 mint "'($ALICE_PUBLIC_KEY, 0)'"

echo == Bob Mint new NFT, False, no erc20 token
eval HOME=$BOB_HOME dfx canister --no-wallet call token_ERC721 mint "'($ALICE_PUBLIC_KEY, 6)'"

echo == Dan Mint new NFT, False, no erc20 token
eval HOME=$DAN_HOME dfx canister --no-wallet call token_ERC721 mint "'($ALICE_PUBLIC_KEY, 7)'"


echo == Get all tokens, Success
eval dfx canister --no-wallet call token_ERC721 getAllTokens
echo == Get Alice Bob Dan tokensList, Alice, Bob Success, Dan False.
eval dfx canister --no-wallet call token_ERC721 getTokenList "'($ALICE_PUBLIC_KEY)'"
eval dfx canister --no-wallet call token_ERC721 getTokenList "'($BOB_PUBLIC_KEY)'"
eval dfx canister --no-wallet call token_ERC721 getTokenList "'($DAN_PUBLIC_KEY)'"
echo == Get totalSupply 6
eval dfx canister --no-wallet call token_ERC721 totalSupply

echo == Alice and Bob Set Token URI, Success, False
eval HOME=$ALICE_HOME dfx canister --no-wallet call token_ERC721 setTokenURI "'(0, \"google.com/0\")'"
eval HOME=$BOB_HOME dfx canister --no-wallet call token_ERC721 setTokenURI "'(2, \"google.com/2\")'"

echo == get token URI
eval dfx canister --no-wallet call token_ERC721 tokenURI  "'(0)'"
eval dfx canister --no-wallet call token_ERC721 tokenURI "'(1)'"

echo == get token owner
eval dfx canister --no-wallet call token_ERC721 ownerOf "'(0)'"
eval dfx canister --no-wallet call token_ERC721 ownerOf "'(1)'"
eval dfx canister --no-wallet call token_ERC721 ownerOf "'(2)'"
eval dfx canister --no-wallet call token_ERC721 ownerOf "'(3)'"
eval dfx canister --no-wallet call token_ERC721 ownerOf "'(4)'"
eval dfx canister --no-wallet call token_ERC721 ownerOf "'(5)'"
eval dfx canister --no-wallet call token_ERC721 ownerOf "'(6)'"


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
eval dfx canister --no-wallet call token_ERC721 tokenByIndex "'(6)'"

echo == get balance 3,3, 0
eval dfx canister --no-wallet call token_ERC721 balanceOf "'($ALICE_PUBLIC_KEY)'"
eval dfx canister --no-wallet call token_ERC721 balanceOf "'($BOB_PUBLIC_KEY)'"
eval dfx canister --no-wallet call token_ERC721 balanceOf "'($DAN_PUBLIC_KEY)'"

echo == Alice transfer self NFT to Bob, Dan, 0,2,True; 1,4,5 False
eval dfx canister --no-wallet call token_ERC721 transferFrom "'($ALICE_PUBLIC_KEY, $BOB_PUBLIC_KEY, 0)'"
eval dfx canister --no-wallet call token_ERC721 transferFrom "'($ALICE_PUBLIC_KEY, $DAN_PUBLIC_KEY, 2)'"
eval dfx canister --no-wallet call token_ERC721 transferFrom "'($BOB_PUBLIC_KEY, $DAN_PUBLIC_KEY, 1)'"
eval dfx canister --no-wallet call token_ERC721 transferFrom "'($BOB_PUBLIC_KEY, $DAN_PUBLIC_KEY, 4)'"
eval dfx canister --no-wallet call token_ERC721 transferFrom "'($ALICE_PUBLIC_KEY, $DAN_PUBLIC_KEY, 5)'"

echo == Bob approve Alice token 1
eval HOME=$BOB_HOME dfx canister --no-wallet call token_ERC721 approve "'($ALICE_PUBLIC_KEY, 1)'"
echo == get approved
eval dfx canister --no-wallet call token_ERC721 getApproved "'(1)'"
eval dfx canister --no-wallet call token_ERC721 getApproved "'(2)'"
echo == Alice transfer Bob token 1 to Alice
eval dfx canister --no-wallet call token_ERC721 safeTransferFrom "'($BOB_PUBLIC_KEY, $ALICE_PUBLIC_KEY, 1)'"
echo == get approved
eval dfx canister --no-wallet call token_ERC721 getApproved "'(1)'"
echo == get token owner
eval dfx canister --no-wallet call token_ERC721 ownerOf "'(1)'"
echo == Alice Set Token URI, Success
eval dfx canister --no-wallet call token_ERC721 setTokenURI "'(1, \"baidu.com/1\")'"
echo == get token URI 1
eval dfx canister --no-wallet call token_ERC721 tokenURI  "'(1)'"

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

echo == Dan transfer Bob NFT to Dan
eval HOME=$DAN_HOME dfx canister --no-wallet call token_ERC721 safeTransferFromWithData "'($BOB_PUBLIC_KEY, $DAN_PUBLIC_KEY, 3, \"safetransfer\")'"


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
eval dfx canister --no-wallet call token_ERC721 tokenOfOwnerByIndex "'($DAN_PUBLIC_KEY, 0)'"
eval dfx canister --no-wallet call token_ERC721 tokenOfOwnerByIndex "'($DAN_PUBLIC_KEY, 1)'"
eval dfx canister --no-wallet call token_ERC721 tokenOfOwnerByIndex "'($BOB_PUBLIC_KEY, 2)'"


echo == get token by index 
eval dfx canister --no-wallet call token_ERC721 tokenByIndex "'(0)'"
eval dfx canister --no-wallet call token_ERC721 tokenByIndex "'(1)'"
eval dfx canister --no-wallet call token_ERC721 tokenByIndex "'(2)'"
eval dfx canister --no-wallet call token_ERC721 tokenByIndex "'(3)'"
eval dfx canister --no-wallet call token_ERC721 tokenByIndex "'(4)'"
eval dfx canister --no-wallet call token_ERC721 tokenByIndex "'(5)'"

echo == get balance 3,3, 0
eval dfx canister --no-wallet call token_ERC721 balanceOf "'($ALICE_PUBLIC_KEY)'"
eval dfx canister --no-wallet call token_ERC721 balanceOf "'($BOB_PUBLIC_KEY)'"
eval dfx canister --no-wallet call token_ERC721 balanceOf "'($DAN_PUBLIC_KEY)'"

echo == owner of token 3
eval dfx canister --no-wallet call token_ERC721 ownerOf "'(3)'"

echo == Dan transfer nft 3 to canister 
eval HOME=$DAN_HOME dfx canister --no-wallet call token_ERC721 transferFrom "'($DAN_PUBLIC_KEY, $NFT_ID, 3)'"
echo == owner of token3
eval dfx canister --no-wallet call token_ERC721 ownerOf "'(3)'"

echo == admin alice withdraw token 3 to Dan
eval dfx canister --no-wallet call token_ERC721 withdraw "'(3, $DAN_PUBLIC_KEY)'"

echo == owner of token3
eval dfx canister --no-wallet call token_ERC721 ownerOf "'(3)'"

echo == admin bob burn token 2
eval HOME=$BOB_HOME dfx canister --no-wallet call token_ERC721 burn "'(2)'"
eval HOME=$BOB_HOME dfx canister --no-wallet call token_ERC721 burn "'(7)'"

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

echo == Alice favourite 1,2,3 NFT token, 2 false
eval HOME=$ALICE_HOME dfx canister --no-wallet call token_ERC721 favourite "'(1)'"
eval HOME=$ALICE_HOME dfx canister --no-wallet call token_ERC721 favourite "'(2)'"
eval HOME=$ALICE_HOME dfx canister --no-wallet call token_ERC721 favourite "'(3)'"

echo == Bob favourite 2,3,5,6 NFT token 3,5 success, 2,6 Failed
eval HOME=$BOB_HOME dfx canister --no-wallet call token_ERC721 favourite "'(2)'"
eval HOME=$BOB_HOME dfx canister --no-wallet call token_ERC721 favourite "'(3)'"
eval HOME=$BOB_HOME dfx canister --no-wallet call token_ERC721 favourite "'(5)'"
eval HOME=$BOB_HOME dfx canister --no-wallet call token_ERC721 favourite "'(6)'"

echo == get ALICE, BOB favourites,1,2,3 2,3,5
eval dfx canister --no-wallet call token_ERC721 getFavourites "'($ALICE_PUBLIC_KEY)'"
eval dfx canister --no-wallet call token_ERC721 getFavourites "'($BOB_PUBLIC_KEY)'"

echo == get 1,2,3,5, 0 favouritedBy, 1,2,2,1,0
eval dfx canister --no-wallet call token_ERC721 getFavouritedBy "'(1)'"
eval dfx canister --no-wallet call token_ERC721 getFavouritedBy "'(2)'"
eval dfx canister --no-wallet call token_ERC721 getFavouritedBy "'(3)'"
eval dfx canister --no-wallet call token_ERC721 getFavouritedBy "'(5)'"
eval dfx canister --no-wallet call token_ERC721 getFavouritedBy "'(0)'"

dfx stop
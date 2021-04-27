
### 1. 已有方法

name

symbol

balanceOf

ownerOf

_exists

transferFrom

_transfer

approve

getApproved


setApprovalForAll

isApprovedForAll

_isApprovedOrOwner

_mint

_burn


### 2021.04.26 本次提交完善方法

private func _addTokenTo(to: Principal, tokenId: Nat) 

private func _clearApproval(owner: Principal, tokenId: Nat) 

private func _removeTokenFrom(owner: Principal, tokenId: Nat)


### 2021.04.27 本次提交完善

1. 内部调用使用private ，外部调用才使用async。

2. 完善以下方法

public shared(msg) func transferFrom(from: Principal, to: Principal, tokenId: Nat) : async Bool 

private func _transfer(from: Principal, to: Principal, tokenId: Nat) :  Bool 

private func _safeTransfer(from: Principal, to: Principal, tokenId: Nat, data: Text) :  Bool 

function safeTransferFrom(address from, address to, uint256 tokenId) external;

function safeTransferFromWithData(address from, address to, uint256 tokenId, bytes calldata data) external;

function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual


### 2. 待讨论问题

1. throw Error 报错

/Users/suzy/2021project/dfinity/nft-team/nft-token/src/token_ERC721/main.mo:68.17-68.59: type error [M0039], misplaced throw

2. _checkOnERC721Received

需要校验哪些条件

3. tokenURI  

4. 一起检查 方法的 public 和 private 的界定






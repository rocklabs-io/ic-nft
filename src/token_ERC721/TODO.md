
1. 已有方法
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


1. 本次提交完善方法
private func _addTokenTo(to: Principal, tokenId: Nat) 
private func _clearApproval(owner: Principal, tokenId: Nat) 
private func _removeTokenFrom(owner: Principal, tokenId: Nat)


2. 待完善方法

function safeTransferFrom(address from, address to, uint256 tokenId) external;

function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual

function _safeMint(address to, uint256 tokenId) internal virtual 
function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual 

function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)


private func _setTokenURI(){ }




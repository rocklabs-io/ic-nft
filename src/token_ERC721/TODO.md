

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

### 2021.04.29 本次提交完善
  完善tokenURI方法 实现solidity-ERC721功能 

  略微改动 未用assert 原因为其无法返回查询不到的Text，改为switch-case结构



### 2021. 04. 30  本次提交完善 
1. 对 _mint 方法中 ownedTokens List 的处理进行完善。

先把tokenId 转换为List， 然后使用append方法。

2. 对 _burn 方法中 ownedTokens List 的处理进行完善。
 
使用filter 方法。

3. 对 _transfer 方法中 ownedTokens List 的处理进行完善。



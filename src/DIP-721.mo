/// @notice Count all NFTs assigned to an owner
/// @dev NFTs assigned to the zero address are considered invalid, and this
///  function throws for queries about the zero address.
/// @param _owner An address for whom to query the balance
/// @return The number of NFTs owned by `_owner`, possibly zero
public query func balanceOf(_owner: Principal) : async Nat {}

/// @notice Find the owner of an NFT
/// @dev NFTs assigned to zero address are considered invalid, and queries
///  about them do throw.
/// @param _tokenId The identifier for an NFT
/// @return The address of the owner of the NFT
public  query func ownerOf (_tokenId: Nat) : async Principal {}

/// @notice Transfers the ownership of an NFT from one address to another address
/// @dev Throws unless `msg.caller` is the current owner, an authorized
///  operator, or the approved address for this NFT. Throws if `_from` is
///  not the current owner. Throws if `_to` is the zero address. Throws if
///  `_tokenId` is not a valid NFT. When transfer is complete, this function
///  checks if `_to` is a smart contract (code size > 0). If so, it calls
///  `onERC721Received` on `_to` and throws if the return value is not
///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
/// @param _from The current owner of the NFT
/// @param _to The new owner
/// @param _tokenId The NFT to transfer
/// @param data Additional data with no specified format, sent in call to `_to`
// 这个接口需要改名或者删除，因为在 motoko 里面会判断重命名
public shared(msg) func safeTransferFrom(_from: Principal, _to: Principal, _tokenId: Nat, data: Text) : async Bool {}

/// @notice Transfers the ownership of an NFT from one address to another address
/// @dev This works identically to the other function with an extra data parameter,
///  except this function just sets data to "".
/// @param _from The current owner of the NFT
/// @param _to The new owner
/// @param _tokenId The NFT to transfer
public shared(msg) func safeTransferFrom(_from: Principal, _to: Principal, _tokenId: Nat) : async Bool {}

/// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
///  THEY MAY BE PERMANENTLY LOST
/// @dev Throws unless `msg.sender` is the current owner, an authorized
///  operator, or the approved address for this NFT. Throws if `_from` is
///  not the current owner. Throws if `_to` is the zero address. Throws if
///  `_tokenId` is not a valid NFT.
/// @param _from The current owner of the NFT
/// @param _to The new owner
/// @param _tokenId The NFT to transfer
public shared(msg) func transferFrom(_from: Principal, _to: Principal, _tokenId: Nat) : async Bool {}

/// @notice Change or reaffirm the approved address for an NFT
/// @dev The zero address indicates there is no approved address.
///  Throws unless `msg.caller` is the current NFT owner, or an authorized
///  operator of the current owner.
/// @param _approved The new approved NFT controller
/// @param _tokenId The NFT to approve
public shared(msg) func approve(_approved: Principal, _tokenId: Nat ) : async Bool {}

/// @notice Enable or disable approval for a third party ("operator") to manage
///  all of `msg.caller`'s assets
/// @dev Emits the ApprovalForAll event. The contract MUST allow
///  multiple operators per owner.
/// @param _operator Address to add to the set of authorized operators
/// @param _approved True if the operator is approved, false to revoke approval
public shared(msg) func setApprovalForAll(_operator: Principal, _approved: Bool) : async Bool {}

/// @notice Get the approved address for a single NFT
/// @dev Throws if `_tokenId` is not a valid NFT.
/// @param _tokenId The NFT to find the approved address for
/// @return The approved address for this NFT, or the zero address if there is none
public query func getApproved (_tokenId: Nat) : async Principal {

/// @notice Query if an address is an authorized operator for another address
/// @param _owner The address that owns the NFTs
/// @param _operator The address that acts on behalf of the owner
/// @return True if `_operator` is an approved operator for `_owner`, false otherwise
public query func isApprovedForAll(_owner: Principal, _operator: Principal) : async Bool {}


/// @notice Handle the receipt of an NFT
/// @dev The ERC721 smart contract calls this function on the recipient
///  after a `transfer`. This function MAY throw to revert and reject the
///  transfer. Return of other than the magic value MUST result in the
///  transaction being reverted.
///  Note: the contract address is always the message sender.
/// @param _operator The address which called `safeTransferFrom` function
/// @param _from The address which previously owned the token
/// @param _tokenId The NFT identifier which is being transferred
/// @param _data Additional data with no specified format
/// @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
///  unless throwing
public query func onERC721Received(_operator: Principal, _from: Principal, _tokenId: Nat, data: Text) : async Char {}


/// @notice A descriptive name for a collection of NFTs in this contract
public query func name() : async Text {}

/// @notice An abbreviated name for NFTs in this contract
public query func symbol() : async Text {}

/// @notice A distinct Uniform Resource Identifier (URI) for a given asset.
/// @dev Throws if `_tokenId` is not a valid NFT. URIs are defined in RFC
///  3986. The URI may point to a JSON file that conforms to the "ERC721
///  Metadata JSON Schema".
public query func tokenURI(_tokenId: Nat) : async Text {}


/// @notice Count NFTs tracked by this contract
/// @return A count of valid NFTs tracked by this contract, where each one of
///  them has an assigned and queryable owner not equal to the zero address
public query func totalSupply() : async Nat {}

/// @notice Enumerate valid NFTs
/// @dev Throws if `_index` >= `totalSupply()`.
/// @param _index A counter less than `totalSupply()`
/// @return The token identifier for the `_index`th NFT,
///  (sort order not specified)
public query func tokenByIndex(_index: Nat) : async Nat {}

/// @notice Enumerate NFTs assigned to an owner
/// @dev Throws if `_index` >= `balanceOf(_owner)` or if
///  `_owner` is the zero address, representing invalid NFTs.
/// @param _owner An address where we are interested in NFTs owned by them
/// @param _index A counter less than `balanceOf(_owner)`
/// @return The token identifier for the `_index`th NFT assigned to `_owner`,
///   (sort order not specified)
public query func tokenOfOwnerByIndex(_owner: Principal, _index: Nat) : async Nat {}


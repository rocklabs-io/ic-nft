import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Error "mo:base/Error";
import Option "mo:base/Option";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Text "mo:base/Text";

/**
 *  Implementation of https://github.com/icplabs/DIPs/blob/main/DIPS/dip-721.md Non-Fungible Token Standard.
 */
actor Token_ERC721{

    // Token name
    private stable var name_ : Text = "";

    // Token symbol
    private stable var symbol_ : Text = "";

    //the Uniform Resource Identifier (URI) for `tokenId` token.
    private var tokenURIs_ = HashMap.HashMap<Nat, Text>(1, Nat.equal, Hash.hash);

    // Mapping from token ID to owner address
    private var ownered = HashMap.HashMap<Nat, Principal>(1, Nat.equal, Hash.hash);
    
    // Mapping owner address to token count
    private var balances = HashMap.HashMap<Principal, Nat>(1,Principal.equal,Principal.hash);

    // Mapping from token ID to approved address
    private var tokenApprovals = HashMap.HashMap<Nat, Principal>(1, Nat.equal, Hash.hash);
    
    // Mapping from owner to operator approvals
    private var operatorApprovals = HashMap.HashMap<Principal, HashMap.HashMap<Principal, Bool>>(1, Principal.equal, Principal.hash);

    //Mapping from owner to token list
    private var ownedTokens = HashMap.HashMap<Principal, [var Nat]>(1, Principal.equal, Principal.hash);

    
    /**
    * @dev Returns whether the specified token exists
    * @param tokenId Nat ID of the token to query the existence of
    * @return whether the token exists
    */
    private func _exists(tokenId: Nat) : Bool {
        switch (ownered.get(tokenId)) {
            case (? owner) {
                return true;
            };
            case (_) {
                return false;
            };
        }
    };

    /*
     * @notice Find the owner of an NFT
     * NFTs assigned to the zero address are considered invalid, 
     * and queries about them do throw.
     * @param _tokenId The identifier for an NFT
     * @return The address of the owner of the NFT
     */
    private func _ownerOf(tokenId: Nat) : Principal {
        switch (ownered.get(tokenId)) {
            case (? owner) {
                return owner;
            };
            case _ {
                throw Error.reject("token does not exist")
            };
        }
    };

    /*
     * @notice Count all NFTs assigned to an owner
     * NFTs assigned to the zero address are considered invalid, 
     * and this function throws for queries about the zero address.
     * @param _owner An address for whom to query the balance
     * @return The number of NFTs owned by `_owner`, possibly zero
     */
    private func _balanceOf(who: Principal) : Nat {
        switch (balances.get(who)) {
            case (? balance) {
                return balance;
            };
            case _ {
                throw Error.reject("Failed to query balance")
            };
        }
    };

    /**
     * Returns whether `spender` is allowed to manage `tokenId`.
     * Requirements:
     * - `tokenId` must exist.
     */
    private func _isApprovedOrOwner(spender: Principal, tokenId: Nat) : Bool {
        let owner = _ownerOf(tokenId);
        return (spender == owner or (_getApproved(tokenId) == spender) or _isApprovedForAll(owner, spender));
    };

    /**
    * @dev private function to mint a new token
    * Reverts if the given token ID already exists
    * @param to The address that will own the minted token
    * @param tokenId Nat ID of the token to be minted by the msg.sender
    */
    private func _mint(to: Principal, tokenId: Nat): Bool {
       return _addTokenTo(to, tokenId);
    };

    private func _addTokenTo(to: Principal, tokenId: Nat) : Bool {
        assert(_exists(tokenId) == false);
        //_tok
        switch(balances.get(to)) {
            case (? to_balance) {
                var to_balcance_new = to_balance + 1;
                balances.put(to, to_balcance_new);
                ownered.put(tokenId, to);
                //TODO  ownedTokens need update.
                return true;
            };
            case (_) {
                return false;
            };
        }
    };

    /**
    * @dev Internal function to burn a specific token
    * Reverts if the token does not exist
    * @param tokenId uint256 ID of the token being burned by the msg.sender
    */
    private func _burn(owner: Principal, tokenId: Nat) : Bool{
        _clearApproval(owner, tokenId);
        return _removeTokenFrom(owner, tokenId);
    };

    private func _clearApproval(owner: Principal, tokenId: Nat) {
        assert(_ownerOf(tokenId) == owner);
        tokenApprovals.delete(tokenId);

    };

    private func _removeTokenFrom(owner: Principal, tokenId: Nat): Bool {
        assert(_ownerOf(tokenId) == owner);
        switch(balances.get(owner)) {
            case (? owner_balance) {
                var owner_balcance_new = owner_balance - 1;
                balances.put(owner, owner_balcance_new);
                ownered.delete(tokenId);
                // TODO ownedTokens need update.
                return true;
            };
            case (_) {
                return false;
            };
        }
    };

    // private func _checkAndCallSafeTransfer(from, to, tokenId, _data) : Bool {

    // };

    private func _setTokenURI(){

    };

    /**
     * Token name
     */
    public query func name() : async Text {
        return name_;
    };

    /**
     * Token symbol
     */
    public query func symbol() : async Text {
        return symbol_;
    };

    /*
     * @notice Change or reaffirm the approved address for an NFT
     * The zero address indicates there is no approved address.
     * Throws unless `msg.caller` is the current NFT owner, or an authorized operator of the current owner.
     * @param _approved The new approved NFT controller
     * @param _tokenId The NFT to approve
     */
    public shared(msg) func approve(spender: Principal, tokenId: Nat ) : async Bool {
        var owner: Principal = _ownerOf(tokenId);
        assert(Principal.equal(msg.caller, owner) or _isApprovedForAll(owner, msg.caller));
        assert(owner != spender);
        _approve(spender, tokenId);
        return true;
    };

    private func _approve(spender: Principal, tokenId: Nat) {
        assert(_exists(tokenId));
        tokenApprovals.put(tokenId, spender);
    };

    /*
     * @notice Get the approved address for a single NFT
     * throws if `_tokenId` is not a valid NFT.
     * @param _tokenId The NFT to find the approved address for
     * @return The approved address for this NFT, or the zero address if there is none
     */
    private func _getApproved(tokenId: Nat) : Principal {
        assert(_exists(tokenId));
        switch (tokenApprovals.get(tokenId)) {
            case (?approved) {
                return approved;
            };
            case _ {
                throw Error.reject("token has no approved Principal") 
            };
        }
    };

    /*
     * @notice Enable or disable approval for a third party ("operator") to manage all of `msg.caller`'s assets
     * The contract MUST allow multiple operators per owner.
     * Throws unless `msg.caller` is the current NFT owner, or an authorized operator of the current owner.
     * @param _operator Address to add to the set of authorized operators
     * @param _approved True if the operator is approved, false to revoke approval
     */
    public shared(msg) func setApprovalForAll(operator: Principal, approved: Bool) : async Bool {
        assert(msg.caller != operator);
        switch (operatorApprovals.get(msg.caller)) {
            case (?operatorMap) {
                operatorMap.put(operator,approved);
                operatorApprovals.put(msg.caller,operatorMap);
                return true;
            };
            case (_) {
                var temp = HashMap.HashMap<Principal,Bool>(1, Principal.equal, Principal.hash);
                temp.put(operator, approved);
                operatorApprovals.put(msg.caller,temp);
                return true;
            };
        }
    };

    /*
     * @notice Query if an address is an authorized operator for another address
     * @param _owner The address that owns the NFTs
     * @param _operator The address that acts on behalf of the owner
     * @return True if `_operator` is an approved operator for `_owner`, false otherwise
     */
    private func _isApprovedForAll(owner: Principal, operator: Principal) : Bool {
        switch(operatorApprovals.get(owner)){
            case (?ownerApprove) {
                switch (ownerApprove.get(operator)) {
                    case (?approval) {
                        return approval;
                    };
                    case (_) {
                        return false;
                    };
                }
            };
            case (_) {
                return false;
            };
        }
    };

    /*
     * @notice Transfer ownership of an NFT
     * THE CALLER IS RESPONSIBLE TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS 
     * OR ELSE THEY MAY BE PERMANENTLY LOST
     * Throws unless `msg.sender` is the current owner, an authorized operator, or the approved address for this NFT. 
     * Throws if `_from` is not the current owner. Throws if `_to` is the zero address. Throws if `_tokenId` is not a valid NFT.
     * @param _from The current owner of the NFT.
     * @param _to The new owner.
     * @param _tokenId The NFT to transfer
     */
    public shared(msg) func transferFrom(from: Principal, to: Principal, tokenId: Nat) : async Bool {
        assert (_isApprovedOrOwner(msg.caller, tokenId));
        return  _transfer(from, to , tokenId);
    };

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.caller.
     *
     * Requirements:
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     */
    private func _transfer(from: Principal, to: Principal, tokenId: Nat) :  Bool {
        var owner: Principal =  _ownerOf(tokenId);
        assert(owner == from);
        _clearApproval(from, tokenId);
        switch(balances.get(from), balances.get(to)) {
            case(?from_balance, ?to_balance) {
                var from_balance_new =  from_balance - 1;
                var to_balance_new = to_balance + 1;
                ownered.put(tokenId, to);
                return true;
            };
            case (_) {
                return false;
            };
        }
    };

    public shared(msg) func safeTransferFrom(from: Principal, to: Principal, tokenId: Nat) : async Bool {
        return await safeTransferFromWithData(from, to, tokenId, "ICP");
    };

    public shared(msg) func safeTransferFromWithData(from: Principal, to: Principal, tokenId: Nat, data: Text) : async Bool {
        assert (_isApprovedOrOwner(msg.caller, tokenId));
        return  _safeTransfer(from, to , tokenId, data);


    };

    private func _safeTransfer(from: Principal, to: Principal, tokenId: Nat, data: Text) :  Bool {
        var bool : Bool  = _transfer(from, to , tokenId);
        return _checkOnERC721Received(from, to, tokenId, data);
    };

    //TODO  what should I check ?
    private func _checkOnERC721Received(from: Principal, to: Principal, tokenId: Nat, data: Text) : Bool {
      //TODO
      return true;  
    };


    //TODO 
    private func tokenURI(tokenId: Principal) :  Text {
        return "";
    };

};

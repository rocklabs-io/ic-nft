import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Utils "./utils"; 
import Error "mo:base/Error";
import Option "mo:base/Option";

/**
 *  Implementation of https://github.com/icplabs/DIPs/blob/main/DIPS/dip-721.md Non-Fungible Token Standard.
 */
actor Token_ERC721{

    // Token name
    private stable var name_ : Text = "";

    // Token symbol
    private stable var symbol_ : Text = "";

    // Mapping from token ID to owner address
    private var ownered = HashMap.HashMap<Principal, Principal>(1, Principal.equal, Principal.hash);
    
    // Mapping owner address to token count
    private var balances = HashMap.HashMap<Principal,Nat>(1,Principal.equal,Principal.hash);

    // Mapping from token ID to approved address
    private var tokenApprovals = HashMap.HashMap<Principal, Principal>(1, Principal.equal, Principal.hash);
    
    // Mapping from owner to operator approvals
    private var operatorApprovals = HashMap.HashMap<Principal, HashMap.HashMap<Principal, Bool>>(1, Principal.equal, Principal.hash);

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
     * @notice Count all NFTs assigned to an owner
     * NFTs assigned to the zero address are considered invalid, 
     * and this function throws for queries about the zero address.
     * @param _owner An address for whom to query the balance
     * @return The number of NFTs owned by `_owner`, possibly zero
     */
    public query func balanceOf(who: Principal) : async Nat {
        switch (balances.get(who)) {
            case (?balance) {
                return balance;
            };
            case (_) {
                return 0 ;
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
    public  query func ownerOf (tokenId: Principal) : async Principal {
        assert(Utils._exists(ownered, tokenId));
        switch (ownered.get(tokenId)) {
            case (? owner) {
                return owner;
            };
            case _ {
                throw Error.reject("token has no owner") 
            };
        }
    };

    /*
     * @notice Change or reaffirm the approved address for an NFT
     * The zero address indicates there is no approved address.
     * Throws unless `msg.caller` is the current NFT owner, or an authorized operator of the current owner.
     * @param _approved The new approved NFT controller
     * @param _tokenId The NFT to approve
     */
    public shared(msg) func approve(spender: Principal, tokenId: Principal ) : async Bool {
        var owner: Principal = await ownerOf(tokenId);
        assert(Principal.equal(msg.caller, owner));
        assert(msg.caller != spender);
        assert(Utils._exists(ownered, tokenId));
        tokenApprovals.put(tokenId, spender);
        return true;
    };

    /*
     * @notice Get the approved address for a single NFT
     * throws if `_tokenId` is not a valid NFT.
     * @param _tokenId The NFT to find the approved address for
     * @return The approved address for this NFT, or the zero address if there is none
     */
    public query func getApproved (tokenId: Principal) : async Principal {
        assert(Utils._exists(ownered, tokenId));
        switch (tokenApprovals.get(tokenId)) {
            case (?approved) {
                return approved;
            };
            case _ {
                throw Error.reject("token has no approved") 
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
    public query func isApprovedForAll(owner: Principal, operator: Principal) : async Bool {
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
    public shared(msg) func transferFrom(from: Principal, to: Principal, tokenId: Principal) : async Bool {
        assert(await _isApprovedOrOwner(msg.caller, tokenId));
        return await _transfer(from, to , tokenId);
    };


    /**
     * Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     * Requirements:
     * - `tokenId` must exist.
     */
    public shared(msg) func _burn(tokenId : Principal) : async Bool {
        var owner: Principal = await ownerOf(tokenId);
        tokenApprovals.put(tokenId, Principal.fromText(""));
        switch(balances.get(owner)) {
            case (? owner_balance) {
                var owner_balcance_new = owner_balance - 1;
                balances.put(owner, owner_balcance_new);
                ownered.put(tokenId, Principal.fromText(""));
                return true;
            };
            case (_) {
                return false;
            };
        }
    };

    /**
     * Mints `tokenId` and transfers it to `to`.
     * Requirements:
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     */
    public shared(msg) func _mint (to: Principal, tokenId: Principal) : async Bool {
        assert( Utils._exists(ownered, tokenId) == false);
        var owner: Principal = await ownerOf(tokenId);
        switch(balances.get(to)) {
            case (? to_balance) {
                var to_balcance_new = to_balance + 1;
                balances.put(owner, to_balcance_new);
                ownered.put(tokenId, to);
                return true;
            };
            case (_) {
                return false;
            };
        }
    };

    /*
     * Returns whether `tokenId` exists.
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    private func _exists(tokenId: Principal) : async Bool {
        switch (ownered.get(tokenId)) {
            case (? owner) {
                return true;
            };
            case (_) {
                return false;
            };
        }
    };

    /**
     * Returns whether `spender` is allowed to manage `tokenId`.
     * Requirements:
     * - `tokenId` must exist.
     */
    public shared(msg) func _isApprovedOrOwner(spender: Principal, tokenId: Principal) : async Bool {
        assert(Utils._exists(ownered, tokenId) == false);
        var owner: Principal = await  ownerOf(tokenId);
        var approved : Principal = await getApproved(tokenId);
        var isApprovedForAllBool : Bool = await isApprovedForAll(owner,spender);
        var isApprovedOrOwner: Bool =  (spender == owner or spender == approved  or isApprovedForAllBool);
        return isApprovedOrOwner;
    };

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.caller.
     *
     * Requirements:
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     */
    public shared(msg) func _transfer(from: Principal, to: Principal, tokenId: Principal) : async Bool {
        var owner: Principal = await  ownerOf(tokenId);
        assert(owner == from);
        tokenApprovals.put(tokenId, Principal.fromText(""));
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

    //TODO 
    public query func tokenURI(tokenId: Principal) : async Text {
        return "";
    };

    public shared(msg) func callerPrincipal() : async Principal {
        return msg.caller;
    };
};

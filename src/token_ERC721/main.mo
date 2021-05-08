import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Error "mo:base/Error";
import Option "mo:base/Option";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Text "mo:base/Text";
import List "mo:base/List";

/**
 *  Implementation of https://github.com/icplabs/DIPs/blob/main/DIPS/dip-721.md Non-Fungible Token Standard.
 */
shared(msg) actor class Token_ERC721(_name: Text, _symbol: Text, admin: Principal) = this {

    // Token name
    private stable var name_ : Text = _name;

    // Token symbol
    private stable var symbol_ : Text = _symbol;

    // token admins
    private var admins = HashMap.HashMap<Principal, Bool>(1, Principal.equal, Principal.hash);

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

    // Mapping from owner to token list
    // private var ownedTokens = HashMap.HashMap<Principal, [var Nat]>(1, Principal.equal, Principal.hash);
    private var ownedTokens = HashMap.HashMap<Principal, List.List<Nat>>(1, Principal.equal, Principal.hash);
    
    private var ownedTokensIndex = HashMap.HashMap<Nat, Nat>(1, Nat.equal, Hash.hash);

    private var allTokens : List.List<Nat> = List.nil<Nat>();

    private var allTokensIndex = HashMap.HashMap<Nat, Nat>(1, Nat.equal, Hash.hash);

    admins.put(admin, true);

    // private query function

    /**
     * @dev Returns whether the specified token exists
     * @param tokenId uint256 ID of the token to query the existence of
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

    private func _ownerOf(tokenId: Nat) : ?Principal {
        return ownered.get(tokenId);
    };

    private func _balanceOf(who: Principal) : ?Nat {
        return balances.get(who);
    };

    /**
     * Returns whether `spender` is allowed to manage `tokenId`.
     * Requirements:
     * - `tokenId` must exist.
     */
    private func _isApprovedOrOwner(spender: Principal, tokenId: Nat) : Bool {
        let owner_or = _ownerOf(tokenId);
        let appr_or = _getApproved(tokenId);
        return ((owner_or != null and Option.unwrap(owner_or) == spender) 
            or (appr_or != null and Option.unwrap(appr_or) == spender) 
            or (owner_or != null and _isApprovedForAll(Option.unwrap(owner_or), spender)));
    };    

    /*
     * @notice Get the approved address for a single NFT
     * @param _tokenId The NFT to find the approved address for
     * @return The approved address for this NFT, or null if there is none
     */
    private func _getApproved(tokenId: Nat) : ?Principal {
        switch (tokenApprovals.get(tokenId)) {
            case (?approver) {
                return ?approver;
            };
            case (_) {
                return null;
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

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call                 <<< solidity - func call use
     * @return bool whether the call correctly returned the expected magic value
     */
    private func _checkOnERC721Received(from: Principal, to: Principal, tokenId: Nat) : Bool {
        return true;
    };


    private func _checkAndCallSafeTransfer(from: Principal, to: Principal, tokenId: Nat, _data: Text) : Bool {
        return true;
    };  

    // private modify function

    /**
     * @dev Internal function to add a token ID to the list of a given address
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    private func _addTokenTo(to: Principal, tokenId: Nat) {
        assert(_exists(tokenId) == false);
        switch(balances.get(to), ownedTokens.get(to)) {
            case (?to_balance, ?tokenList) {
                // 1. update ownered 
                ownered.put(tokenId, to);                
                // 2. update balances
                let to_balance_new = to_balance + 1;
                assert(to_balance_new > to_balance);
                balances.put(to, to_balance_new);
                // 3. update ownedTokens of to
                let length = List.size<Nat>(tokenList);
                let tokenIdOfList = List.make<Nat>(tokenId);
                let tokenList_new = List.append<Nat>(tokenList, tokenIdOfList); // 可能会性能低下，但是用 push，index 会乱
                ownedTokens.put(to, tokenList_new);
                // 4. update ownedTokensIndex
                ownedTokensIndex.put(tokenId, length);
            };
            case (_) {
                // 1. update ownered
                ownered.put(tokenId, to);
                // 2. update balances
                let to_balance_new = 1;
                balances.put(to, to_balance_new);
                // 3. update ownedTokens of to
                let new = List.make<Nat>(tokenId);
                ownedTokens.put(to, new);
                // 4. update ownedTokensIndex
                ownedTokensIndex.put(tokenId, 1);
            };
        }
    };    

    /**
    * @dev private function to mint a new token
    * Reverts if the given token ID already exists
    * @param to The address that will own the minted token
    * @param tokenId Nat ID of the token to be minted by the msg.sender
    */
    private func _mint(to: Principal, tokenId: Nat) {
        _addTokenTo(to, tokenId);
        allTokensIndex.put(tokenId, List.size<Nat>(allTokens));
        let new = List.make<Nat>(tokenId);
        let allTokens_new = List.append(allTokens, new);
        allTokens := allTokens_new;
    };    

    /**
    * @dev Internal function to burn a specific token
    * Reverts if the token does not exist
    * @param tokenId uint256 ID of the token being burned by the msg.sender
    */
    private func _burn(owner: Principal, tokenId: Nat) {
        _clearApproval(owner, tokenId);
        _removeTokenFrom(owner, tokenId);
        tokenURIs_.delete(tokenId);

        let tokenIndex = switch (allTokensIndex.get(tokenId)) {
            case (?index) {
                index;
            };
            case (_) {
                assert(false);
                0; // just for compiled
            };
        };
        let length = List.size<Nat>(allTokens);
        let lastTokenId = switch (List.last<Nat>(allTokens)) {
            case (?_tokenId) {
                _tokenId;
            };
            case (_) {
                assert(false);
                0;
            };
        };
        let changeToken = func(x: Nat) : Nat {
            if (x == tokenId) {
                return lastTokenId;
            } else {
                return x;
            };
        };
        let tokenList_1 = List.map<Nat, Nat>(allTokens, changeToken);
        let tokenList_2 = List.take<Nat>(tokenList_1, length - 1);
        allTokens := tokenList_2;

        allTokensIndex.delete(tokenId);
        allTokensIndex.put(lastTokenId, tokenIndex);
    };

    private func _clearApproval(owner: Principal, tokenId: Nat) {
        assert(_ownerOf(tokenId) != null and Option.unwrap<Principal>(_ownerOf(tokenId)) == owner);
        switch (tokenApprovals.get(tokenId)) {
            case (?operator) {
                tokenApprovals.delete(tokenId);
            };
            case (_) {
                ();
            }
        }
    };

    /**
     * @dev Internal function to remove a token ID from the list of a given address
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    private func _removeTokenFrom(owner: Principal, tokenId: Nat) {
        assert(_ownerOf(tokenId) != null and Option.unwrap<Principal>(_ownerOf(tokenId)) == owner);
        switch(balances.get(owner), ownedTokens.get(owner)) {
            case (?owner_balance, ?tokenList ) {
                // 1. update balances
                let owner_balcance_new = owner_balance - 1;
                assert(owner_balcance_new < owner_balance);
                balances.put(owner, owner_balcance_new);
                // 2. update ownered
                ownered.delete(tokenId);
                // 3. update ownedTokens of owner
                /*
                // 这样更新的话，tokenList 后面所有的 Index 全部要减 1
                let isBurnToken = func (x : Nat) : Bool {Nat.notEqual(x, tokenId)};
                let tokenList_new  = List.filter<Nat>(tokenList, isBurnToken);
                ownedTokens.put(owner, tokenList_new);
                */
                let length = List.size<Nat>(tokenList);
                let tokenIndex = switch (ownedTokensIndex.get(tokenId)) {
                    case (?index) {
                        index;
                    };
                    case (_) {
                        assert(false);
                        0;
                    };
                };
                let lastTokenId = switch (List.last<Nat>(tokenList)) {
                    case (?_tokenId) {
                        _tokenId;
                    };
                    case (_) {
                        assert(false);
                        0;
                    };
                };

                let changeToken = func(x: Nat) : Nat {
                    if (x == tokenId) {
                        lastTokenId;
                    } else {
                        x;
                    };
                };
                let tokenList_1 = List.map<Nat, Nat>(tokenList, changeToken);
                let tokenList_2 = List.take<Nat>(tokenList_1, length - 1);
                ownedTokens.put(owner, tokenList_2);
                // 4. update ownedTokensIndex
                ownedTokensIndex.delete(tokenId);
                ownedTokensIndex.put(lastTokenId, tokenIndex);
            };
            case (_) {
                assert(false);
            };
        }
    };

    //set Token URI
    private func _setTokenURI(tokenId : Nat, uri: Text) {
        assert(_exists(tokenId));
        tokenURIs_.put(tokenId, uri)
    };

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.caller.
     *
     * Requirements:
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     */
    private func _transferFrom(caller: Principal, from: Principal, to: Principal, tokenId: Nat) :  Bool {
        assert(_isApprovedOrOwner(caller, tokenId));
        _clearApproval(from, tokenId);
        _removeTokenFrom(from, tokenId);
        _addTokenTo(to, tokenId);
        return true;
    };    

    private func _safeTransferFrom(caller: Principal, from: Principal, to: Principal, tokenId: Nat, data: Text) :  Bool {
        assert(_transferFrom(caller, from, to , tokenId));
        assert(_checkAndCallSafeTransfer(from, to, tokenId, data));
        return true;
    };
    

    // public query function 

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

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    public query func tokenURI(tokenId: Nat) : async Text {
        switch(tokenURIs_.get(tokenId)){
            case(?uri){
                uri;
            };
            case(_){
                "ERC721Metadata: URI query for nonexistent token";
            };
        };
    };

    /*
     * @notice Find the owner of an NFT
     * NFTs assigned to the zero address are considered invalid, 
     * and queries about them do throw.
     * @param _tokenId The identifier for an NFT
     * @return The address of the owner of the NFT
     */
     public query func ownerOf(tokenId: Nat) : async Principal {
        switch (_ownerOf(tokenId)) {
            case (? owner) {
                return owner;
            };
            case _ {
                throw Error.reject("token does not exist, can't get owner")
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
    public query func balanceOf(who: Principal) : async Nat {
        switch (_balanceOf(who)) {
            case (? balance) {
                return balance;
            };
            case _ {
                throw Error.reject("Failed to query balance")
            };
        }
    };

    /**
     * @dev Gets the approved address for a token ID, or zero if no address set
     * Reverts if the token ID does not exist.
     * @param tokenId uint256 ID of the token to query the approval of
     * @return address currently approved for the given token ID
     */    
    public query func getApproved(tokenId: Nat) : async Principal {
        switch (_exists(tokenId)) {
            case true {
                switch (_getApproved(tokenId)) {
                    case (?who) {
                        return who;
                    };
                    case (_) {
                        throw Error.reject("Failed to get approved")
                    };
                }                
            };
            case (_) {
                throw Error.reject("token don't exists")
            };
        }
    };

    public query func isApprovedForAll(owner: Principal, operator: Principal) : async Bool {
        return _isApprovedForAll(owner, operator);
    };

    public query func tokenOfOwnerByIndex(owner: Principal, index: Nat) : async Nat {
        let balance = switch (_balanceOf(owner)) {
            case (?amount) {
                amount;
            };
            case (_) {
                throw Error.reject("owner have no balance")
            };
        };
        assert(index < balance);
        let temp = switch (ownedTokens.get(owner)) {
            case (?tokenList) {
                switch (List.get<Nat>(tokenList, index)) {
                    case (?tokenId) {
                        tokenId
                    };
                    case (_) {
                        throw Error.reject("index don't exist in Owned List")
                    };
                }
            };
            case (_) {
                throw Error.reject("owner don't have the token list")
            };
        };
        return temp;
    };

    public query func totalSupply() : async Nat {
        return List.size<Nat>(allTokens);
    };

    public query func tokenByIndex(index: Nat) : async Nat {
        assert(index < List.size<Nat>(allTokens));
        let temp = switch (List.get<Nat>(allTokens, index)) {
            case (?tokenId) {
                tokenId
            };
            case (_) {
                throw Error.reject("index don't exist in allTokens")
            };
        };
        return temp;
    };

    public query func getAllTokens() : async [Nat] {
        let tokens = List.toArray<Nat>(allTokens);
        return tokens;
    };

    public query func getTokenList(owner: Principal) : async [Nat] {
        let tokenList = switch (ownedTokens.get(owner)) {
            case (?list) {
                list;
            };
            case (_) {
                throw Error.reject("can't get the principal's ownedTokens");
            };
        };
        let tokens = List.toArray<Nat>(tokenList);
        return tokens;
    };

    public query func isAdmin(who: Principal) : async Bool {
        switch (admins.get(who)) {
            case (?res) {
                return res;                
            };
            case (_) {
                return false;
            };
        }
    };


    // public modify function 

    /*
     * @notice Change or reaffirm the approved address for an NFT
     * The zero address indicates there is no approved address.
     * Throws unless `msg.caller` is the current NFT owner, or an authorized operator of the current owner.
     * @param spender The new approved NFT controller
     * @param tokenId The NFT to approve
     */
    public shared(msg) func approve(spender: Principal, tokenId: Nat) : async Bool {
        var owner: Principal = switch (_ownerOf(tokenId)) {
            case (?own) {
                own;
            };
            case (_) {
                throw Error.reject("token does not exist")
            }
        };
        assert(Principal.equal(msg.caller, owner) or _isApprovedForAll(owner, msg.caller));
        assert(owner != spender);
        tokenApprovals.put(tokenId, spender);
        return true;
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
        return  _transferFrom(msg.caller, from, to, tokenId);
    };

    public shared(msg) func safeTransferFrom(from: Principal, to: Principal, tokenId: Nat) : async Bool {
        return _safeTransferFrom(msg.caller, from, to, tokenId, "");
    };

    public shared(msg) func safeTransferFromWithData(from: Principal, to: Principal, tokenId: Nat, data: Text) : async Bool {
        return  _safeTransferFrom(msg.caller, from, to, tokenId, data);
    };

    public shared(msg) func setTokenURI(tokenId: Nat, uri: Text) : async Bool {
        assert(Option.unwrap(_ownerOf(tokenId)) == msg.caller);
        _setTokenURI(tokenId, uri);
        return true;
    };

    public shared(msg) func mint(to: Principal, tokenId: Nat) : async Bool {
        assert(Option.unwrap(admins.get(msg.caller)));
        assert(not _exists(tokenId));
        _mint(to, tokenId);
        return true;
    };

    public shared(msg) func burn(tokenId: Nat) : async Bool {
        assert(Option.unwrap(admins.get(msg.caller)));
        assert(_exists(tokenId));
        let to = switch (_ownerOf(tokenId)) {
            case (?owner) {
                owner;
            };
            case (_) {
                throw Error.reject("can't get the token owner");
            }
        };
        _burn(to, tokenId);
        return true;
    };

    public shared(msg) func withdraw(tokenId: Nat, to: Principal) : async Bool {
        assert(_exists(tokenId));
        assert(Option.unwrap(admins.get(msg.caller)));
        let owner = Principal.fromActor(this);
        assert(Option.unwrap(_ownerOf(tokenId)) == owner);
        _clearApproval(owner, tokenId);
        _removeTokenFrom(owner, tokenId);
        _addTokenTo(to, tokenId);
        return true;
    };

    public shared(msg) func setAdmin(who: Principal, isOr: Bool) : async Bool {
        assert(Option.unwrap(admins.get(msg.caller)));
        admins.put(who, isOr);
        return true;
    };
};

import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Error "mo:base/Error";
import Option "mo:base/Option";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Text "mo:base/Text";
import List "mo:base/List";
import Time "mo:base/Time";
import TrieSet "mo:base/TrieSet";
import Array "mo:base/Array";
import Debug "mo:base/Debug";
import Result "mo:base/Result";


shared(msg) actor class NFToken(
    _name: Text, 
    _symbol: Text, 
    _owner: Principal
    ) = this {

    type TokenInfo = {
        index: Nat;
        var owner: Principal;
        var url: Text;
        var name: Text;
        var desc: Text;
        timestamp: Time.Time;
    };

    type TokenInfoExt = {
        index: Nat;
        owner: Principal;
        url: Text;
        name: Text;
        desc: Text;
        timestamp: Time.Time;
    };

    private stable var name_ : Text = _name;
    private stable var symbol_ : Text = _symbol;
    private stable var owner_: Principal = _owner;
    private stable var totalSupply: Nat = 0;
    private stable var blackhole: Principal = Principal.fromText("aaaaa-aa");

    private var tokens = HashMap.HashMap<Nat, TokenInfo>(1, Nat.equal, Hash.hash);
    private var tokenApprovals = HashMap.HashMap<Nat, Principal>(1, Nat.equal, Hash.hash);
    private var operatorApprovals = HashMap.HashMap<Principal, HashMap.HashMap<Principal, Bool>>(1, Principal.equal, Principal.hash);
    private var ownedTokens = HashMap.HashMap<Principal, List.List<Nat>>(1, Principal.equal, Principal.hash);


    private func _exists(tokenId: Nat) : Bool {
        switch (tokens.get(tokenId)) {
            case (?info) {
                return true;
            };
            case (_) {
                return false;
            };
        }
    };

    private func _ownerOf(tokenId: Nat) : ?Principal {
        switch (tokens.get(tokenId)) {
            case (?info) {
                return ?info.owner;
            };
            case (_) {
                return null;
            };
        }
    };

    private func _balanceOf(who: Principal) : Nat {
        switch (ownedTokens.get(who)) {
            case (?tokens) {
                return tokens.size();
            };
            case (_) {
                return 0;
            };
        }
    };

    private func _tokenInfotoExt(info: TokenInfo) : TokenInfoExt {
        return {
            index = info.index;
            owner = info.owner;
            url = info.url;
            name = info.name;
            desc = info.desc;
            timestamp = info.timestamp;
        };
    };

    private func _isApprovedOrOwner(spender: Principal, tokenId: Nat) : Bool {
        let owner_or = _ownerOf(tokenId);
        let appr_or = _getApproved(tokenId);
        return ((owner_or != null and Option.unwrap(owner_or) == spender) 
            or (appr_or != null and Option.unwrap(appr_or) == spender) 
            or (owner_or != null and _isApprovedForAll(Option.unwrap(owner_or), spender)));
    };

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

    private func _addTokenTo(to: Principal, tokenId: Nat) {
        switch(ownedTokens.get(to)) {
            case (?tokenList) {
                let length = List.size<Nat>(tokenList);
                let tokenIdOfList = List.make<Nat>(tokenId);
                let tokenList_new = List.append<Nat>(tokenList, tokenIdOfList);
                ownedTokens.put(to, tokenList_new);
            };
            case (_) {
                let new = List.make<Nat>(tokenId);
                ownedTokens.put(to, new);
            };
        }
    }; 

    private func _removeTokenFrom(owner: Principal, tokenId: Nat) {
        assert(_ownerOf(tokenId) != null and Option.unwrap(_ownerOf(tokenId)) == owner);
        switch(ownedTokens.get(owner)) {
            case (?tokenList) {
                // just remove tokenId from owner's list, TODO: simplify this
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
            };
            case (_) {
                assert(false);
            };
        }
    };

    private func _transfer(to: Principal, tokenId: Nat) {
        assert(_exists(tokenId) == true);
        switch(tokens.get(tokenId)) {
            case (?info) {
                _removeTokenFrom(info.owner, tokenId);
                _addTokenTo(to, tokenId);
                info.owner := to;
                tokens.put(tokenId, info);
            };
            case (_) {
                assert(false);
            };
        };
    };

    private func _clearApproval(owner: Principal, tokenId: Nat) {
        assert(_ownerOf(tokenId) != null and Option.unwrap(_ownerOf(tokenId)) == owner);
        switch (tokenApprovals.get(tokenId)) {
            case (?operator) {
                tokenApprovals.delete(tokenId);
            };
            case (_) {
                ();
            }
        }
    };  

    private func _burn(owner: Principal, tokenId: Nat) {
        _clearApproval(owner, tokenId);
        _transfer(blackhole, tokenId);
    };

    private func _mint(to: Principal, url: Text, name: Text, desc: Text) {
        assert(_exists(tokenId) == false);
        let token: TokenInfo = {
            index = totalSupply;
            owner = to;
            url = url;
            name = name;
            desc = desc;
            timestamp = Time.now();
        };
        tokens.put(totalSupply, token);
        _addTokenTo(to, totalSupply);
        totalSupply += 1;
    };

    private func _updateTokenInfo(info: TokenInfo) {
        assert(_exists(info.index));
        let token = Option.unwrap(tokens.get(tokenId));
        token.owner := owner;
        token.url := url;
        token.name := name;
        token.desc := desc;
        tokens.put(info.index, token);
    };

    private func _transferFrom(caller: Principal, from: Principal, to: Principal, tokenId: Nat) :  Bool {
        assert(_isApprovedOrOwner(caller, tokenId));
        _clearApproval(from, tokenId);
        _transfer(to, tokenId);
        return true;
    };    

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

    public shared(msg) func transferFrom(from: Principal, to: Principal, tokenId: Nat) : async Bool {
        return  _transferFrom(msg.caller, from, to, tokenId);
    };

    public shared(msg) func setTokenInfo(info: TokenInfo) : async Bool {
        assert(Option.unwrap(_ownerOf(info.index)) == msg.caller);
        _updateTokenInfo(info);
        return true;
    };

    // public query function 
    public query func name() : async Text {
        return name_;
    };

    public query func symbol() : async Text {
        return symbol_;
    };

    public query func getTokenInfo(tokenId: Nat) : async TokenInfoExt {
        switch(tokenInfos_.get(tokenId)){
            case(?tokeninfo){
                return _tokenInfotoExt(tokeninfo);
            };
            case(_){
                throw Error.reject("ERC721Metadata: info query for nonexistent token");
            };
        };
    };

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

    public query func balanceOf(who: Principal) : async Nat {
        switch (_balanceOf(who)) {
            case (? balance) {
                return balance;
            };
            case _ {
                return 0;
            };
        }
    };
 
    public query func getApproved(tokenId: Nat) : async Principal {
        switch (_exists(tokenId)) {
            case true {
                switch (_getApproved(tokenId)) {
                    case (?who) {
                        return who;
                    };
                    case (_) {
                        return Principal.fromText("aaaaa-aa");
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
        return totalSupply;
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
};

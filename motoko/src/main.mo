import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Error "mo:base/Error";
import Option "mo:base/Option";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Hash "mo:base/Hash";
import Text "mo:base/Text";
import List "mo:base/List";
import Time "mo:base/Time";
import Iter "mo:base/Iter";
import TrieSet "mo:base/TrieSet";
import Array "mo:base/Array";
import Debug "mo:base/Debug";
import Prelude "mo:base/Prelude";

shared(msg) actor class NFToken(
    _name: Text, 
    _symbol: Text, 
    _desc: Text,
    _owner: Principal
    ) = this {

	type TxRecord = {
		index: Nat;
		tokenIndex: Nat;
		from: Nat;
		to: Nat;
		timestamp: Int;
	};

    type Metadata = {
        name: Text;
        desc: Text;
        totalSupply: Nat;
        owner: Principal;
    };

	// e.g. IPFS => ipfshash; URL => https://xxx; ...
	type KV = {
		key: Text;
		value: Text;
	};
	type TokenMetadata = [KV];
    type TokenInfo = {
        index: Nat;
        var owner: Principal;
		var metadata: TokenMetadata;
        var approval: ?Principal;
        timestamp: Time.Time;
    };

    type TokenInfoExt = {
        index: Nat;
        owner: Principal;
        metadata: TokenMetadata;
        approval: ?Principal;
        timestamp: Time.Time;
    };

    type UserInfo = {
        var allows: TrieSet.Set<Principal>;         // principals allowed to operate on owner's behalf
        var allowedBy: TrieSet.Set<Principal>;      // principals approved owner
        var allowedIds: TrieSet.Set<Nat>;           // tokens controlled by owner
        var tokens: TrieSet.Set<Nat>;               // owner's tokens
    };

    type UserInfoExt = {
        allows: [Principal];
        allowedBy: [Principal];
        allowedIds: [Nat];
        tokens: [Nat];
    };

    private stable var name_ : Text = _name;
    private stable var symbol_ : Text = _symbol;
    private stable var desc_ : Text = _desc;
    private stable var owner_: Principal = _owner;
    private stable var totalSupply_: Nat = 0;
    private stable var blackhole: Principal = Principal.fromText("aaaaa-aa");

    private stable var txIndex: Nat = 0;
    private stable var txs: [TxRecord] = [];
    private stable var userTxs = HashMap.HashMap<Principal, [Nat]>(1, Principal.equal, Principal.hash);
    private var tokens = HashMap.HashMap<Nat, TokenInfo>(1, Nat.equal, Hash.hash);
    private var users = HashMap.HashMap<Principal, UserInfo>(1, Principal.equal, Principal.hash);

    private func _unwrap<T>(x : ?T) : T =
    switch x {
      case null { Prelude.unreachable() };
      case (?x_) { x_ };
    };
    
    private func _exists(tokenId: Nat) : Bool {
        switch (tokens.get(tokenId)) {
            case (?info) { return true; };
            case _ { return false; };
        }
    };

    private func _ownerOf(tokenId: Nat) : ?Principal {
        switch (tokens.get(tokenId)) {
            case (?info) { return ?info.owner; };
            case (_) { return null; };
        }
    };

    private func _isOwner(who: Principal, tokenId: Nat) : Bool {
        switch (tokens.get(tokenId)) {
            case (?info) { return info.owner == who; };
            case _ { return false; };
        };
    };

    private func _isApprover(who: Principal, tokenId: Nat) : Bool {
        switch (tokens.get(tokenId)) {
            case (?info) { return info.approval == ?who; };
            case _ { return false; };
        }
    };
    
    private func _balanceOf(who: Principal) : Nat {
        switch (users.get(who)) {
            case (?user) { return TrieSet.size(user.tokens); };
            case (_) { return 0; };
        }
    };

    private func _newUser() : UserInfo {
        {
            var allows = TrieSet.empty<Principal>();
            var allowedBy = TrieSet.empty<Principal>();
            var allowedIds = TrieSet.empty<Nat>();
            var tokens = TrieSet.empty<Nat>();
        }
    };

    private func _tokenInfotoExt(info: TokenInfo) : TokenInfoExt {
        return {
            index = info.index;
            owner = info.owner;
            metadata = info.metadata;
            timestamp = info.timestamp;
            approval = info.approval;
        };
    };

    private func _userInfotoExt(info: UserInfo) : UserInfoExt {
        return {
            allows = TrieSet.toArray(info.allows);
            allowedBy = TrieSet.toArray(info.allowedBy);
            allowedIds = TrieSet.toArray(info.allowedIds);
            tokens = TrieSet.toArray(info.tokens);
        };
    };

    private func _isApprovedOrOwner(spender: Principal, tokenId: Nat) : Bool {
        switch (_ownerOf(tokenId)) {
            case (?owner) {
                return spender == owner or _isApprover(spender, tokenId) or _isApprovedForAll(owner, spender);
            };
            case _ {
                return false;
            };
        };        
    };

    private func _getApproved(tokenId: Nat) : ?Principal {
        switch (tokens.get(tokenId)) {
            case (?info) {
                return info.approval;
            };
            case (_) {
                return null;
            };
        }
    };

    private func _isApprovedForAll(owner: Principal, operator: Principal) : Bool {
        switch (users.get(owner)) {
            case (?user) {
                return TrieSet.mem(user.allows, operator, Principal.hash(operator), Principal.equal);
            };
            case _ { return false; };
        };
    };

    private func _addTokenTo(to: Principal, tokenId: Nat) {
        switch(users.get(to)) {
            case (?user) {
                user.tokens := TrieSet.put(user.tokens, tokenId, Hash.hash(tokenId), Nat.equal);
                users.put(to, user);
            };
            case _ {
                let user = _newUser();
                user.tokens := TrieSet.put(user.tokens, tokenId, Hash.hash(tokenId), Nat.equal);
                users.put(to, user);
            };
        }
    }; 

    private func _removeTokenFrom(owner: Principal, tokenId: Nat) {
        assert(_exists(tokenId) and _isOwner(owner, tokenId));
        switch(users.get(owner)) {
            case (?user) {
                user.tokens := TrieSet.delete(user.tokens, tokenId, Hash.hash(tokenId), Nat.equal);
                users.put(owner, user);
            };
            case _ {
                assert(false);
            };
        }
    };

    private func _clearApproval(owner: Principal, tokenId: Nat) {
        assert(_exists(tokenId) and _isOwner(owner, tokenId));
        switch (tokens.get(tokenId)) {
            case (?info) {
                if (info.approval != null) {
                    let approver = _unwrap(info.approval);
                    let approverInfo = _unwrap(users.get(approver));
                    approverInfo.allowedIds := TrieSet.delete(approverInfo.allowedIds, tokenId, Hash.hash(tokenId), Nat.equal);
                    users.put(approver, approverInfo);
                    info.approval := null;
                    tokens.put(tokenId, info);
                }
            };
            case _ {
                assert(false);
            };
        }
    };  

    private func _transfer(to: Principal, tokenId: Nat) {
        assert(_exists(tokenId));
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

    private func _burn(owner: Principal, tokenId: Nat) {
        _clearApproval(owner, tokenId);
        _transfer(blackhole, tokenId);
    };

    private func _mint(to: Principal, metadata: TokenMetadata) {
        let token: TokenInfo = {
            index = totalSupply_;
            var owner = to;
            var metadata = metadata;
            timestamp = Time.now();
            var approval = null;
        };
        tokens.put(totalSupply_, token);
        _addTokenTo(to, totalSupply_);
        totalSupply_ += 1;
    };

    private func _updateTokenInfo(info: TokenInfoExt) {
        assert(_exists(info.index));
        let token = _unwrap(tokens.get(info.index));
        token.metadata := info.metadata;
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
                throw Error.reject("token not exist")
            }
        };
        assert(Principal.equal(msg.caller, owner) or _isApprovedForAll(owner, msg.caller));
        assert(owner != spender);
        switch (tokens.get(tokenId)) {
            case (?info) {
                info.approval := ?spender;
                tokens.put(tokenId, info);
            };
            case _ {
                assert(false);
            };
        };
        switch (users.get(spender)) {
            case (?user) {
                user.allowedIds := TrieSet.put(user.allowedIds, tokenId, Hash.hash(tokenId), Nat.equal);
                users.put(spender, user);
            };
            case _ {
                let user = _newUser();
                user.allowedIds := TrieSet.put(user.allowedIds, tokenId, Hash.hash(tokenId), Nat.equal);
                users.put(spender, user);
            };
        };
        return true;
    };

    public shared(msg) func setApprovalForAll(operator: Principal, approved: Bool) : async Bool {
        assert(msg.caller != operator);
        if approved {
            let caller = switch (users.get(msg.caller)) {
                case (?user) { user };
                case _ { _newUser() };
            };
            caller.allows := TrieSet.put(caller.allows, operator, Principal.hash(operator), Principal.equal);
            users.put(msg.caller, caller);
            let user = switch (users.get(operator)) {
                case (?user) { user };
                case _ { _newUser() };
            };
            user.allowedBy := TrieSet.put(user.allowedBy, msg.caller, Principal.hash(msg.caller), Principal.equal);
            users.put(operator, user);
        } else {
            switch (users.get(msg.caller)) {
                case (?user) {
                    user.allows := TrieSet.delete(user.allows, operator, Principal.hash(operator), Principal.equal);    
                    users.put(msg.caller, user);
                };
                case _ { };
            };
            switch (users.get(operator)) {
                case (?user) {
                    user.allowedBy := TrieSet.delete(user.allowedBy, msg.caller, Principal.hash(msg.caller), Principal.equal);    
                    users.put(operator, user);
                };
                case _ { };
            };
        };
        return true;
    };

    public shared(msg) func transferFrom(from: Principal, to: Principal, tokenId: Nat) : async Bool {
        return  _transferFrom(msg.caller, from, to, tokenId);
    };

    public shared(msg) func setTokenInfo(info: TokenInfoExt) : async Bool {
        assert(_isOwner(msg.caller, info.index));
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
        switch(tokens.get(tokenId)){
            case(?tokeninfo) {
                return _tokenInfotoExt(tokeninfo);
            };
            case(_) {
                throw Error.reject("token not exist");
            };
        };
    };

    public query func ownerOf(tokenId: Nat) : async Principal {
        switch (_ownerOf(tokenId)) {
            case (? owner) {
                return owner;
            };
            case _ {
                throw Error.reject("token not exist")
            };
        }
    };

    public query func balanceOf(who: Principal) : async Nat {
        return _balanceOf(who);
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
                throw Error.reject("token not exist")
            };
        }
    };

    public query func isApprovedForAll(owner: Principal, operator: Principal) : async Bool {
        return _isApprovedForAll(owner, operator);
    };

    public query func tokenOfOwnerByIndex(owner: Principal, index: Nat) : async Nat {
        let balance = _balanceOf(owner);
        assert(index < balance);
        switch (users.get(owner)) {
            case (?userInfo) {
                return TrieSet.toArray(userInfo.tokens)[index];
            };
            case _ {
                throw Error.reject("unauthorized")
            };
        };
    };

    public query func totalSupply() : async Nat {
        return totalSupply_;
    };

    public query func tokenByIndex(index: Nat) : async Nat {
        assert(index < tokens.size());
        let tokenIds = Iter.toArray(Iter.map(tokens.entries(), func (i: (Nat, TokenInfo)): Nat {i.0}));
        return tokenIds[index];
    };

    public query func getAllTokens() : async [Nat] {
        Iter.toArray(Iter.map(tokens.entries(), func (i: (Nat, TokenInfo)): Nat {i.0}))
    };

    public query func getTokenList(owner: Principal) : async [Nat] {
        switch (users.get(owner)) {
            case (?user) {
                return TrieSet.toArray(user.tokens);
            };
            case _ {
                throw Error.reject("unauthorized");
            };
        };
    };

    public query func getUser(who: Principal) : async UserInfoExt {
        switch (users.get(who)) {
            case (?user) {
                return _userInfotoExt(user)
            };
            case _ {
                throw Error.reject("unauthorized");
            };
        };        
    };

    public query func getMetadata(): async Metadata {
        {
            name = name_;
            desc = desc_;
            totalSupply = totalSupply_;
            owner = owner_;
        }
    };

	public query func historySize(): async Nat {
        return txIndex;
	};

	public query func getTransactions(start: Nat, limit: Nat): async [TxRecord] {

	};

	public query func getTransaction(index: Nat): async TxRecord {

	};

	public query func getUserTransactionAmount(user: Principal): async Nat {

	};

	public query func getUserTransactions(user: Principal): async Nat {

	};
};

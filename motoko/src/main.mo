/**
 * Module     : main.mo
 * Copyright  : 2021 DFinance Team
 * License    : Apache 2.0 with LLVM Exception
 * Maintainer : DFinance Team <hello@dfinance.ai>
 * Stability  : Experimental
 */

import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Types "./types";
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
    _owner: Principal,
    _desc: Text
    ) = this {

    type Metadata = Types.Metadata;
    type TokenMetadata = Types.TokenMetadata;
    type KV = Types.KV;
    type OpRecord = Types.OpRecord;
    type Operation = Types.Operation;
    type TokenInfo = Types.TokenInfo;
    type TokenInfoExt = Types.TokenInfoExt;
    type UserInfo = Types.UserInfo;
    type UserInfoExt = Types.UserInfoExt;

    private stable var name_ : Text = _name;
    private stable var symbol_ : Text = _symbol;
    private stable var desc_ : Text = _desc;
    private stable var owner_: Principal = _owner;
    private stable var totalSupply_: Nat = 0;
    private stable var blackhole: Principal = Principal.fromText("aaaaa-aa");

    private stable var mintable_ : Bool = _mintable;
    private stable var burnable_ : Bool = _burnable;
    private stable var tokensEntries : [(Nat, TokenInfo)] = [];
    private stable var usersEntries : [(Principal, UserInfo)] = [];
    private var tokens = HashMap.HashMap<Nat, TokenInfo>(1, Nat.equal, Hash.hash);
    private var users = HashMap.HashMap<Principal, UserInfo>(1, Principal.equal, Principal.hash);
    private stable var ops: [OpRecord] = [];
    private stable var txIndex: Nat = 0;
    private stable var userTxs = HashMap.HashMap<Principal, [Nat]>(1, Principal.equal, Principal.hash);

    private func addRecord(
        caller: Principal, op: Operation, tokenIndex: ?Nat,
        from: Principal, to: Principal, timestamp: Time.Time
    ): Nat {
        let index = ops.size();
        let record: OpRecord = {
            caller = caller;
            op = op;
            index = index;
            tokenIndex = tokenIndex;
            from = from;
            to = to;
            timestamp = timestamp;
        };
        ops := Array.append(ops, [record]);
        return index;
    };

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
        return token.index;
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

    public shared(msg) func mint(to: Principal, tokenMetadata: TokenMetadata): async Nat{
        let tokenId = _mint(to, tokenMetadata);
        let txid = addRecord(msg.caller, #mint, ?tokenId, blackhole, to, Time.now());
        return tokenId;   
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
        var from: Principal = switch (_getApproved(tokenId)) {
            case (?f) {
                f;
            };
            case (_) {
                owner;
            }
        }; 
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
        let txid = addRecord(msg.caller, #approve, ?tokenId, from, spender, Time.now());
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
            let txid = addRecord(msg.caller, #approveAll, null, msg.caller, operator, Time.now());
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
        let txid = addRecord(msg.caller, #unapproveAll, null, msg.caller, operator, Time.now());
        return true;
    };

    public shared(msg) func transferFrom(from: Principal, to: Principal, tokenId: Nat) : async Bool {
        let txid = addRecord(msg.caller, #transfer, ?tokenId, from, to, Time.now());
        return  _transferFrom(msg.caller, from, to, tokenId);
    };

    public shared(msg) func setTokenInfo(info: TokenInfoExt) : async Bool {
        assert(_isOwner(msg.caller, info.index));
        _updateTokenInfo(info);
        return true;
    };

    // public query function 

    public query func getMetadata(): async Metadata {
        {
            name = name_;
            desc = desc_;
            totalSupply = totalSupply_;
            owner = owner_;
        }
    };
    
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

    public query func getAllTxs(): async [OpRecord] {
        return ops;
    };

    public query func historySize(): async Nat {
        return ops.size();
    };

    public query func getTransactions(start: Nat, num: Nat): async [OpRecord] {
        var res: [OpRecord] = [];
        var i = start;
        while (i < start + num and i < ops.size()) {
            res := Array.append(res, [ops[i]]);
            i += 1;
        };
        return res;
    };

    public query func getTransaction(index: Nat): async OpRecord {
        return ops[index];
    };

    public query func getUserTransactionAmount(user: Principal): async Nat {
        var res: Nat = 0;
        for (i in ops.vals()) {
            if (i.caller == user or i.from == user or i.to == user) {
                res += 1;
            };
        };
        return res;
    };

    public query func getUserTransactions(user: Principal): async [OpRecord] {
        var res: [OpRecord] = [];
        for (i in ops.vals()) {
            if (i.caller == user or i.from == user or i.to == user) {
                res := Array.append<OpRecord>(res, [i]);
            };
        };
        return res;
    };

    system func preupgrade() {
        usersEntries := Iter.toArray(users.entries());
        tokensEntries := Iter.toArray(tokens.entries());
    };

    system func postupgrade() {
        type TokenInfo = Types.TokenInfo;
        type UserInfo = Types.UserInfo;

        users := HashMap.fromIter<Principal, UserInfo>(usersEntries.vals(), 1, Principal.equal, Principal.hash);
        tokens := HashMap.fromIter<Nat, TokenInfo>(tokensEntries.vals(), 1, Nat.equal, Hash.hash);
        usersEntries := [];
        tokensEntries := [];
    };
};


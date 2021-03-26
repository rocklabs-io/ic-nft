import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Utils "./utils"; 
import Error "mo:base/Error";
import Option "mo:base/Option";

actor Token_ERC721{

    private stable var name_ : Text = "";
    private stable var symbol_ : Text = "";

    private var ownered = HashMap.HashMap<Principal, Principal>(1, Principal.equal, Principal.hash);
    private var balances = HashMap.HashMap<Principal,Nat>(1,Principal.equal,Principal.hash);

    // 允许用户转移指定token。
    private var tokenApprovals = HashMap.HashMap<Principal, Principal>(1, Principal.equal, Principal.hash);
    // 允许一个用户成为另一个用户的代理操作员，可以转移指定用户的所有token。
    private var operatorApprovals = HashMap.HashMap<Principal, HashMap.HashMap<Principal, Bool>>(1, Principal.equal, Principal.hash);


    // 名称
    public query func name() : async Text {
        return name_;
    };

    // 标识
    public query func symbol() : async Text {
        return symbol_;
    };

    // 余额
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


    // public query  func ownerOf(tokenId: Principal) : async ?Principal {
    //     assert(Utils._exists(ownered, tokenId));
    //     return ownered.get(tokenId);
    // };

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

    // 调用者允许指定账户转移指定tokenid的token
    public shared(msg) func approve(spender: Principal, tokenId: Principal ) : async Bool {
        var owner: Principal = await ownerOf(tokenId);
        assert(Principal.equal(msg.caller, owner));
        assert(msg.caller != spender);
        assert(Utils._exists(ownered, tokenId));
        tokenApprovals.put(tokenId, spender);
        return true;
    };

    // 获取指定token允许被哪个账户转移
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

    // 允许或者不允许“operator” 转移调用者的所有token。Bool是false的时候不允许。
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

    // 查询owner 是否允许 operator作为他的代理操作员。
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

    //转移代币transferFrom
    public shared(msg) func transferFrom(from: Principal, to: Principal, tokenId: Principal) : async Bool {
        assert(await _isApprovedOrOwner(msg.caller, tokenId));
        return await _transfer(from, to , tokenId);
    };

    // 销毁
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

    // mint  铸币
    public shared(msg) func _mint (to: Principal, tokenId: Principal) : async Bool {
        assert(Utils._exists(ownered, tokenId) == false);
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

    // 内部方法 判断tokenID 是否存在
    public query func _exists(tokenId: Principal) : async Bool {
        switch (ownered.get(tokenId)) {
            case (? owner) {
                return true;
            };
            case (_) {
                return false;
            };
        }
    };

    //内部方法 判断 spender 是否对 tokenID 有操作权
    //1. 是 tokenID 的主人。
    //2. 根据 tokenApprovals 判断 tokenID 允许spender操作。
    //3. 根据 operatorApprovals 判断 spender 是否是 tokenID 的主人的代理人。
    public shared(msg) func _isApprovedOrOwner(spender: Principal, tokenId: Principal) : async Bool {
        assert(Utils._exists(ownered, tokenId) == false);
        var owner: Principal = await  ownerOf(tokenId);
        var approved : Principal = await getApproved(tokenId);
        var isApprovedForAllBool : Bool = await isApprovedForAll(owner,spender);
        var isApprovedOrOwner: Bool =  (spender == owner or spender == approved  or isApprovedForAllBool);
        return isApprovedOrOwner;
    };

    //内部方法 转账
    public shared(msg) func _transfer(from: Principal, to: Principal, tokenId: Principal) : async Bool {
        var owner: Principal = await  ownerOf(tokenId);
        assert(owner == from);
        // 清除原来的owner赋予给其他人的权限。
        tokenApprovals.put(tokenId, Principal.fromText(""));
        // 余额变动 
        switch(balances.get(from), balances.get(to)) {
            case(?from_balance, ?to_balance) {
                var from_balance_new =  from_balance + 1;
                var to_balance_new = to_balance + 1;
                ownered.put(tokenId, to);
                return true;
            };
            case (_) {
                return false;
            };
        }
    };



    //TODO baseURI自定义  加密方法
    public query func tokenURI(tokenId: Principal) : async Text {
        return "";
    };

    //TODO safeTransfer

    //TODO safeMint

    //TODO tokenURI


    public shared(msg) func callerPrincipal() : async Principal {
        return msg.caller;
    };
};

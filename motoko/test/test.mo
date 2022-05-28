import Debug "mo:base/Debug";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Prelude "mo:base/Prelude";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Time "mo:base/Time";

import Types "../src//types";

actor class Testflow(token_ERC721_id : Principal, alice: Principal, bob: Principal) = this {

    type Metadata = Types.Metadata;
    type Location = Types.Location;
    type Attribute = Types.Attribute;
    type TokenMetadata = Types.TokenMetadata;
    type Record = Types.Record;
    type TxRecord = Types.TxRecord;
    type Operation = Types.Operation;
    type TokenInfo = Types.TokenInfo;
    type TokenInfoExt = Types.TokenInfoExt;
    type UserInfo = Types.UserInfo;
    type UserInfoExt = Types.UserInfoExt;

    public type Error = {
        #Unauthorized;
        #TokenNotExist;
        #InvalidOperator;
    };
    public type TxReceipt = Result.Result<Nat, Error>;
    public type MintResult = Result.Result<(Nat, Nat), Error>; // token index, txid
    public type Result<Ok, Err> = {#ok : Ok; #err : Err};

    public type NftActor = actor {
        mint: shared (to: Principal, metadata: TokenMetadata) -> async MintResult;
        burn: shared (tokenId: Nat) -> async MintResult;
        setTokenMetadata: shared (tokenId: Nat, new_metadata: TokenMetadata) -> async TxReceipt;
        approve: shared (tokenId: Nat, operator: Principal) -> async TxReceipt;
        setApprovalForAll: shared (operator: Principal, value: Bool) -> async TxReceipt;
        transfer: shared (to: Principal, tokenId: Nat) -> async TxReceipt;
        transferFrom: shared (from: Principal, to: Principal, tokenId: Nat) -> async TxReceipt;

        // query functions
        logo:   query () -> async Text;
        name:   query () -> async Text;
        symbol: query () -> async Text;
        desc:   query () -> async Text;

        balanceOf:    query (who: Principal) -> async Nat;
        totalSupply:  query ()  -> async Nat;
        getMetadata:  query ()  -> async Metadata;
        isApprovedForAll: query (owner: Principal, operator: Principal) -> async Bool;
        getOperator:  query (tokenId: Nat)   -> async Result<Principal, Error>;
        getUserInfo:  query (who: Principal) -> async Result<UserInfoExt, Error>;
        getUserTokens:query (owner: Principal) -> async [TokenInfoExt];
        ownerOf:      query (tokenId: Nat)   -> async Result<Principal, Error>;
        getTokenInfo: query (tokenId: Nat)   -> async Result<TokenInfoExt, Error>;
        getAllTokens: query ()  -> async [TokenInfoExt];
        getTransaction: query (index: Nat)   -> async TxRecord;
        getTransactions: query (start: Nat, limit: Nat)  -> async [TxRecord];
        getUserTransactionAmount: query (user: Principal)  -> async Nat;
        getUserTransactions: query (user: Principal, start: Nat, limit: Nat)  -> async [TxRecord];
        historySize: query ()  -> async Nat;
    };


    let nftCanister : NftActor = actor(Principal.toText(token_ERC721_id));
    let user_alice: Principal = alice;
    let user_bob: Principal = bob;
    let blackhole: Principal = Principal.fromText("aaaaa-aa");
    // test result status
    private var result : Bool = false;
    private var total_count: Nat = 0;
    private var pass_count : Nat = 0;
    private var fail_count : Nat = 0;
    private var skip_count : Nat = 0;


    func log_info (message: Text) {
        Debug.print(message);
    };

    public func testMint(to: Principal, metadata: TokenMetadata): async Bool {
        switch(await nftCanister.mint(to, metadata)){
            case(#ok(tokenId, txid)){
                log_info("[ok]: mint token successed?");
                log_info("token index: " # Nat.toText(tokenId) # " txid: " # Nat.toText(txid));
                return true;
            };
            case(#err(#Unauthorized)){
                log_info("[error]: " # "unauthotized");
                return false;
            };
            case(#err(#TokenNotExist)){
                log_info("[error]: " # "token not exist");
                return false;
            };
            case(#err(#InvalidOperator)){
                log_info("[error]: " # "invalid operator");
                return false;
            };
        };
    };

    public func testBurn(tokenId: Nat): async Bool {
        switch(await nftCanister.burn(tokenId)){
            case(#ok(tokenId, txid)){
                log_info("[ok]: burn token successed?");
                log_info("token index: " # Nat.toText(tokenId) # " txid: " # Nat.toText(txid));
                return true;
            };
            case(#err(#Unauthorized)){
                log_info("[error]: " # "unauthotized");
                return false;
            };
            case(#err(#TokenNotExist)){
                log_info("[error]: " # "token not exist");
                return false;
            };
            case(#err(#InvalidOperator)){
                log_info("[error]: " # "invalid operator");
                return false;
            };
        };
    };

    public func testSetTokenMetadata(tokenId: Nat, new_metadata: TokenMetadata): async Bool {
        switch(await nftCanister.setTokenMetadata(tokenId, new_metadata)){
            case(#ok(txid)){
                log_info("[ok]: setTokenMetadata successed?");
                log_info("txid: " # Nat.toText(txid));
                return true;
            };
            case(#err(#Unauthorized)){
                log_info("[error]: " # "unauthotized");
                return false;
            };
            case(#err(#TokenNotExist)){
                log_info("[error]: " # "token not exist");
                return false;
            };
            case(#err(#InvalidOperator)){
                log_info("[error]: " # "invalid operator");
                return false;
            };
        };
    };

    public func testApprove(tokenId: Nat, operator: Principal): async Bool {
        switch(await nftCanister.approve(tokenId, operator)){
            case(#ok(txid)){
                log_info("[ok]: approve successed?");
                log_info("txid: " # Nat.toText(txid));
                return true;
            };
            case(#err(#Unauthorized)){
                log_info("[error]: " # "unauthotized");
                return false;
            };
            case(#err(#TokenNotExist)){
                log_info("[error]: " # "token not exist");
                return false;
            };
            case(#err(#InvalidOperator)){
                log_info("[error]: " # "invalid operator");
                return false;
            };
        };
    };

    public func testSetApprovalForAll(operator: Principal, value: Bool): async Bool {
        switch(await nftCanister.setApprovalForAll(operator, value)){
            case(#ok(txid)){
                log_info("[ok]: setApprovalForAll successed?");
                log_info("txid: " # Nat.toText(txid));
                return true;
            };
            case(#err(#Unauthorized)){
                log_info("[error]: " # "unauthotized");
                return false;
            };
            case(#err(#TokenNotExist)){
                log_info("[error]: " # "token not exist");
                return false;
            };
            case(#err(#InvalidOperator)){
                log_info("[error]: " # "invalid operator");
                return false;
            };
        };
    };

    public func testTransfer(to: Principal, tokenId: Nat): async Bool {
        switch(await nftCanister.transfer(to, tokenId)){
            case(#ok(txid)){
                log_info("[ok]: transfer successed?");
                log_info("txid: " # Nat.toText(txid));
                return true;
            };
            case(#err(#Unauthorized)){
                log_info("[error]: " # "unauthotized");
                return false;
            };
            case(#err(#TokenNotExist)){
                log_info("[error]: " # "token not exist");
                return false;
            };
            case(#err(#InvalidOperator)){
                log_info("[error]: " # "invalid operator");
                return false;
            };
        };
    };

    public func testTransferFrom(from: Principal, to: Principal, tokenId: Nat): async Bool {
        switch(await nftCanister.transferFrom(from, to, tokenId)){
            case(#ok(txid)){
                log_info("[ok]: transferFrom successed?");
                log_info("txid: " # Nat.toText(txid));
                return true;
            };
            case(#err(#Unauthorized)){
                log_info("[error]: " # "unauthotized");
                return false;
            };
            case(#err(#TokenNotExist)){
                log_info("[error]: " # "token not exist");
                return false;
            };
            case(#err(#InvalidOperator)){
                log_info("[error]: " # "invalid operator");
                return false;
            };
        };
    };

    public func logMetadataInfos() : async Metadata {
        let metadata: Metadata = await nftCanister.getMetadata();
        log_info("MetaData Info: ");
        log_info("logo: "# metadata.logo);
        log_info("name: "# metadata.name);
        log_info("desc: "# metadata.desc);
        log_info("totalSupply: "# Nat.toText(metadata.totalSupply));
        log_info("owner: "# Principal.toText(metadata.owner));
        metadata
    };

    public func logTokenInfos(tokenId:Nat) : async Bool{
        let tokenInfo: TokenInfoExt = switch(await nftCanister.getTokenInfo(tokenId)) {
            case (#ok(tokenInfo)) {
                tokenInfo;
            };
            case (#err(code)) {
                Prelude.unreachable();
            };
        };
        log_info("\n");
        log_info("Token " # Nat.toText(tokenId) # " Info:");
        log_info("* index: "# Nat.toText(tokenInfo.index));
        log_info("* token owner:" # Principal.toText(tokenInfo.owner));
        switch(tokenInfo.operator){
            case (?p) log_info("* operator: " # Principal.toText(p));
            case null log_info("* no operator");
        };
        log_info("* Timestamp: " # Int.toText(tokenInfo.timestamp));
        log_info("* TokenMetadata:");
        switch(tokenInfo.metadata) {
            case (null) log_info("* no metadata");
            case (?metadata) {
                log_info("     filetype: " # metadata.filetype);
                switch(metadata.location){
                    case (#InCanister(b)) log_info("     location: " # "blob" # "");
                    case (#AssetCanister((p,b))) log_info("     location: " # "Principal: "# Principal.toText(p) # " blob:" # "");
                    case (#IPFS(t)) log_info("     location: " # t);
                    case (#Web(t))  log_info("     location: " # t);
                };
                log_info("     attributes: {key: " # metadata.attributes[0].key # " , value: " # metadata.attributes[0].value # "}");
            };
        };

        true
    };

    public func logUserInfos(who: Principal): async Bool {
        let userInfo: UserInfoExt = switch(await nftCanister.getUserInfo(who)) {
            case (#ok(userInfo)) {
                userInfo;
            };
            case (#err(code)) {
                Prelude.unreachable();
            };
        };
        //Todo
        log_info("User Info:" # Principal.toText(who));
        var operators: Text = "";
        Iter.iterate<Principal>(Iter.fromArray(userInfo.operators), func(p, _index) {
            operators := operators # Principal.toText(p) # ",";
        });
        var allowedBy: Text = "";
        Iter.iterate<Principal>(Iter.fromArray(userInfo.allowedBy), func(p, _index) {
            allowedBy := allowedBy # Principal.toText(p) # ",";
        });
        var allowedTokens: Text = "";
        Iter.iterate<Nat>(Iter.fromArray(userInfo.allowedTokens), func(n, _index) {
            allowedTokens := allowedTokens # Nat.toText(n) # ",";
        });
        var tokens: Text = "";
        Iter.iterate<Nat>(Iter.fromArray(userInfo.tokens), func(n, _index) {
            tokens := tokens # Nat.toText(n) # ",";
        });
        log_info("   operators: " # operators );
        log_info("   allowedBy: " # allowedBy);
        log_info("   allowedTokens: "# allowedTokens);
        log_info("   tokens: "# tokens);
        true
    };

/**
*** @brief: init info test.
**/
    public func testCase1(): async Text {

        log_info("- - - - - - - - - - - - - - - - - - ");
        log_info("a): get Metadata ");
        let init_metadata = await logMetadataInfos(); // log_info metadata info
        if (
          init_metadata.logo == "Test logo" and
          init_metadata.name == "Test NFT1" and
          init_metadata.symbol == "NFT1" and
          init_metadata.desc == "This is a NFT demo test!" and
          init_metadata.totalSupply == 9 and
          init_metadata.owner == user_alice
        ) {
          pass_count += 1;
          } else {
            log_info("! ! ! test fail");
            log_info("ref metadata:");
            log_info("   logo: Test logo");
            log_info("   name: Test NFT1");
            log_info("   name: NFT1");
            log_info("   desc: This is a NFT demo test!");
            log_info("   totalSupply: 9");
            log_info("   owner: "# Principal.toText(user_alice));
            fail_count += 1;
        };
        total_count += 1;

        log_info("\n");
        log_info("- - - - - - - - - - - - - - - - - - ");
        log_info("b): Get Token Infos");
        var token_id = 0;
        let tokens_num = await nftCanister.totalSupply();
        while(token_id < tokens_num) {
            ignore await logTokenInfos(token_id);
            token_id += 1;
        };

        log_info("\n");
        log_info("- - - - - - - - - - - - - - - - - - ");
        log_info("c): Get User Infos");
        log_info("* Alice");
        ignore await logUserInfos(user_alice);
        log_info("\n");
        log_info("* Bob");
        ignore await logUserInfos(user_bob);
        log_info("\n");
        log_info("* This canister");
        ignore await logUserInfos(Principal.fromActor(this));

        log_info("- - - - - - - - - - - - - - - - - - ");
        log_info("\n");
        "Case1: test finished! "
    };

/**
*** @brief: setMetadata, approve, transferFrom, setApproveForAll
**/
    public func testCase2(): async Text {
        // test parameters: to,  metadata
        let canister = Principal.fromActor(this);

        /** 
            filetype: change to png
            location: change to #Web
            attributes: change key and value.
        **/
        let new_location = #Web("Web url");
        let new_meta: TokenMetadata = {
            filetype = "png";
            location = new_location;
            attributes = [{key = "new_test_key"; value = "new_test_value"}];
        }; 

        // tests
        log_info("\n");
        log_info("- - - - - - - - - - - - - - - - - - ");
        log_info("a): Mint");
        log_info("Only owner can mint, this canister try mint. error occur?");
        result := await testMint(canister, new_meta);
        if (result) {
            log_info("! ! ! test fail");
            fail_count += 1;
            }
        else {
            pass_count += 1;
        };
        total_count += 1;

        log_info("\n");
        log_info("- - - - - - - - - - - - - - - - - - ");
        log_info("b): Set New Token Metadata");
        log_info("\n");
        log_info("Only owner can set token metadata, this canister try to set. error occur?");
        result := await testSetTokenMetadata(0, new_meta);
        if (result) {
            log_info("! ! ! test fail");
            fail_count += 1;
            }
        else {
            pass_count += 1;
        };
        total_count += 1;

        log_info("\n");
        log_info("- - - - - - - - - - - - - - - - - - ");
        log_info("c): Test approve");
        log_info("There is no token 10, now this canister try to approve it. error occur?");
        result := await testApprove(10, user_alice);
        if (result) {
            log_info("! ! ! test fail");
            fail_count += 1;
            }
        else {
            pass_count += 1;
        };
        total_count += 1;

        log_info("\n");
        log_info("This canister has token 6,7,8, now it try to approve token 0 (not belong to itself). error occur?");
        result := await testApprove(0, user_alice);
        if (result) {
            log_info("! ! ! test fail");
            fail_count += 1;
            }
        else {
            pass_count += 1;
        };
        total_count += 1;

        log_info("\n");
        log_info("This canister has token 6,7,8, now it try to approve token 6 to itself. error occur?");
        result := await testApprove(6, canister);
        if (result) {
            log_info("! ! ! test fail");
            fail_count += 1;
            }
        else {
            pass_count += 1;
        };
        total_count += 1;


        log_info("\n");
        log_info("This canister has token 6,7,8, now it try to approve token 6 to Alice. successed?");
        result := await testApprove(6, user_alice);
        if (result) {pass_count += 1;}
        else {
            log_info("! ! ! test fail");
            fail_count += 1;
        };
        total_count += 1;

        log_info("\n");
        log_info("This canister trys to approve token 3 (belongs to Bob, but he has approved this canister for all!) to Alice. successed?");
        result := await testApprove(3, user_alice);
        if (result) {pass_count += 1;}
        else {
            log_info("! ! ! test fail");
            fail_count += 1;
        };
        total_count += 1;

        log_info("\n ");
        log_info("Get User Infos");
        log_info("* Alice Infos:");
        ignore await logUserInfos(user_alice);
        log_info("\n");
        log_info("* Bob Infos:");
        ignore await logUserInfos(user_bob);
        log_info("\n");
        log_info("* This canister Infos:");
        ignore await logUserInfos(canister);


        log_info("\n");
        log_info("- - - - - - - - - - - - - - - - - - ");
        log_info("d): Test setApproveForAll");

        log_info("\n");
        log_info("This canister has token 6,7,8, now it try to approve all token for itself. error occur?");
        result := await testSetApprovalForAll(canister, true);
        if (result) {
            log_info("! ! ! test fail");
            fail_count += 1;
            }
        else {
            pass_count += 1;
        };
        total_count += 1;

        log_info("\n");
        log_info("This canister has token 6,7,8, now it try to approve all token for alice. successed?");
        result := await testSetApprovalForAll(user_alice, true);
        if (result) {pass_count += 1;}
        else {
            log_info("! ! ! test fail");
            fail_count += 1;
        };
        total_count += 1;

        log_info("\n");
        log_info("This canister has token 6,7,8, now it try to approve all token for bob. successed?");
        result := await testSetApprovalForAll(user_bob, true);
        if (result) {pass_count += 1;}
        else {
            log_info("! ! ! test fail");
            fail_count += 1;
        };
        total_count += 1;

        log_info("\n ");
        log_info("Get User Infos");
        log_info("* Alice Infos:");
        ignore await logUserInfos(user_alice);
        log_info("\n");
        log_info("* Bob Infos:");
        ignore await logUserInfos(user_bob);
        log_info("\n");
        log_info("* This canister Infos:");
        ignore await logUserInfos(canister);

        log_info("\n");
        log_info("This canister has token 6,7,8, now it try to cancel bob approvol for all token. successed?");
        result := await testSetApprovalForAll(user_bob, false);
        if (result) {pass_count += 1;}
        else {
            log_info("! ! ! test fail");
            fail_count += 1;
        };
        total_count += 1;

        log_info("\n ");
        log_info("Get User Infos");
        log_info("* Alice Infos:");
        ignore await logUserInfos(user_alice);
        log_info("* Bob Infos:");
        ignore await logUserInfos(user_bob);
        log_info("* This canister Infos:");
        ignore await logUserInfos(canister);


        log_info("\n");
        log_info("- - - - - - - - - - - - - - - - - - ");
        log_info("e): Test transfer");

        log_info("\n");
        log_info("There is no token 10, now this canister trys to transfer it. error occur?");
        result := await testTransfer(canister, 10);
        if (result) {
            log_info("! ! ! test fail");
            fail_count += 1;
        }
        else {
            pass_count += 1;
        };
        total_count += 1;

        log_info("\n");
        log_info("This canister has token 6,7,8, allowed token 0, 3, 4, 5. Now it try to transfer token 3. error occur?");
        result := await testTransfer(canister, 1);
        if (result) {
            log_info("! ! ! test fail");
            fail_count += 1;
        }
        else {
            pass_count += 1;
        };
        total_count += 1;

        log_info("\n");
        log_info("This canister has token 6,7,8, allowed token 0, 3, 4, 5. Now it try to transfer token 6 to alice from itself. successed?");
        result := await testTransfer(user_alice, 6);
        if (result) {pass_count += 1;}
        else {
            log_info("! ! ! test fail");
            fail_count += 1;
        };
        total_count += 1;

        log_info("\n ");
        log_info("Get User Infos");
        log_info("* Alice Infos:");
        ignore await logUserInfos(user_alice);
        log_info("\n ");
        log_info("* Bob Infos:");
        ignore await logUserInfos(user_bob);
        log_info("\n ");
        log_info("* This canister Infos:");
        ignore await logUserInfos(canister);


        log_info("\n ");
        log_info("- - - - - - - - - - - - - - - - - - ");
        log_info("f): Test transferFrom");

        log_info("\n");
        log_info("There is no token 10, now this canister trys to transfer it. error occur?");
        result := await testTransferFrom(user_bob, canister, 10);
        if (result) {
            log_info("! ! ! test fail");
            fail_count += 1;
        }
        else {
            pass_count += 1;
        };
        total_count += 1;

        log_info("\n");
        log_info("This canister has token 7,8, allowed token 0, 3, 4, 5. Now it try to transfer token 1. error occur?");
        result := await testTransferFrom(user_alice, canister, 1);
        if (result) {
            log_info("! ! ! test fail");
            fail_count += 1;
        }
        else {
            pass_count += 1;
        };
        total_count += 1;

        log_info("\n");
        log_info("This canister has token 7,8, allowed token 0, 3, 4, 5. Now it try to transfer token 7 to alice from itself. successed?");
        result := await testTransferFrom(canister, user_alice, 7);
        if (result) {pass_count += 1;}
        else {
            log_info("! ! ! test fail");
            fail_count += 1;
        };
        total_count += 1;

        log_info("\n");
        log_info("This canister has token 8, allowed token 0, 3, 4, 5. Now it try to transfer token 3 to itself from bob. successed?");
        result := await testTransferFrom(user_bob, canister, 3);
        if (result) {pass_count += 1;}
        else {
            log_info("! ! ! test fail");
            fail_count += 1;
        };
        total_count += 1;

        log_info("\n ");
        log_info("Get User Infos");
        log_info("* Alice Infos:");
        ignore await logUserInfos(user_alice);
        log_info("* Bob Infos:");
        log_info("\n ");
        ignore await logUserInfos(user_bob);
        log_info("\n ");
        log_info("* This canister Infos:");
        ignore await logUserInfos(canister);


        log_info("\n ");
        log_info("- - - - - - - - - - - - - - - - - - ");
        log_info("g): Test burn");

        log_info("\n");
        log_info("There is no token 10, now this canister trys to burn it. error occur?");
        result := await testBurn(10);
        if (result) {
            log_info("! ! ! test fail");
            fail_count += 1;
            }
        else {
            pass_count += 1;
        };
        total_count += 1;

        log_info("\n");
        log_info("This canister has token 3, 8, allowed token 0, 4, 5. now it try to burn 4. error occur?");
        result := await testBurn(4);
        if (result) {
            log_info("! ! ! test fail");
            fail_count += 1;
            }
        else {
            pass_count += 1;
        };
        total_count += 1;

        log_info("\n");
        log_info("This canister has token 3,8, now it try to burn token 8. successed?");
        result := await testBurn(8);
        if (result) {pass_count += 1;}
        else {
            log_info("! ! ! test fail");
            fail_count += 1;
        };
        total_count += 1;

        log_info("\n ");
        log_info("Get User Infos");
        log_info("* Alice Infos:");
        ignore await logUserInfos(user_alice);
        log_info("* Bob Infos:");
        ignore await logUserInfos(user_bob);
        log_info("* This canister Infos:");
        ignore await logUserInfos(canister);

        "Case2: test finished! "
    };

/**
*** @brief:  get history tx receipt
**/
    public func testCase3(): async Text {

        "Case3: todo "
    };

/**
*** @brief:  test query funs
**/
    public func testCase4(): async Text {

        "Case4: todo "

    };

/**
*** @brief: testfolw: test all cases.
**/
    public func testflow(): async () {

        log_info("******  Testing beginning! ******");
        log_info("====================================");
        log_info("Currently, Alice has token 0, 1, 2; Bob has token 3, 4, 5; This canister has token 6, 7, 8");

        log_info("%%%%% Case1: Testing init Metadata %%%%%");
        log_info(await testCase1());

        log_info("\n");
        log_info("***********************************");
        log_info("%%%%% Case2: Testing setMetadata, approve, transferFrom, setApproveForAll %%%%%");
        log_info(await testCase2());

        log_info("\n");
        log_info("***********************************");
        log_info("%%%%% Case3: Testing history tx receipt! %%%%%");
        log_info(await testCase3());

        log_info("\n");
        log_info("***********************************");
        log_info("%%%%% Case4: Testing query functions! %%%%%");
        log_info(await testCase4());
        
        log_info("====================================");
        log_info("******  Testing end! ******");
        log_info("******  Test results showed below! ******");
        log_info("Total: " # Nat.toText(total_count) # "  Pass: " # Nat.toText(pass_count) # "  Fail: " # Nat.toText(fail_count) # "  Skip: " # Nat.toText(skip_count));

    };

}
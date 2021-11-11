
import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Text "mo:base/Text";
import Debug "mo:base/Debug";
import Time "mo:base/Time";
import Result "mo:base/Result";
import Types "../src//types";

actor class Testflow(token_ERC721_id : Principal) = this {

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



    public type NftActor = actor {
        mint: shared (to: Principal, metadata: TokenMetadata) -> async MintResult;
        burn: shared (tokenId: Nat) -> async MintResult;
        setTokenMetadata: shared (tokenId: Nat, new_metadata: TokenMetadata) -> async TxReceipt;
        approve: shared (tokenId: Nat, operator: Principal) -> async TxReceipt;
        setApprovalForAll: shared (operator: Principal, value: Bool) -> async TxReceipt;
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
        getOperator:  query (tokenId: Nat)   -> async Principal;
        getUserInfo:  query (who: Principal) -> async UserInfoExt;
        getUserTokens:query (owner: Principal) -> async [TokenInfoExt];
        ownerOf:      query (tokenId: Nat)   -> async Principal;
        getTokenInfo: query (tokenId: Nat)   -> async TokenInfoExt;
        getAllTokens: query ()  -> async [TokenInfoExt];
        getTransaction: query (index: Nat)   -> async TxRecord;
        getTransactions: query (start: Nat, limit: Nat)  -> async [TxRecord];
        getUserTransactionAmount: query (user: Principal)  -> async Nat;
        getUserTransactions: query (user: Principal, start: Nat, limit: Nat)  -> async [TxRecord];
        historySize: query ()  -> async Nat;
    };


    let nftCanister : NftActor = actor(Principal.toText(token_ERC721_id));
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
                log_info("[ok]: mint token successed!");
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
                log_info("[ok]: burn token successed!");
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
        switch(await nftCanister.setTokenMetadata(tokenId, new_metadata)){caller:}{
            case(#ok(txid)){
                log_info("[ok]: setTokenMetadata successed!");
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
                log_info("[ok]: approve successed!");
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
                log_info("[ok]: transferFrom successed!");
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

    public func testGetMetadataInfos() : async () {
        let metadata: Metadata = await nftCanister.getMetadata();
        log_info("MetaData Info: ");
        log_info("logo: "# metadata.logo);
        log_info("name: "# metadata.name);
        log_info("desc: "# metadata.desc);
        log_info("totalSupply: "# Nat.toText(metadata.totalSupply));
        log_info("owner: "# Principal.toText(metadata.owner));
    };

    public func testGetBasicInfos(tokenId:Nat) : async () {
        let tokenInfo: TokenInfoExt = await nftCanister.getTokenInfo(tokenId);
        let totalSupply: Nat = await nftCanister.totalSupply();
        let balance: Nat = await nftCanister.balanceOf(tokenInfo.owner);

        log_info("\n");
        log_info("Nft Info:");
        log_info("* totalSupply: "# Nat.toText(totalSupply));
        log_info("* tokenId: "# Nat.toText(tokenInfo.index) # " owner:" # Principal.toText(tokenInfo.owner));
        switch(tokenInfo.operator){
            case (?p) log_info("* operator: " # Principal.toText(p));
            case null log_info("* no operator");
        };
        log_info("* Timestamp:" # Int.toText(tokenInfo.timestamp));
        log_info("* Owner nft balance: " # Nat.toText(balance));

        log_info("\n");
        log_info("Token Info:");
        log_info("* filetype: " # tokenInfo.metadata.filetype);
        switch(tokenInfo.metadata.location){
            case (#InCanister(b)) log_info("* location: " # "blob" # "");
            case (#AssetCanister((p,b))) log_info("* location: " # "Principal: "# Principal.toText(p) # " blob:" # "");
            case (#IPFS(t)) log_info("* location: " # t);
            case (#Web(t))  log_info("* location: " # t);
        };
        log_info("Attributes: {key: " # tokenInfo.metadata.attributes[tokenId].key # " , value: " # tokenInfo.metadata.attributes[tokenId].value # "}");

    };

/**
*** @brief: operations flow correctly
**/
    public func testCase1(): async () {
        // test parameters: to,  metadata
        let to = Principal.fromActor(this);
        /** 
           select located files storage.
           choose #InCanister: Blob for test.
           token_ERC721 Canister as the storage buffer.
        **/
        let location = #InCanister(Principal.toBlob(token_ERC721_id));
        let meta: TokenMetadata = {
            filetype = "jpg";
            location = location;
            attributes = [{key = "test_key"; value = "test_value"}];
        }; 
        log_info("- - - - - - - - - - - - - - - - - - ");
        log_info("a): mint token");
        result := await testMint(to, meta);
        if (result) {pass_count += 1;}
        else {
            log_info("! ! ! test fail");
            fail_count += 1;
        };
        total_count += 1;
        await testGetBasicInfos(0);

        log_info("- - - - - - - - - - - - - - - - - - ");
        log_info("b): Set Token Metadata");
        let new_location = #IPFS("IPFS hash");
        let new_meta: TokenMetadata = {
            filetype = "png";
            location = new_location;
            attributes = [{key = "new_test_key"; value = "new_test_value"}];
        }; 
        result := await testSetTokenMetadata(0, new_meta);
        if (result) {pass_count += 1;}
        else {
            log_info("! ! ! test fail");
            fail_count += 1;
        };
        await testGetBasicInfos(0);

        log_info("- - - - - - - - - - - - - - - - - - ");
        log_info("Case1: finished");
    };

/**
*** @brief:  
**/
    public func testCase2(): async () {
        // log_info("- - - - - - - - - - - - - - - - - - ");
        // log_info("e) not reach minumum liquidity (wicp usdt) ");
        // try {
        //     result := await testAddLiquidity(wicp_id, usdt_id, 1, 50, 0, 0, Time.now()*2);
        //     if (result) {pass_count += 1;}
        //     else {
        //         log_info("! ! ! test fail");
        //         fail_count += 1;};
        //     total_count += 1;
        // } catch(e) {
        //     pass_count += 1;
        //     total_count += 1;
        // };
    };

/**
*** @brief:  
**/
    public func testCase3(): async () {

    };

/**
*** @brief:  
**/
    public func testCase4(): async () {

    };

/**
*** @brief: testfolw: test all cases.
**/
    public func testflow(): async () {

        log_info("******  Testing beginning! ******");
        log_info("====================================");

        log_info("%%%%% Case1: Testing ... %%%%%");
        await testCase1();

        log_info("***********************************");
        log_info("%%%%% Case2: Testing ... %%%%%");
        await testCase2();

        log_info("***********************************");
        log_info("%%%%% Case3: Testing ... %%%%%");
        await testCase3();

        log_info("***********************************");
        log_info("%%%%% Case4: Testing ... %%%%%");
        await testCase4();
        
        log_info("====================================");
        log_info("******  Testing end! ******");
        log_info("******  Test results showed below! ******");
        log_info("Total: " # Nat.toText(total_count) # "  Pass: " # Nat.toText(pass_count) # "  Fail: " # Nat.toText(fail_count) # "  Skip: " # Nat.toText(skip_count));

    };

}
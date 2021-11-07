/**
 * Module     : types.mo
 * Copyright  : 2021 DFinance Team
 * License    : Apache 2.0 with LLVM Exception
 * Maintainer : DFinance Team <hello@dfinance.ai>
 * Stability  : Experimental
 */

import Time "mo:base/Time";
import TrieSet "mo:base/TrieSet";

module {
    public type Metadata = {
        name: Text;
        desc: Text;
        totalSupply: Nat;
        owner: Principal;
    };

    public type FileType = {
        #jpg;
        #png;
        #mp4;
    };
    public type Location = {
        #InCanister: Blob; // NFT encoded data
        #AssetCanister: (Principal, Blob); // asset canister id, storage key
        #IPFS: Text; // IPFS content hash
        #Web: Text; // URL pointing to the file
    };
    public type Attribute = {
        key: Text;
        value: Text;
    };
    public type TokenMetadata = {
        filetype: FileType;
        location: Location;
        attributes: [Attribute];
    };

    public type TokenInfo = {
        index: Nat;
        var owner: Principal;
        var metadata: TokenMetadata;
        var approval: ?Principal;
        timestamp: Time.Time;
    };

    public type TokenInfoExt = {
        index: Nat;
        owner: Principal;
        metadata: TokenMetadata;
        approval: ?Principal;
        timestamp: Time.Time;
    };

    public type UserInfo = {
        var allows: TrieSet.Set<Principal>;         // principals allowed to operate on owner's behalf
        var allowedBy: TrieSet.Set<Principal>;      // principals approved owner
        var allowedIds: TrieSet.Set<Nat>;           // tokens controlled by owner
        var tokens: TrieSet.Set<Nat>;               // owner's tokens
    };

    public type UserInfoExt = {
        allows: [Principal];
        allowedBy: [Principal];
        allowedIds: [Nat];
        tokens: [Nat];
    };
    /// Update call operations
    public type Operation = {
        #mint;  
        #burn;
        #transfer;
        #approve;
        #approveAll;
        #unapproveAll; 
    };
    /// Update call operation record fields
    public type OpRecord = {
        caller: Principal;
        op: Operation;
        index: Nat;
        tokenIndex: ?Nat;
        from: Principal;
        to: Principal;
        timestamp: Time.Time;
    };
};

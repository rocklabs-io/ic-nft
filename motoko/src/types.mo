/**
 * Module     : types.mo
 * Copyright  : 2021 Mixlabs
 * License    : Apache 2.0 with LLVM Exception
 * Maintainer : Mixlabs <hello@mixlabs.io>
 * Stability  : Experimental
 */

import Time "mo:base/Time";

module {
    // e.g. IPFS => ipfshash; URL => https://xxx; ...
	type KV = {
		key: Text;
		value: Text;
	};

	type Metadata = [KV];

    type TokenInfo = {
        index: Nat;
        var owner: Principal;
		var metadata: Metadata;
        var desc: Text;
        var approval: ?Principal;
        timestamp: Time.Time;
    };

    type TokenInfoExt = {
        index: Nat;
        owner: Principal;
        url: Text;
        desc: Text;
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
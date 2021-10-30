/**
 * Module     : types.mo
 * Copyright  : 2021 Mixlabs
 * License    : Apache 2.0 with LLVM Exception
 * Maintainer : Mixlabs <hello@mixlabs.io>
 * Stability  : Experimental
 */

import Time "mo:base/Time";

module {
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
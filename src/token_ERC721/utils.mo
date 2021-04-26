import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";

module {
    public func _exists(ownered : HashMap.HashMap<Nat, Principal>, tokenId: Principal) :  Bool {
        switch (ownered.get(tokenId)) {
            case (? owner) {
                return true;
            };
            case (_) {
                return false;
            };
        }
    };
};


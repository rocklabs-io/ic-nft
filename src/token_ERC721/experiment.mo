import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Error "mo:base/Error";
import Option "mo:base/Option";
import Array "mo:base/Array";
import Int8 "mo:base/Int8";

/**
 *  Implementation of https://github.com/icplabs/DIPs/blob/main/DIPS/dip-721.md Non-Fungible Token Standard.
 */
actor Token_ERC721{

    // Token name
    private stable var name_ : Text = "";

    // Token symbol
    private stable var symbol_ : Text = "";

    // Mapping from token ID to owner address
    private var ownered = HashMap.HashMap<Principal, Principal>(1, Principal.equal, Principal.hash);
    
    // Mapping owner address to token count
    private var balances = HashMap.HashMap<Principal,Nat>(1,Principal.equal,Principal.hash);

    // Mapping from token ID to approved address
    private var tokenApprovals = HashMap.HashMap<Principal, Principal>(1, Principal.equal, Principal.hash);
    
    // Mapping from owner to operator approvals
    private var operatorApprovals = HashMap.HashMap<Principal, HashMap.HashMap<Principal, Bool>>(1, Principal.equal, Principal.hash);
    
    //Mapping from NFT Principal to signer Array
    private var NFTSigner = HashMap.HashMap<Principal, [Principal]>(1, Principal.equal, Principal.hash);

    //NFT Type

    /**
    * @param msg : owner Principal
    * @return [Principal] : Principal of Own NFT
    **/
    public shared(msg) func getMyNFT() : async [Principal]{
        var array : [Principal] = [];
        for ((l,v) in ownered.entries()){
            if (msg.caller == v) {
                array := Array.append(array, [v]);
            };
        };
        array
    };

    public shared(msg) func getMyNFTNumber() : async Int8{
        var number : Int8 = 0;
        for ((l,v) in ownered.entries()){
            if (msg.caller == v) {
                number += 1;
            };
        };
        number
    };

    //TODO : sign NFT
    /**
    * @param msg : 
    * @return : successful or failed
    * need owner agree?
    **/
    public shared(msg) func signNFT() : async Bool{ true };


    //NFT swap NFT
    /**
    * @param msg : NFT Owner
    * @param ID : NFT ID
    * how to get owner's agree? sign???
    **/
    public shared(msg) func swapNFT(nft_id : [Principal]) : async Bool{
        true
    };

    //compound multiple NFT to signal NFT
    /**
    *@param nft_id : owner's NFT Principal
    *@param target_NFT_Id : target compound NFT 
    **/


}

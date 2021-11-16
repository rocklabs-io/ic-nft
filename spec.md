# NFT Standard Spec

A non-fungible token standard for the DFINITY Internet Computer.


## Abstract

NFTs are basic building blocks for the web3 economy, such as gaming, social network, digital art, etc. To better help the web3 economy grow on the IC ecosystem, we propose a standard token interface for non-fungible tokens, the standard provides basic functionality to transfer tokens, allow tokens to be approved so they can be operated by a third party, it also support history transaction storage and query, provide full traceability and verifiability for NFTs including their metadata.

## Specification

### 1. Data structures

1. Metadata: information about this NFT collection

   ```
   public type Metadata = {
   		logo: Text;
       name: Text;
       symbol: Text;
       desc: Text;
       totalSupply: Nat;
       owner: Principal;
   };
   ```

2. TokenMetadata: metadata of a single token

   ```
   public type Location = {
       #InCanister: Blob; // NFT encoded data
       #AssetCanister: (Principal, Blob); // asset storage canister id, storage key
       #IPFS: Text; // IPFS content hash
       #Web: Text; // URL pointing to the file
   };
   public type Attribute = {
       key: Text;
       value: Text;
   };
   public type TokenMetadata = {
       filetype: Text; // jpg, png, mp4, etc.
       location: Location;
       attributes: [Attribute];
   };
   ```

3. TokenInfo: information of a single token

   ```
   public type TokenInfo = {
       index: Nat;
       var owner: Principal;
       var metadata: ?TokenMetadata;
       var operator: ?Principal;
       timestamp: Time.Time;
   };
   ```

4. UserInfo: user information

   ```
   public type UserInfo = {
       var operators: TrieSet.Set<Principal>;     // principals allowed to operate on the user's behalf
       var allowedBy: TrieSet.Set<Principal>;     // principals approved user to operate their's tokens
       var allowedTokens: TrieSet.Set<Nat>;       // tokens the user can operate
       var tokens: TrieSet.Set<Nat>;              // user's tokens
   };
   ```

5. TxRecord: transaction record

   ```
   /// Update call operations
   public type Operation = {
       #mint: ?TokenMetadata;  
       #burn;
       #transfer;
       #approve;
       #approveAll;
       #revokeAll; // revoke approvals
       #setMetadata;
   };
   /// Update call operation record fields
   public type Record = {
       #user: Principal;
       #metadata: ?TokenMetadata; // op == #setMetadata
   };
   public type TxRecord = {
       caller: Principal;
       op: Operation;
       index: Nat;
       tokenIndex: ?Nat;
       from: Record;
       to: Record;
       timestamp: Time.Time;
   };
   ```

6. TxReceipt & MintResult

   ```
   public type Error = {
       #Unauthorized;
       #TokenNotExist;
       #InvalidSpender;
   };
   public type TxReceipt = Result.Result<Nat, Error>; // txid
   public type MintResult = Result.Result<(Nat, Nat), Error>; // token index, txid
   ```

### 2. Basic interfaces

#### Update calls

##### mint

Mint a new token with metadata `metadata` to user `to`, returns a `TxReceipt`. Note that `metadata` can be `null` when mint, and can be set later with `setTokenMetadata` interface.

```
public shared(msg) func mint(to: Principal, metadata: ?TokenMetadata): async MintResult
```

##### setTokenMetadata

Set metadata for the existing token `tokenId`.

```
public shared(msg) func setTokenMetadata(tokenId: Nat, metadata: TokenMetadata): async TxReceipt
```

##### approve

Set operator for the token `tokenId` to `operator`, each token can only have 1 operator.

```
public shared(msg) func approve(tokenId: Nat, operator: Principal): async TxReceipt
```

##### setApprovalForAll

Set approval for the operator `operator` to `value`, if `value == true`, this means allow `operator` to spend owner's tokens, if `value == false`, this means revoke the approval to `operator`.

```
public shared(msg) func setApprovalForAll(operator: Principal, value: Bool): async TxReceipt
```

##### transferFrom

Transfer the token `tokenId` from user `from` to user `to`.

```
public shared(msg) func transferFrom(from: Principal, to: Principal, tokenId: Nat): async TxReceipt
```

#### Query calls

##### logo

Returns the logo of the token.

```
public query func logo() : async Text
```

##### name

Returns the name of the token.

```
public query func name() : async Text
```

##### symbol

Returns the symbol of the token.

```
public query func symbol() : async Text
```

##### desc

Returns the description of the token.

```
public query func desc() : async Text
```

##### balanceOf

Returns the number of tokens user `who` holds.

```
public query func balanceOf(who: Principal): async Nat
```

##### totalSupply

Returns the total supply the this NFT collection.

```
public query func totalSupply(): async Nat
```

##### getMetadata

Returns the metadata about this NFT collection.

```
public query func getMetadata(): async Metadata
```

##### isApprovedForAll

Check if `operator  ` is allowed to operate `owner` 's tokens.

```
public query func isApprovedForAll(owner: Principal, operator: Principal): async Bool
```

##### getOperator

Get the operator of the token `tokenId`.

```
public query func getOperator(tokenId: Nat): async Principal
```

##### getUserInfo

Get user information.

```
public query func getUserInfo(who: Principal): async UserInfoExt
```

##### getUserTokens

Get the token information user `who` holds.

```
public query func getUserTokens(owner: Principal): async [TokenInfoExt]
```

##### ownerOf

Return owner of token `tokenId`.

```
public query func ownerOf(tokenId: Nat): async Principal
```

##### getTokenInfo

Get the token information of `tokenId`.

```
public query func getTokenInfo(tokenId: Nat): async TokenInfoExt
```

##### historySize

Returns transaction history size.

```
public query func historySize(): async Nat
```

##### getTransaction

Get the transaction record with index `index`.

```
public query func getTransaction(index: Nat): async TxRecord
```

##### getTransactions

Get transaction records in the range `[start, start + limit)`.

```
public query func getTransactions(start: Nat, limit: Nat): async [TxRecord]
```

##### getUserTransactionAmount

Get the transaction amount of user.

```
public query func getUserTransactionAmount(user: Principal): async Nat
```

##### getUserTransactions

Get the transactions records in the range `[start, start + limit)` related to user `user`. Note the range is not the global range of all transactions.

```
public query func getUserTransactions(user: Principal, start: Nat, limit: Nat): async [TxRecord]
```

### 3. Optional interfaces

#### Update calls

##### burn

Burn the token `tokenId`, only the owner of the token can do this.

```
public func burn(tokenId: Nat): async TxReceipt
```

##### batchMint

Mint multiple NFTs in one update call, only the NFT issuer can do this.

```
public shared(msg) func batchMint(to: Principal, arr: [?TokenMetadata]): async MintResult
```

#### Query calls

##### getAllTokens

Returns information of all tokens.

```
public query func getAllTokens() : async [TokenInfoExt]
```


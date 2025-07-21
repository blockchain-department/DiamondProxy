# Diamond Proxy Contract

This repository contains a basic implementation of a **Diamond Proxy Contract** (EIP-2535 minimal version), allowing modular and upgradeable smart contracts using facets and selectors.

##  Contract: `Diamond.sol`

###  Features
- Supports `diamondCut()` for adding, replacing, and removing function selectors.
- Stores selector-to-facet mapping for delegation.
- Uses Solidity inline assembly for fallback `delegatecall`.
- Follows `EIP-2535: Diamonds — Multi-Facet Proxy` standard (simplified).

###  Functions

- `constructor()` – Initializes the contract and sets the deployer as the owner.
- `diamondCut(address _facet, uint8 _action, bytes4[] calldata _selectors)`  
  - `_action`:  
    - `0`: Add  
    - `1`: Replace  
    - `2`: Remove
- `fallback()` – Delegates call to the appropriate facet.
- `receive()` – Accepts ETH.
- Internal helpers for selector and facet cleanup.

###  Notes
- Only the owner (set at deployment) can execute `diamondCut`.
- The storage layout is accessed via a fixed `keccak256` slot.
- Does **not** include Loupe or Initialization functions (can be extended).

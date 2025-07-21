/**
 *Submitted for verification at Etherscan.io on 2025-07-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Diamond {
    struct DiamondStorage {
        mapping(bytes4 => address) selectorToFacet;
        mapping(address => bytes4[]) facetFunctionSelectors;
        mapping(address => bytes4[]) facetToSelectors;
        address[] facetAddresses;
        address contractOwner;
    }

    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");

    function diamondStorage() internal pure returns (DiamondStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    modifier onlyOwner() {
        require(msg.sender == diamondStorage().contractOwner, "Not owner");
        _;
    }

    constructor() {
        diamondStorage().contractOwner = msg.sender;
    }

    function diamondCut(address _facet, uint8 _action, bytes4[] calldata _selectors) external onlyOwner {
        require(_facet != address(0) || _action == 2, "Invalid facet");

        DiamondStorage storage ds = diamondStorage();

        for (uint i = 0; i < _selectors.length; i++) {
            bytes4 selector = _selectors[i];

            if (_action == 0) {
                require(ds.selectorToFacet[selector] == address(0), "Selector exists");
                ds.selectorToFacet[selector] = _facet;
                ds.facetFunctionSelectors[_facet].push(selector);
                ds.facetToSelectors[_facet].push(selector);
                if (ds.facetFunctionSelectors[_facet].length == 1) {
                    ds.facetAddresses.push(_facet);
                }

            } else if (_action == 1) {
                require(ds.selectorToFacet[selector] != address(0), "Selector missing");
                address oldFacet = ds.selectorToFacet[selector];
                ds.selectorToFacet[selector] = _facet;
                ds.facetFunctionSelectors[_facet].push(selector);
                ds.facetToSelectors[_facet].push(selector);
                removeSelector(ds.facetToSelectors[oldFacet], selector);

            } else if (_action == 2) {
                address oldFacet = ds.selectorToFacet[selector];
                require(oldFacet != address(0), "Selector missing");
                delete ds.selectorToFacet[selector];
                removeSelector(ds.facetFunctionSelectors[oldFacet], selector);
                removeSelector(ds.facetToSelectors[oldFacet], selector);
                if (ds.facetFunctionSelectors[oldFacet].length == 0) {
                    removeFacetAddress(ds.facetAddresses, oldFacet);
                }

            } else {
                revert("Invalid action");
            }
        }
    }

    function removeSelector(bytes4[] storage selectors, bytes4 selector) internal {
        for (uint i = 0; i < selectors.length; i++) {
            if (selectors[i] == selector) {
                selectors[i] = selectors[selectors.length - 1];
                selectors.pop();
                return;
            }
        }
    }

    function removeFacetAddress(address[] storage facets, address facet) internal {
        for (uint i = 0; i < facets.length; i++) {
            if (facets[i] == facet) {
                facets[i] = facets[facets.length - 1];
                facets.pop();
                return;
            }
        }
    }

    fallback() external payable {
        DiamondStorage storage ds = diamondStorage();
        address facet = ds.selectorToFacet[msg.sig];
        require(facet != address(0), "Function does not exist");

        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    receive() external payable {}
}

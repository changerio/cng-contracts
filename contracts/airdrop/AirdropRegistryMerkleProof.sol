// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; // solhint-disable-line compiler-version

import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import { AirdropRegistryStorage } from "./AirdropRegistryStorage.sol";

abstract contract AirdropRegistryMerkleProof is AirdropRegistryStorage {
    // function _addRoot(address token, bytes32 root) internal {
    //     require(!isRoot[token][root], "duplicate-root");
    //     isRoot[token][root] = true;
    //     roots[token].push(root);
    // }
    // /// @dev verify merkle tree and leaf with contract storage
    // function _verify(
    //     address token,
    //     bytes32 root,
    //     address account,
    //     uint256 amount,
    //     bytes32[] memory proof
    // ) internal view {
    //     require(isRoot[token][root], "unknown-root");
    //     require(verify(token, root, account, amount, proof), "invalid-proof");
    //     require(!claimed[token][root][account], "alreayd-claimed");
    // }
    // /// @dev verify merkle tree
    // function verify(
    //     address token,
    //     bytes32 root,
    //     address account,
    //     uint256 amount,
    //     bytes32[] memory proof
    // ) public pure returns (bool) {
    //     bytes32 h = keccak256(abi.encodePacked(token, account, amount));
    //     return MerkleProof.verify(proof, root, h);
    // }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { NonLinearTimeLockSwapperV2Storage } from "../swapper/NonLinearTimeLockSwapperV2Storage.sol";
import { StorageSlotOwnable } from "../lib/StorageSlotOwnable.sol";

contract NonLinearTimeLockSwapperV3Mock is NonLinearTimeLockSwapperV2Storage, StorageSlotOwnable {
    uint256 public foo;

    modifier onlyValidAddress(address account) {
        require(account != address(0), "zero-address");
        _;
    }

    //////////////////////////////////////////
    //
    // kernel
    //
    //////////////////////////////////////////

    function baz() external pure returns (string memory) {
        return "hey this is baz";
    }

    function implementationVersion() public view virtual override returns (string memory) {
        return "3.0.0";
    }

    function _initializeKernel(bytes memory data) internal virtual override {
        (address owner_, address token_, address tokenWallet_, uint256 foo_) =
            abi.decode(data, (address, address, address, uint256));

        _initializeV3(owner_, token_, tokenWallet_, foo_);
    }

    function _initializeV3(
        address owner_,
        address token_,
        address tokenWallet_,
        uint256 foo_
    ) private onlyValidAddress(owner_) onlyValidAddress(token_) onlyValidAddress(tokenWallet_) {
        _setOwner(owner_);
        token = IERC20(token_);
        tokenWallet = tokenWallet_;
        foo = foo_;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.5; // solhint-disable-line compiler-version

import { OnApprove } from "../token/ERC20OnApprove.sol";
import { Token } from "../token/Token.sol";

import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenReceiverMock is OnApprove {
    IERC20 public token;

    constructor(IERC20 token_) public {
        token = token_;
    }

    function onApprove(
        address owner,
        address spender,
        uint256 amount,
        bytes calldata data
    ) external override returns (bool) {
        if (spender != address(this)) return true;
        if (msg.sender != address(token)) return false;

        SafeERC20.safeTransferFrom(token, owner, address(this), amount);

        data;

        return true;
    }
}

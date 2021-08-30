// SPDX-License-Identifier: MIT

pragma solidity 0.8.5; // solhint-disable-line compiler-version

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { SafeMath } from "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract ERC20MultiTransfer {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    mapping(IERC20 => mapping(address => uint256)) public transferAmount;

    function transferToken(
        IERC20 token,
        address account,
        uint256 amount,
        bool allowDup
    ) public {
        require(allowDup || transferAmount[token][account] == 0, "no-dup-transfer");
        transferAmount[token][account] = transferAmount[token][account].add(amount);
        token.safeTransferFrom(msg.sender, account, amount);
    }

    function transferTokens(
        IERC20 token,
        address[] calldata accounts,
        uint256[] calldata amounts,
        bool allowDup
    ) external {
        require(accounts.length == amounts.length);

        for (uint256 i = 0; i < amounts.length; i++) {
            transferToken(token, accounts[i], amounts[i], allowDup);
        }
    }
}

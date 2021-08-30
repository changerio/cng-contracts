// SPDX-License-Identifier: MIT

pragma solidity 0.8.5; // solhint-disable-line compiler-version

import { SafeMath } from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { OnApprove } from "../token/ERC20OnApprove.sol";

/**
 * @notice this contract is deprecated. NonLinearTimeLock will be used.
 * @dev after each duration, beneficiary can claim tokens.
 */
contract TimeLock is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    bool public initialized;

    IERC20 public token;
    address public beneficiary;

    uint256 public initialBalance;
    uint256 public claimed;

    uint256 public startTime;
    uint256 public endTime;
    uint256 public nSteps;

    event Claimed(address indexed beneficiary, uint256 amount);

    constructor(IERC20 token_, address beneficiary_) public {
        token = token_;
        beneficiary = beneficiary_;
    }

    function init(
        uint256 startTime_,
        uint256 endTime_,
        uint256 nSteps_
    ) external onlyOwner {
        require(!initialized, "no-re-init");
        initialized = true;
        initialBalance = token.balanceOf(address(this));

        startTime = startTime_;
        endTime = endTime_;
        nSteps = nSteps_;
    }

    /**
     * @dev claim loced tokens. `owner` can call this for usability, and it's safe
     *      becuase owner must be Swapper which is not capable to transfer locker's ownership.
     */
    function claim() external {
        require(msg.sender == beneficiary || msg.sender == owner(), "no-auth");

        uint256 amount = claimable();
        require(amount > 0, "invalid-amount");

        claimed = claimed.add(amount);
        token.safeTransfer(beneficiary, amount);

        emit Claimed(beneficiary, amount);
    }

    /**
     * @dev get claimable tokens now
     */
    function claimable() public view returns (uint256) {
        return claimableAt(block.timestamp);
    }

    /**
     * @dev get claimable tokens at `timestamp`
     */
    function claimableAt(uint256 timestamp) public view returns (uint256) {
        require(block.timestamp <= timestamp, "invalid-timestamp");

        if (timestamp < startTime) return 0;
        if (timestamp >= endTime) return initialBalance.sub(claimed);

        uint256 duration = endTime.sub(startTime);
        uint256 step = timestamp.sub(startTime).div(duration.div(nSteps));

        if (step == 0) return 0;
        return initialBalance.mul(step).div(nSteps).sub(claimed);
    }
}

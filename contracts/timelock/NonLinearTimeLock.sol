// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { SafeMath } from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { OnApprove } from "../token/ERC20OnApprove.sol";

import { DSMath } from "../lib/ds-hub.sol";

/**
 * @dev before each step end time, beneficiary can claim tokens.
 */
contract NonLinearTimeLock is DSMath, Ownable, OnApprove {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    bool public initialized;

    ERC20 public token;
    address public beneficiary;

    uint256 public initialBalance;
    uint256 public claimed;

    uint256 public startTime;
    uint256 public endTime;

    uint256 public lastStep;

    uint256 public nSteps;
    uint256[] public stepEndTimes;
    uint256[] public accStepRatio;

    event Claimed(address indexed beneficiary, uint256 amount);

    constructor(ERC20 token_, address beneficiary_) public {
        require(beneficiary_ != address(0), "zero-value");
        require(token_.decimals() == 18, "invalid-decimal");

        token = token_;
        beneficiary = beneficiary_;
    }

    function init(
        uint256 startTime_,
        uint256[] memory stepEndTimes_,
        uint256[] memory stepRatio_
    ) external onlyOwner {
        require(!initialized, "no-re-init");
        require(stepEndTimes_.length == stepRatio_.length, "invalid-array-length");

        uint256 n = stepEndTimes_.length;

        uint256[] memory accStepRatio_ = new uint256[](n);
        uint256 accRatio;
        for (uint256 i = 0; i < n; i++) {
            accRatio += stepRatio_[i];
            accStepRatio_[i] = accRatio;
        }
        require(accRatio == WAD, "invalid-acc-ratio");

        for (uint256 i = 1; i < n; i++) {
            require(stepEndTimes_[i - 1] < stepEndTimes_[i], "unsorted-times");
        }

        initialized = true;
        initialBalance = token.balanceOf(address(this));

        startTime = startTime_;
        endTime = stepEndTimes_[n - 1];

        stepEndTimes = stepEndTimes_;
        accStepRatio = accStepRatio_;

        nSteps = stepRatio_.length;
    }

    function onApprove(
        address owner,
        address spender,
        uint256 amount,
        bytes calldata data
    ) external override returns (bool) {
        require(spender == address(this), "invalid-approval");
        require(msg.sender == address(token), "invalid-token");

        _addDeposit(owner, amount);

        data;
        return true;
    }

    // append more deposits
    function addDeposit(uint256 amount) external {
        _addDeposit(msg.sender, amount);
    }

    function _addDeposit(address owner, uint256 amount) internal {
        require(initialized, "no-init");
        initialBalance = initialBalance.add(amount);
        token.safeTransferFrom(owner, address(this), amount);
    }

    /**
     * @dev claim locked tokens. `owner` can call this for usability, and it's safe
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

        uint256 step = getStepAt(timestamp);
        uint256 accRatio = accStepRatio[step];

        return wmul(initialBalance, accRatio).sub(claimed);
    }

    /**
     * @dev get current step
     */
    function getStep() public view returns (uint256) {
        return getStepAt(block.timestamp);
    }

    /**
     * @dev get step at `timestamp`
     */
    function getStepAt(uint256 timestamp) public view returns (uint256) {
        require(timestamp >= startTime, "not-started");
        uint256 n = nSteps;
        if (timestamp >= stepEndTimes[n - 1]) {
            return n - 1;
        }
        if (timestamp <= stepEndTimes[0]) {
            return 0;
        }

        uint256 lo = 1;
        uint256 hi = n - 1;
        uint256 md;

        while (lo < hi) {
            md = (hi + lo + 1) / 2;
            if (timestamp < stepEndTimes[md - 1]) {
                hi = md - 1;
            } else {
                lo = md;
            }
        }

        return lo;
    }
}

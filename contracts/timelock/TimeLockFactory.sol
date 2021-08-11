// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { SafeMath } from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { TimeLock } from "./TimeLock.sol";
import { OnApprove } from "../token/ERC20OnApprove.sol";

/**
 * @notice this contract is deprecated.
 */
contract TimeLockFactory is Ownable, OnApprove {
    using SafeERC20 for IERC20;

    IERC20 public token;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public nSteps;

    mapping(address => TimeLock) public locks;

    event Deposited(address indexed beneficiary, address indexed lock, uint256 amount);

    constructor(
        IERC20 token_,
        uint256 startTime_,
        uint256 endTime_,
        uint256 nSteps_
    ) public {
        require(startTime_ < endTime_, "invalid-time");
        require(nSteps_ > 0, "invalid-steps");

        token = token_;
        startTime = startTime_;
        endTime = endTime_;
        nSteps = nSteps_;
    }

    function onApprove(
        address owner,
        address spender,
        uint256 amount,
        bytes calldata data
    ) external override returns (bool) {
        require(spender == address(this), "invalid-approval");
        require(amount > 0, "invalid-approval-amount");
        deposit(owner, amount);
        return true;
    }

    // deposit sender's token
    function deposit(address beneficiary, uint256 amount) public {
        require(address(locks[beneficiary]) == address(0), "redundent-deposit");
        require(msg.sender == address(token) || msg.sender == beneficiary, "no-auth");
        TimeLock lock = new TimeLock(token, beneficiary);

        locks[beneficiary] = lock;

        token.safeTransferFrom(beneficiary, address(lock), amount);
        lock.init(startTime, endTime, nSteps);

        emit Deposited(beneficiary, address(lock), amount);
    }

    //////////////////////////////////////////
    //
    // TimeLock helper functions
    //
    //////////////////////////////////////////

    function claim() external {
        require(address(locks[msg.sender]) != address(0), "no-deposit");
        return locks[msg.sender].claim();
    }

    function initialBalance(address beneficiary) external view returns (uint256) {
        require(address(locks[beneficiary]) != address(0), "no-deposit");
        return locks[beneficiary].initialBalance();
    }

    function claimable(address beneficiary) external view returns (uint256) {
        require(address(locks[beneficiary]) != address(0), "no-deposit");
        return locks[beneficiary].claimable();
    }

    function claimableAt(address beneficiary, uint256 timestamp) external view returns (uint256) {
        require(address(locks[beneficiary]) != address(0), "no-deposit");
        return locks[beneficiary].claimableAt(timestamp);
    }

    function claimed(address beneficiary) external view returns (uint256) {
        require(address(locks[beneficiary]) != address(0), "no-deposit");
        return locks[beneficiary].claimed();
    }
}

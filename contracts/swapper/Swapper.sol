// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import {SafeMath} from "@openzeppelin/contracts/math/SafeMath.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

import {TimeLock} from "../timelock/TimeLock.sol";
import {OnApprove} from "../token/ERC20OnApprove.sol";

import {DSMath} from "../lib/ds-hub.sol";

/**
 * @notice this contract is deprecated. NonLinearTimeLockSwapper will be used.
 * @dev `deposit` source token and `claim` target token from TimeLock contract.
 */
contract Swapper is Ownable, DSMath, OnApprove {
    using SafeERC20 for IERC20;

    // swap data for each source token, i.e., tCHA, mCHA
    struct Data {
        uint128 rate;
        uint128 startTime;
        uint128 endTime;
        uint128 nSteps;
    }

    IERC20 public token; // target token, i.e., CHA
    address public tokenWallet; // address who supply target token

    // time lock data for each source token
    mapping(address => Data) public datas;

    // time lock of beneficiary for each source token
    // sourceToken => beneficiary => TimeLock
    mapping(address => mapping(address => TimeLock)) public locks;

    event Deposited(
        address indexed sourceToken,
        address indexed beneficiary,
        address indexed lock,
        uint256 sourceTokenAmount,
        uint256 targetTokenAmount
    );

    constructor(IERC20 token_, address tokenWallet_) public {
        token = token_;
        tokenWallet = tokenWallet_;
    }

    //////////////////////////////////////////
    //
    // TimeLock data
    //
    //////////////////////////////////////////

    function register(
        address sourceToken,
        uint256 rate,
        uint256 startTime,
        uint256 endTime,
        uint256 nSteps
    ) external onlyOwner {
        require(!isRegistered(sourceToken), "duplicate-register");

        require(rate > 0, "invalid-rate");
        require(startTime < endTime, "invalid-time");
        require(nSteps > 0, "invalid-steps");

        datas[sourceToken] = Data({
            rate: uint128(rate),
            startTime: uint128(startTime),
            endTime: uint128(endTime),
            nSteps: uint128(nSteps)
        });
    }

    function isRegistered(address sourceToken) public view returns (bool) {
        return datas[sourceToken].rate > 0;
    }

    //////////////////////////////////////////
    //
    // source token deposit
    //
    //////////////////////////////////////////

    function onApprove(
        address owner,
        address spender,
        uint256 amount,
        bytes calldata data
    ) external override returns (bool) {
        require(spender == address(this), "invalid-approval");

        deposit(msg.sender, owner, amount);

        return true;
    }

    // deposit sender's token
    function deposit(
        address sourceToken,
        address beneficiary,
        uint256 amount
    ) public {
        require(isRegistered(sourceToken), "unregistered-source-token");
        require(amount > 0, "invalid-amount");

        require(
            address(locks[sourceToken][beneficiary]) == address(0),
            "redundent-deposit"
        );

        require(
            msg.sender == address(sourceToken) || msg.sender == beneficiary,
            "no-auth"
        );

        Data storage data = datas[sourceToken];

        TimeLock lock = new TimeLock(token, beneficiary);

        locks[sourceToken][beneficiary] = lock;

        // get source token
        IERC20(sourceToken).safeTransferFrom(
            beneficiary,
            address(this),
            amount
        );

        uint256 tokenAmount = wmul(amount, data.rate);

        token.safeTransferFrom(tokenWallet, address(lock), tokenAmount);
        lock.init(data.startTime, data.endTime, data.nSteps);

        emit Deposited(
            sourceToken,
            beneficiary,
            address(lock),
            amount,
            tokenAmount
        );
    }

    //////////////////////////////////////////
    //
    // TimeLock contract instance helper functions
    //
    //////////////////////////////////////////

    function claim(address sourceToken) external {
        require(
            address(locks[sourceToken][msg.sender]) != address(0),
            "no-deposit"
        );
        return locks[sourceToken][msg.sender].claim();
    }

    function initialBalance(address sourceToken, address beneficiary)
        external
        view
        returns (uint256)
    {
        require(
            address(locks[sourceToken][beneficiary]) != address(0),
            "no-deposit"
        );
        return locks[sourceToken][beneficiary].initialBalance();
    }

    function claimable(address sourceToken, address beneficiary)
        external
        view
        returns (uint256)
    {
        require(
            address(locks[sourceToken][beneficiary]) != address(0),
            "no-deposit"
        );
        return locks[sourceToken][beneficiary].claimable();
    }

    function claimableAt(
        address sourceToken,
        address beneficiary,
        uint256 timestamp
    ) external view returns (uint256) {
        require(
            address(locks[sourceToken][beneficiary]) != address(0),
            "no-deposit"
        );
        return locks[sourceToken][beneficiary].claimableAt(timestamp);
    }

    function claimed(address sourceToken, address beneficiary)
        external
        view
        returns (uint256)
    {
        require(
            address(locks[sourceToken][beneficiary]) != address(0),
            "no-deposit"
        );
        return locks[sourceToken][beneficiary].claimed();
    }
}

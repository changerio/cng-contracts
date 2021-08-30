// SPDX-License-Identifier: MIT

pragma solidity 0.8.5; // solhint-disable-line compiler-version

import { SafeMath } from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { NonLinearTimeLock } from "../timelock/NonLinearTimeLock.sol";
import { OnApprove } from "../token/ERC20OnApprove.sol";
import { Token } from "../token/Token.sol";

import { DSMath } from "../lib/ds-hub.sol";

/**
 * @dev `deposit` source token and `claim` target token from NonLinearTimeLock contract.
 */
contract NonLinearTimeLockSwapper is Ownable, DSMath, OnApprove {
    using SafeERC20 for IERC20;

    // swap data for each source token, i.e., tCHA, mCHA
    struct Data {
        uint128 rate; // convertion rate from source token to target token
        uint128 startTime;
        uint256[] stepEndTimes;
        uint256[] stepRatio;
    }

    IERC20 public token; // target token, i.e., CHA
    address public tokenWallet; // address who supply target token

    // time lock data for each source token
    mapping(address => Data) public datas;

    // time lock of beneficiary for each source token
    // sourceToken => beneficiary => NonLinearTimeLock
    mapping(address => mapping(address => NonLinearTimeLock)) public locks;

    modifier onlyValidAddress(address account) {
        require(account != address(0), "zero-address");
        _;
    }

    event Deposited(
        address indexed sourceToken,
        address indexed beneficiary,
        address indexed lock,
        uint256 sourceTokenAmount,
        uint256 targetTokenAmount
    );

    constructor(IERC20 token_, address tokenWallet_)
        public
        onlyValidAddress(address(token_))
        onlyValidAddress(tokenWallet_)
    {
        token = token_;
        tokenWallet = tokenWallet_;
    }

    //////////////////////////////////////////
    //
    // token wallet
    //
    //////////////////////////////////////////

    function setTokenWallet(address tokenWallet_) external onlyOwner onlyValidAddress(tokenWallet_) {
        tokenWallet = tokenWallet_;
    }

    //////////////////////////////////////////
    //
    // NonLinearTimeLock data
    //
    //////////////////////////////////////////

    function register(
        address sourceToken,
        uint128 rate,
        uint128 startTime,
        uint256[] memory stepEndTimes,
        uint256[] memory stepRatio
    ) external onlyOwner {
        require(!isRegistered(sourceToken), "duplicate-register");

        require(rate > 0, "invalid-rate");

        require(stepEndTimes.length == stepRatio.length, "invalid-array-length");

        uint256 n = stepEndTimes.length;

        uint256 accRatio;
        for (uint256 i = 0; i < n; i++) {
            accRatio = add(accRatio, stepRatio[i]);
        }
        require(accRatio == WAD, "invalid-acc-ratio");

        for (uint256 i = 1; i < n; i++) {
            require(stepEndTimes[i - 1] < stepEndTimes[i], "unsorted-times");
        }

        datas[sourceToken] = Data({
            rate: rate,
            startTime: startTime,
            stepEndTimes: stepEndTimes,
            stepRatio: stepRatio
        });
    }

    function isRegistered(address sourceToken) public view returns (bool) {
        return datas[sourceToken].startTime > 0;
    }

    function getStepEndTimes(address sourceToken) external view returns (uint256[] memory) {
        return datas[sourceToken].stepEndTimes;
    }

    function getStepRatio(address sourceToken) external view returns (uint256[] memory) {
        return datas[sourceToken].stepRatio;
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

        data;
        return true;
    }

    // deposit sender's token
    function deposit(
        address sourceToken,
        address beneficiary,
        uint256 amount
    ) public onlyValidAddress(beneficiary) {
        require(isRegistered(sourceToken), "unregistered-source-token");
        require(amount > 0, "invalid-amount");

        require(msg.sender == address(sourceToken) || msg.sender == beneficiary, "no-auth");

        Data storage data = datas[sourceToken];
        uint256 tokenAmount = wmul(amount, data.rate);

        // process first deposit
        if (address(locks[sourceToken][beneficiary]) == address(0)) {
            NonLinearTimeLock lock = new NonLinearTimeLock(ERC20(address(token)), beneficiary);

            locks[sourceToken][beneficiary] = lock;

            // get source token
            IERC20(sourceToken).safeTransferFrom(beneficiary, address(this), amount);

            // transfer target token and initialize lock
            token.safeTransferFrom(tokenWallet, address(lock), tokenAmount);
            lock.init(data.startTime, data.stepEndTimes, data.stepRatio);

            emit Deposited(sourceToken, beneficiary, address(lock), amount, tokenAmount);
            return;
        }

        // process subsequent deposit
        NonLinearTimeLock lock = locks[sourceToken][beneficiary];

        // get source token
        IERC20(sourceToken).safeTransferFrom(beneficiary, address(this), amount);

        // get target token from token wallet
        token.safeTransferFrom(tokenWallet, address(this), tokenAmount);

        // update initial balance of lock
        bytes memory d;
        Token(address(token)).approveAndCall(address(lock), tokenAmount, d);

        emit Deposited(sourceToken, beneficiary, address(lock), amount, tokenAmount);
    }

    //////////////////////////////////////////
    //
    // NonLinearTimeLock contract instance helper functions
    //
    //////////////////////////////////////////

    modifier onlyDeposit(address sourceToken, address account) {
        require(address(locks[sourceToken][account]) != address(0), "no-deposit");

        _;
    }

    function claim(address sourceToken) public onlyDeposit(sourceToken, msg.sender) {
        locks[sourceToken][msg.sender].claim();
    }

    function claimTokens(address[] calldata sourceTokens) external {
        for (uint256 i = 0; i < sourceTokens.length; i++) {
            claim(sourceTokens[i]);
        }
    }

    function initialBalance(address sourceToken, address beneficiary)
        external
        view
        onlyDeposit(sourceToken, beneficiary)
        returns (uint256)
    {
        return locks[sourceToken][beneficiary].initialBalance();
    }

    function claimable(address sourceToken, address beneficiary)
        external
        view
        onlyDeposit(sourceToken, beneficiary)
        returns (uint256)
    {
        return locks[sourceToken][beneficiary].claimable();
    }

    function claimableAt(
        address sourceToken,
        address beneficiary,
        uint256 timestamp
    ) external view onlyDeposit(sourceToken, beneficiary) returns (uint256) {
        return locks[sourceToken][beneficiary].claimableAt(timestamp);
    }

    function claimed(address sourceToken, address beneficiary)
        external
        view
        onlyDeposit(sourceToken, beneficiary)
        returns (uint256)
    {
        return locks[sourceToken][beneficiary].claimed();
    }
}

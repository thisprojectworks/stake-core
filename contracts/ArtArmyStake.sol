// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

//import "hardhat/console.sol";

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
    * @dev Returns the token name.
    */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title SafeBEP20
 * @dev Wrappers around BEP20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeBEP20 for IBEP20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IBEP20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IBEP20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IBEP20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IBEP20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IBEP20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeBEP20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeBEP20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
        }
    }
}

contract ArtArmyStake  {

    /**
     * Art Army Stake 1 is a gamified application,
     * where players stake to earn points.
     * After two weeks, the top 10 players with the
     * most points earn exclusive NFTs.
     * Points are determined by the amount of tokens
     * that have been deposited and the time that it has been deposited.
     * Players can withdraw and put tokens whenever they want.
     */

    using SafeBEP20 for IBEP20;
    using SafeMath for uint256;

    IBEP20 public _token;
    event StakeAdded(address indexed player);
    event StakeRemoved(address indexed player);
    event PlayerSet(address indexed player);

    string private _gameName;

    mapping (address => uint256) private _stakes;

    /**
     * @dev Constructor sets token that can be received
     */
    constructor (IBEP20 token) public {
        _gameName = 'Art Army Stake 1';
        _token = token;
    }

    /**
    * @dev Returns the game name.
    */
    function gameName() public view returns (string memory) {
        return _gameName;
    }


    /**
     * @dev Return the amount staked of the player.
     */

    function getStake(address account) public view virtual returns (uint256) {
        return _stakes[account];
    }

    /**
     * @dev Player participation numbers
     * Player.amount: Determine the amount of tokens deposited
     * Player.time: The last time tokens were added or removed
     * Player.points: With an algorithm, the points accumulated since the last time tokens were added or removed are calculated.
     */


    struct Player {
        uint256 amount;
        uint256 time;
        uint256 points;
    }

    mapping (address => Player) private _player;

    /**
     * @dev Return the points of the player since the last time tokens were added or removed.
     */

    function getPlayerPoints(address account) external view virtual returns (uint256) {
        return _player[account].points;
    }

    /**
     * @dev Return the last time tokens were added or removed.
     */

    function getPlayerTime(address account) external view virtual returns (uint256) {
        return _player[account].time;
    }

    /**
    * @dev Return the amount staked of the player.
    */

    function getPlayerAmount(address account) external view virtual returns (uint256) {
        return _player[account].amount;
    }

    /**
     * @dev Return the current points of the player.
     */

    function getPlayerCurrentPoints(address account) external view virtual returns (uint256) {
        uint256 currentPoints = 0;
        // Algorithm to calculate the current points
        if(_player[account].time != 0){
            uint256 timeDifference = block.timestamp.sub(_player[account].time);
            uint256 newPoints = timeDifference.mul(_stakes[account]);
            currentPoints = _player[account].points.add(newPoints);
        }

        return currentPoints;
    }

    /**
     * @dev Called when a player add tokens to stake.
     */
    function addStake(uint256 amount) external returns (bool) {

        address playerAddress = address(msg.sender);

        // Before staking, the points are calculated since the last time tokens were added or removed.
        _setPlayer(playerAddress);

        // It is necessary to add stake with more than 0 tokens
        require(amount > 0, "You need to steak at least some tokens");

        // The player need to have enough allowance
        uint256 allowance = _token.allowance(playerAddress, address(this));
        require(allowance >= amount, "You need to approve the transactions before you stake");

        // Tokens are transferred to the game contract
        _token.safeTransferFrom(playerAddress, address(this), amount);

        //The player's token amount is updated
        _stakes[playerAddress] = _stakes[playerAddress].add(amount);
        _player[playerAddress].amount = _stakes[playerAddress];

        emit StakeAdded(playerAddress);

        return true;
    }

    /**
     * @dev Called when a player remove tokens to stake.
     */

    function removeStake(uint256 amount) external returns (bool){

        address playerAddress = address(msg.sender);

        // Before staking, the points are calculated since the last time tokens were added or removed.
        _setPlayer(playerAddress);

        uint256 contractBalance = _token.balanceOf(address(this));
        uint256 stakeOfThisPlayer = _stakes[playerAddress];

        // It is necessary to remove stake with more than 0 tokens
        require(amount > 0, "The amount needs to be higher than 0");

        //It is necessary that the amount to be removed does not exceed the balance of contract
        require(amount <= contractBalance, "The contract needs to have the same or less amount of tokens");

        //It is necessary that the amount to be removed does not exceed the amount of deposited tokens
        require(amount <= stakeOfThisPlayer, "The amount exceeds staked");

        // Tokens are transferred to the player
        _token.safeTransfer(playerAddress, amount);

        // The player's token amount is updated
        _stakes[playerAddress] = _stakes[playerAddress].sub(amount);
        _player[playerAddress].amount = _stakes[playerAddress];

        emit StakeRemoved(playerAddress);

        return true;

    }

    /**
     * @dev Function that determines some numbers of the player
     */

    function _setPlayer(address playerAddress) internal returns (address){

        // Algorithm to calculate points since tokens were last added or removed
        if(_player[playerAddress].time != 0){
            uint256 timeDifference = block.timestamp.sub(_player[playerAddress].time);
            uint256 newPoints = timeDifference.mul(_stakes[playerAddress]);
            _player[playerAddress].points = _player[playerAddress].points.add(newPoints);
        }

        _player[playerAddress].time = block.timestamp;

        emit PlayerSet(playerAddress);

        return playerAddress;
    }


}
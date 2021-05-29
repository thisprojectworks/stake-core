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

import "@openzeppelin/contracts/access/Ownable.sol";

contract ArtArmyFarming is Ownable  {

    /**
     * Art Army Farming is a yield farming functionality,
     * The investors can stake liquidity tokens
     * for earn reward tokens
     * Investors can withdraw and add liquidity tokens whenever they want.
     */

    using SafeBEP20 for IBEP20;
    using SafeMath for uint256;

    IBEP20 public _lpToken;
    IBEP20 public _rewardToken;
    event StakeAdded(address indexed investor);
    event StakeRemoved(address indexed investor);
    event RemoveRewardToken(uint256 amount);

    string private _contractName;
    uint256 private _multiplier;
    uint256 private _endTime;

    mapping (address => uint256) private _stakes;

    /**
     * @dev Constructor sets token that can be received
     */
    constructor (string memory contractName, IBEP20 lpToken, IBEP20 rewardToken, uint256 multiplier, uint256 endTime) {

        _contractName = contractName;
        // Liquidity Token
        _lpToken = lpToken;
        // Reward Token
        _rewardToken = rewardToken;
        // Multiplier of rewards
        _multiplier = multiplier;
        // End of the rewards
        _endTime = endTime;
    }



    /**
    * @dev Returns the contract name.
    */
    function getContractName() public view returns (string memory) {
        return _contractName;
    }

    /**
    * @dev Returns the LP Token address.
    */
    function getLpToken() public view returns (IBEP20) {
        return _lpToken;
    }

    /**
    * @dev Returns the Reward Token address.
    */
    function getRewardToken() public view returns (IBEP20) {
        return _rewardToken;
    }

    /**
    * @dev Returns the Multiplier.
    */
    function getMultiplier() public view returns (uint256) {
        return _multiplier;
    }

    /**
    * @dev Set the Multiplier.
    */
    function setMultiplier(uint256 multiplier) external returns (bool) {
        require(address(msg.sender) == address(owner()), "Only the owner can call this function");
        _multiplier = multiplier;
        return true;
    }

    /**
    * @dev Returns the end of the rewards.
    */
    function getEndTime() public view returns (uint256) {
        return _endTime;
    }

    /**
    * @dev Set the end of the rewards.
    */
    function setEndTime(uint256 endTime) external returns (bool) {
        require(address(msg.sender) == address(owner()), "Only the owner can call this function");
        _endTime = endTime;
        return true;
    }


    /**
     * @dev Return the amount staked of the investor.
     */
    function getStake(address account) public view virtual returns (uint256) {
        return _stakes[account];
    }

    /**
     * @dev Investor participation numbers
     * Player.amount: Determine the amount of tokens deposited
     * Player.time: The last time tokens were added or removed
     * Player.reward: With an algorithm, the reward accumulated since the last time LP tokens were added or removed are calculated.
     */

    struct Investor {
        uint256 amount;
        uint256 time;
        uint256 reward;
    }

    mapping (address => Investor) private _investor;

    /**
     * @dev Return the reward of the investor since the last time LP tokens were added or removed.
     */

    function getInvestorReward(address account) external view virtual returns (uint256) {
        return _investor[account].reward;
    }

    /**
     * @dev Return the last time LP tokens were added or removed.
     */

    function getInvestorTime(address account) external view virtual returns (uint256) {
        return _investor[account].time;
    }

    /**
    * @dev Return the amount staked of the investor.
    */

    function getInvestorAmount(address account) external view virtual returns (uint256) {
        return _investor[account].amount;
    }

    /**
    * @dev Return the amount staked of the investor.
    */

    function getContractBalance() external view virtual returns (uint256) {
        return _lpToken.balanceOf(address(this));
    }

    /**
     * @dev Return the current points of the player.
     * For each token that is deposited, give 1 token per year of reward multiplied for the multiplier.
     */

    function getInvestorCurrentReward(address account) public view virtual returns (uint256) {
        uint256 currentReward = 0;

        uint256 time = block.timestamp;

        if(time > _endTime)
            time = _endTime;

        if(_investor[account].time != 0 && time > _investor[account].time){
           uint256 timeDifference = time.sub(_investor[account].time);
           uint256 newPoints = timeDifference.mul(_stakes[account]);
           uint256 newPointsMultiplier = newPoints.div(31536000).mul(_multiplier);
           currentReward = _investor[account].reward.add(newPointsMultiplier);
        }

        return currentReward;
    }

    /**
   * @dev Called when a investor want to get the rewards.
   */

    function harvestInvestorReward() public returns (bool){

        // Only the Investor can call this function for him.
        address investorAddress = address(msg.sender);

        // Get current reward
        uint256 reward = getInvestorCurrentReward(investorAddress);

        // It is necessary to remove stake with more than 0 tokens
        require( _stakes[investorAddress] > 0, "The amount of stake needs to be higher than 0");

        // It is necessary to remove stake with more than 0 tokens
        require( reward > 0, "The amount of reward needs to be higher than 0");

        uint256 contractBalance = _rewardToken.balanceOf(address(this));

        //It is necessary that the amount to be removed does not exceed the balance of contract
        require(reward <= contractBalance, "The contract needs to have the same or less amount of reward tokens");

        // Tokens are transferred to the investor
        _rewardToken.safeTransfer(investorAddress, reward);

        // Reset some values of the investor
        _investor[investorAddress].time = block.timestamp;
        _investor[investorAddress].reward = 0;

        return true;

    }



    /**
    * @dev Called when a player add tokens to stake.
    */
    function addStake(uint256 amount) external returns (bool) {

        address investorAddress = address(msg.sender);

        // Get current reward and harvest rewards
        uint256 reward = getInvestorCurrentReward(investorAddress);
        if( reward > 0 ){
            harvestInvestorReward();
        }

        // Before staking, the rewards are calculated since the last time LP tokens were added or removed.
        _setInvestor(investorAddress);

        // It is necessary not finish the endTime of the contract
        require(block.timestamp < _endTime, "You need to steak at least some tokens");

        // It is necessary to add stake with more than 0 tokens
        require(amount > 0, "You need to steak at least some tokens");

        // The investor need to have enough allowance
        uint256 allowance = _lpToken.allowance(investorAddress, address(this));
        require(allowance >= amount, "You need to approve the transactions before you stake");

        // Tokens are transferred to the contract
        _lpToken.safeTransferFrom(investorAddress, address(this), amount);

        //The investor's token amount is updated
        _stakes[investorAddress] = _stakes[investorAddress].add(amount);
        _investor[investorAddress].amount = _stakes[investorAddress];


        emit StakeAdded(investorAddress);

        return true;
    }

    /**
     * @dev Called when a player remove tokens to stake.
     */

    function removeStake(uint256 amount) external returns (bool){

        address investorAddress = address(msg.sender);

        // Get current reward and harvest rewards
        uint256 reward = getInvestorCurrentReward(investorAddress);
        if( reward > 0 ){
            harvestInvestorReward();
        }

        // Before staking, the points are calculated since the last time tokens were added or removed.
        _setInvestor(investorAddress);

        uint256 contractBalance = _lpToken.balanceOf(address(this));
        uint256 stakeOfThisInvestor = _stakes[investorAddress];

        // It is necessary to remove stake with more than 0 LP tokens
        require(amount > 0, "The amount needs to be higher than 0");

        //It is necessary that the amount to be removed does not exceed the balance of contract
        require(amount <= contractBalance, "The contract needs to have the same or less amount of tokens");

        //It is necessary that the amount to be removed does not exceed the amount of deposited LP tokens
        require(amount <= stakeOfThisInvestor, "The amount exceeds staked");

        // Tokens are transferred to the investor
        _lpToken.safeTransfer(investorAddress, amount);

        // The investor's token amount is updated
        _stakes[investorAddress] = _stakes[investorAddress].sub(amount);
        _investor[investorAddress].amount = _stakes[investorAddress];

        emit StakeRemoved(investorAddress);

        return true;

    }

    /**
     * @dev Function that determines some numbers of the investor
     */

    function _setInvestor(address investorAddress) internal returns (address){

        // Algorithm to calculate points since LP tokens were last added or removed
        if(_investor[investorAddress].time != 0 && block.timestamp <= _endTime){
            uint256 timeDifference = block.timestamp.sub(_investor[investorAddress].time);
            uint256 newReward = timeDifference.mul(_stakes[investorAddress]);
            _investor[investorAddress].reward = _investor[investorAddress].reward.add(newReward);
        }

        _investor[investorAddress].time = block.timestamp;


        return investorAddress;
    }

    /**
    * @dev Called only for the owner to remove rewards Tokens of the Contract.
    */

    function removeRewardToken(uint256 amount) external returns (bool){

        require(address(msg.sender) == address(owner()), "Only the owner can call this function");

        uint256 contractBalance = _rewardToken.balanceOf(address(this));

        // It is necessary to remove stake with more than 0 tokens
        require(amount > 0, "The amount needs to be higher than 0");

        //It is necessary that the amount to be removed does not exceed the balance of contract
        require(amount <= contractBalance, "The contract needs to have the same or less amount of tokens");


        // Tokens are transferred to the owner
        _rewardToken.safeTransfer(address(owner()), amount);

        /*// The player's token amount is updated
        _stakes[investorAddress] = _stakes[investorAddress].sub(amount);
        _investor[investorAddress].amount = _stakes[investorAddress];

        emit RemoveRewardToken(amount);*/

        return true;

    }




}
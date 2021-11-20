// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IArtArmyStakeHolders {

    function distributeEarns() external payable returns (bool);

}

contract ArtArmyStakeHolders is IArtArmyStakeHolders  {

    /**
     * Art Army Stake 1 is a gamified application,
     * where players stake to earn points.
     * After two weeks, the top 10 players with the
     * most points earn exclusive NFTs.
     * Points are determined by the amount of tokens
     * that have been deposited and the time that it has been deposited.
     * Players can withdraw and put tokens whenever they want.
     */

    IERC20 private _token;

    string private _contractName;

    event StakeAdded(address indexed investor);
    event StakeRemoved(address indexed investor);

    address[] investorsArray;

    /**
     * @dev Constructor sets token that can be received
     */
    constructor (string memory contractName, IERC20 token) {
        _contractName = contractName;
        _token = token;
    }

    /**
    * @dev Returns the contract name.
    */
    function getContractName() public view returns (string memory) {
        return _contractName;
    }

    struct Investor {
        uint256 amountStaked;
        uint256 earns;
    }

    mapping (address => Investor) private _investor;

    /**
    * @dev Return the amount staked of the investor.
    */

    function getInvestorAmount(address account) external view virtual returns (uint256) {
        return _investor[account].amountStaked;
    }

    /**
    * @dev Return the earns of the investor.
    */

    function getInvestorEarns(address account) external view virtual returns (uint256) {
        return _investor[account].earns;
    }


    /**
     * @dev Called when a investor add tokens to stake.
     */
    function addStake(uint256 amount) external returns (bool) {

        address investorAddress = address(msg.sender);

        // It is necessary to add stake with more than 0 tokens
        require(amount > 0, "You need to stake at least some tokens");

        // The player need to have enough allowance
        uint256 allowance = _token.allowance(investorAddress, address(this));
        require(allowance >= amount, "You need to approve the transactions before you stake");

        // Add the investor to the InvestorsArray
        if(_investor[investorAddress].amountStaked == 0)
            investorsArray.push(investorAddress);

        // Tokens are transferred to the contract
        _token.transferFrom(investorAddress, address(this), amount);

        // Investor amount is updated
        _investor[investorAddress].amountStaked += amount;

        emit StakeAdded(investorAddress);

        return true;
    }

    /**
     * @dev Called when a player remove tokens to stake.
     */

    function removeStake(uint256 amount) external returns (bool){

        address investorAddress = address(msg.sender);

        uint256 contractBalance = _token.balanceOf(address(this));

        // It is necessary to remove stake with more than 0 tokens
        require(amount > 0, "The amount needs to be higher than 0");

        //It is necessary that the amount to be removed does not exceed the balance of contract
        require(amount <= contractBalance, "The contract needs to have the same or less amount of tokens");

        //It is necessary that the amount to be removed does not exceed the amount of deposited tokens
        require(amount <= _investor[investorAddress].amountStaked, "The amount exceeds staked");

        // Tokens are transferred to the player
        _token.transfer(investorAddress, amount);

        // Investor amount is updated
        _investor[investorAddress].amountStaked = _investor[investorAddress].amountStaked - amount;

        if(_investor[investorAddress].amountStaked == 0)
            removeInvestor(investorAddress);

        emit StakeRemoved(investorAddress);

        return true;

    }

    function removeInvestor(address investorAddress) private returns(bool) {

        for ( uint i = 0; i < investorsArray.length; i++ ) {
           if(investorAddress == investorsArray[i])
                delete investorsArray[i];
        }

        return true;
    }


    // Called by the Seller & Auction Contract
    function distributeEarns() public payable returns (bool){

        // If you dont sen any msg.value always add 0.
        require(msg.value > 0, "Art Army Holders Stake: Your amount must be greater than 0");

        uint256 contractBalance = _token.balanceOf(address(this));

        for (uint i = 0; i < investorsArray.length; i++) {
            _investor[address(investorsArray[i])].earns += (msg.value * _investor[address(investorsArray[i])].amountStaked ) / contractBalance;
        }

        return true;
    }


}

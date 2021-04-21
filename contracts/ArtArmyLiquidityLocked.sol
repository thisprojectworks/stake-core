pragma solidity ^0.7.0;

import "@openzeppelin/contracts/token/ERC20/TokenTimelock.sol";

contract ArtArmyLiquidityLocked is TokenTimelock {
    constructor(
        IERC20 _token,
        address _beneficiary,
        uint256 _releaseTime
    ) public TokenTimelock(_token, _beneficiary, _releaseTime) {}
}

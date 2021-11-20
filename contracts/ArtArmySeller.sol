// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ArtArmyArtwork.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IArtArmyStakeHolders {

    function distributeEarns() external payable returns (bool);

}

contract ArtArmySeller is

    Ownable,
    ERC721Holder

{

    string private _contractName;
    IERC721ArtArmy public _nftContract;
    address payable private _artArmyTreasury;
    uint256 private _artArmyFee;
    uint256 private _holdersFee;
    IERC20 private _currencyContract;
    uint256 private _maximumCuratorFeeInBasisPoints;
    address _burnWallet = 0x0000000000000000000000000000000000000000;
    IERC721ArtArmy public _membershipNftContract;
    IArtArmyStakeHolders _stakeHoldersContract;

    event saleLaunched(uint256 tokenId);
    event purchaseDone(uint256 tokenId);

    constructor (
        string memory contractName,
        IERC721ArtArmy nftContract,
        address payable artArmyTreasury,
        uint256 artArmyFee,
        uint256 holdersFee,
        IERC20 currencyContract,
        uint256 maximumCuratorFeeInBasisPoints,
        IERC721ArtArmy membershipNftContract,
        IArtArmyStakeHolders stakeHoldersContract
    ) {

        _contractName = contractName;
        // NFT Contract
        _nftContract = nftContract;
        // Art Army Treasury address
        _artArmyTreasury = artArmyTreasury;
        // Art Army Fee in basis points
        _artArmyFee = artArmyFee;
        // Holders Fee in basis points
        _holdersFee = holdersFee;
        // Token used for the transactions
        _currencyContract = currencyContract;
        // Maximum curator's Fee in basis points
        _maximumCuratorFeeInBasisPoints = maximumCuratorFeeInBasisPoints;
        // Discount NFT
        _membershipNftContract = membershipNftContract;
        // Stake Holders Contract
        _stakeHoldersContract = stakeHoldersContract;

    }

    struct Sale {
        bool onSale;
        uint256 price;
        address payable curatorWallet;
        uint256 curatorFeeInBasisPoints;
        address payable sellerWallet;
    }

    // Sales
    mapping (uint256 => Sale) private _sale;

    function getOnSale(uint256 tokenId) public view returns (bool){
        return _sale[tokenId].onSale;
    }
    function getSalePrice(uint256 tokenId) public view returns (uint256){
        return _sale[tokenId].price;
    }
    function getSaleCuratorWallet(uint256 tokenId) public view returns (address payable){
        return _sale[tokenId].curatorWallet;
    }
    function getSaleCuratorFeeInBasisPoints(uint256 tokenId) public view returns (uint256){
        return _sale[tokenId].curatorFeeInBasisPoints;
    }
    function getSaleSellerWallet(uint256 tokenId) public view returns (address payable){
        return _sale[tokenId].sellerWallet;
    }

    /**
    * @dev Returns the contract name.
    */
    function getContractName() public view returns (string memory) {
        return _contractName;
    }

    /**
    * @dev Returns the NFT Token contract address.
    */
    function getNftContract() public view returns (IERC721) {
        return _nftContract;
    }

    /**
    * @dev Returns the treasury address.
    */
    function getArtArmyTreasury() public view returns (address payable) {
        return _artArmyTreasury;
    }

    /**
    * @dev Returns the Art Army Fee in basis points.
    */
    function getArtArmyFee() public view returns (uint256) {
        return _artArmyFee;
    }

    /**
    * @dev Returns the stake address.
    */
    function getHoldersStakeContract() public view returns (IArtArmyStakeHolders) {
        return _stakeHoldersContract;
    }

    /**
    * @dev Returns the Holders Fee in basis points.
    */
    function getHoldersFee() public view returns (uint256) {
        return _holdersFee;
    }

    /**
    * @dev Returns the Token BEP20 used for the transactions.
    */
    function getCurrency() public view returns (IERC20) {
        return _currencyContract;
    }

    /**
    * @dev Returns the maximum Curator's Fee in Basis Points that an curator can be set in basis points.
    */
    function getMaximumCuratorFeeInBasisPoints() public view returns (uint256) {
        return _maximumCuratorFeeInBasisPoints;
    }

    /**
    * @dev Set the Art Army Fees.
    */
    function setArtArmyFee(uint256 artArmyFee) external returns (bool) {
        require(address(_msgSender()) == address(owner()), "Only the owner can call this function");
        _artArmyFee = artArmyFee;
        return true;
    }

    /**
    * @dev Set the Holders Fees.
    */
    function setHoldersFee(uint256 holdersFee) external returns (bool) {
        require(address(_msgSender()) == address(owner()), "Only the owner can call this function");
        _holdersFee = holdersFee;
        return true;
    }

    /**
    * @dev Set the Token BEP20 used for the transactions.
    */
    function setCurrency(IERC20 currencyContract) external returns (bool) {
        require(address(_msgSender()) == address(owner()), "Only the owner can call this function");
        _currencyContract = currencyContract;
        return true;
    }

    /**
    * @dev Set the maximum curator's fee in basis points.
    */
    function setMaximumCuratorFeeInBasisPoints(uint256 maximumCuratorFeeInBasisPoints) external returns (bool) {
        require(address(_msgSender()) == address(owner()), "Only the owner can call this function");
        _maximumCuratorFeeInBasisPoints = maximumCuratorFeeInBasisPoints;
        return true;
    }

    function _tokenExists(uint256 tokenId) internal view virtual returns (bool) {

        bool tokenExistsBool = false;

        if(
            // Token must Exists
            _nftContract.getArtistWallet(tokenId) != _burnWallet
        ){
            tokenExistsBool  = true;
        }

        return tokenExistsBool ;
    }
    

    /**
    * @dev Make an Art Army NFT Sale
    *
    * Requirements:
    * - The sender must have the NFT `tokenId`.
    * - `_royaltyInBasisPoints`should be less than maximumCuratorFeeInBasisPoints
    * - The sender must approve the transactions with the contract
    */
    function launchSale(uint256 price, uint256 tokenId, address payable curatorWallet, uint256 curatorFeeInBasisPoints, address payable sellerWallet) external returns (bool){
        require(_nftContract.ownerOf(tokenId) == address(_msgSender()), "Art Army Sale: The NFT is not in the wallet sender");
        require(curatorFeeInBasisPoints < _maximumCuratorFeeInBasisPoints , "Art Army Sale: Curator fee needs to be less than _maximumCuratorFeeInBasisPoints");

        _nftContract.safeTransferFrom(_nftContract.ownerOf(tokenId), address(this), tokenId);

        _sale[tokenId].price = price;
        _sale[tokenId].curatorWallet = curatorWallet;
        _sale[tokenId].curatorFeeInBasisPoints = curatorFeeInBasisPoints;
        _sale[tokenId].curatorWallet = curatorWallet;
        _sale[tokenId].sellerWallet = sellerWallet;
        _sale[tokenId].onSale = true;

        emit saleLaunched(tokenId);

        return true;
    }

    /**
    * @dev Transfer the token to the owner of the contract by emergency
    *
    */
    function emergencyTransferNft(uint256 tokenId) external returns (bool){
        require(address(_msgSender()) == address(owner()), "Only the owner can call this function");
        _nftContract.safeTransferFrom(address(this), address(owner()), tokenId);

        return true;
    }

    /**
    * @dev Make the purchase of the Token
    *
    */
    function makePurchase(uint256 tokenId) external payable returns (bool){
        //require(_currencyContract.allowance(address(_msgSender()), address(this)) >= _sale[tokenId].price, "Art Army Sale: The allowance must be greater or equal than the price of the NFT");
        require(_sale[tokenId].onSale, "The NFT must be on sale");
        require(msg.value >= _sale[tokenId].price, "Art Army Sale: Your amount must be greater or equal than the price of the NFT");
        require( _msgSender() != _nftContract.getArtistWallet(tokenId), "Art Army Sale: The artist cannot buy his own tokens");

        endSale(tokenId, payable(_msgSender()));

        emit purchaseDone(tokenId);
        return true;
    }

    function getBenefit(uint256 amount, uint256 fee) internal pure returns (uint256){

        return (amount * fee) / 10000;
    }

    /**
    * @dev End the sale & transfer money and NFTs to all the players
    *
    */
    function endSale(uint256 tokenId, address payable buyer) internal returns (bool){

        // If there are one or more discount NFT (membershipNftContract) in the buyer wallet,
        // the buyer get half the benefit of the holders.
        uint256 discountBenefit = 0;
        if(_membershipNftContract.balanceOf(buyer) > 0){
            discountBenefit = getBenefit(_sale[tokenId].price, _holdersFee / 2);
            sendViaCall(buyer, discountBenefit);
        }

        // Holders Benefit
        uint256 holdersBenefit = getBenefit(_sale[tokenId].price, _holdersFee) - discountBenefit;
        _stakeHoldersContract.distributeEarns{value: holdersBenefit}();

        // Art Army Benefit
        uint256 artArmyBenefit = getBenefit(_sale[tokenId].price, _artArmyFee);
        sendViaCall(payable(_artArmyTreasury), artArmyBenefit);

        // Curator Benefit
        uint256 curatorBenefit = getBenefit(_sale[tokenId].price, _sale[tokenId].curatorFeeInBasisPoints);
        sendViaCall(payable(_sale[tokenId].curatorWallet), curatorBenefit);

        // Artist Royalty
        uint256 artistRoyalty = getBenefit(_sale[tokenId].price, _nftContract.getArtistRoyalty(tokenId));
        sendViaCall(payable(_nftContract.getArtistWallet(tokenId)), artistRoyalty);

        // Seller Benefit
        uint256 sellerBenefit =  _sale[tokenId].price - curatorBenefit - artArmyBenefit - holdersBenefit - artistRoyalty - discountBenefit;
        sendViaCall(payable(_sale[tokenId].sellerWallet), sellerBenefit);

        _nftContract.safeTransferFrom(address(this), address(buyer), tokenId);

        _sale[tokenId].onSale = false;

        return true;
    }

    function sendViaCall(address payable _to, uint256 amount) private{
        (bool sent, bytes memory data) = _to.call{value: amount}("");
        require(sent, "Failed to send currency");
    }

}

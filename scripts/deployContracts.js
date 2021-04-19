const { ethers } = require("hardhat");

let Token;
let Stake;
let artArmyToken;
let stakeArtArmyToken;

let SimpleToken;
let TokenReceiver;
let simpleToken;
let tokenReceiver;

async function deployContracts(deployer) {
    console.log(
        "Deploying contracts....",
    );
    Token = await ethers.getContractFactory("contracts/ArtArmyToken.sol:ArtArmyToken");
    Stake = await ethers.getContractFactory("ArtArmyStake");

    artArmyToken = await Token.deploy();
    stakeArtArmyToken = await Stake.deploy();

    SimpleToken = await ethers.getContractFactory("SimpleToken");
    TokenReceiver = await ethers.getContractFactory("TokenReceiver");

    simpleToken = await SimpleToken.deploy();
    tokenReceiver = await TokenReceiver.deploy();

}

deployContracts()
    .then(() => {
        console.log('Address of ArtArmyToken: '+artArmyToken.address);
        console.log('Address of ArtArmyStake: '+stakeArtArmyToken.address);
        console.log('Address of simpleToken: '+simpleToken.address);
        console.log('Address of tokenReceiver: '+tokenReceiver.address);
        process.exit(0);
    })
    .catch(error => {
        console.error(error);
        process.exit(1);
    });


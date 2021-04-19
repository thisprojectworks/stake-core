const { ethers } = require("hardhat");

let Token;
let Stake;
let artArmyToken;
let artArmyStake;

async function deployArtArmyTestnet() {
    const [deployer] = await ethers.getSigners();
    console.log(
        "Deploying contracts with the account:",
        deployer.address
    );

    Token = await ethers.getContractFactory("ArtArmyToken");
    Stake = await ethers.getContractFactory("ArtArmyStake");
    artArmyToken = await Token.deploy();
    artArmyStake = await Stake.deploy(artArmyToken.address);

    console.log('Address of ArtArmyToken: '+artArmyToken.address);
    console.log('Address of ArtArmyStake: '+artArmyStake.address);


}

deployArtArmyTestnet()
    .then(() => {
        /*console.log('Address of ArtArmyToken: '+artArmyToken.address);
        console.log('Address of ArtArmyStake: '+artArmyStake.address);*/
        process.exit(0);
    })
    .catch(error => {
        console.error(error);
        process.exit(1);
    });


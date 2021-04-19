const { ethers } = require("hardhat");

let Token;
let artArmyToken;
let tokenArtArmyTokenAddress = '0x5FbDB2315678afecb367f032d93F642f64180aa3';


async function getBalance() {
    console.log(
        "Getting balances....",
    );
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    Token = await ethers.getContractFactory("ArtArmyToken");
    artArmyToken = await Token.attach(hre.bsc_testnet.artArmyTokenAddress);
    const account = owner.address;
    const accountBalance = await artArmyToken.balanceOf(account);
    return accountBalance;

}

getBalance()
    .then((accountBalance) => {
        console.log('Balance: '+accountBalance);
        process.exit(0);
    })
    .catch(error => {
        console.error(error);
        process.exit(1);
    });


const { ethers } = require("hardhat");

async function createWallets() {
    console.log(
        "Creating Wallets....",
    );
    let wallet_1 = ethers.Wallet.createRandom()
}

createWallets()
    .then(() => {
        console.log('Reset complete.')
        process.exit(0);
    })
    .catch(error => {
        console.error(error);
        process.exit(1);
    });


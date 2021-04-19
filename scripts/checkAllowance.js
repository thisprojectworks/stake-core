const { ethers } = require("hardhat");

async function checkAllowance() {
    console.log(
        "Creating Wallets....",
    );
    let wallet_1 = ethers.Wallet.createRandom()
}

checkAllowance()
    .then(() => {
        console.log('Reset complete.')
        process.exit(0);
    })
    .catch(error => {
        console.error(error);
        process.exit(1);
    });


/**
 * @type import('hardhat/config').HardhatUserConfig
 */

require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-web3");


task("accounts", "Prints the list of accounts", async () => {
  const accounts = await ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

task("getTransaction", "Prints the transaction")
    .addParam("id", "The transaction ID")
    .setAction(async response => {
        console.log(response.id);
        const transaction = await web3.eth.getTransaction(response.id)
        console.log(transaction);
    });

/* NO FUNCIONA */
task("balanceOf", "Prints an account's ART balance")
    .addParam("account", "The account's address")
    .setAction(async taskArgs => {
        exec('npx testnet run scripts/getBalance.js');
        console.log('balance');
      //await hre.run('/scripts/getBalance.js');
      //console.log(web3.utils.fromWei(accountBalance, "ether"), "ART");
    });


extendEnvironment((hre) => {
    hre.contractsAddress = {
        artArmyTokenAddress: '0xDDa0648FA8c9cD593416EC37089C2a2E6060B45c',
        artArmyStakeAddress: '0xccA9728291bC98ff4F97EF57Be3466227b0eb06C',
        simpleTokenAddress: '0xAe9Ed85dE2670e3112590a2BB17b7283ddF44d9c',
        tokenReceiverAddress: '0xD1760AA0FCD9e64bA4ea43399Ad789CFd63C7809',
    };

    hre.bsc_testnet = {
        artArmyTokenAddress: '0x16aec0f50896e3a0da39af49903aa251f8028c1b',
        artArmyStakeAddress: '0xB023aab87d5cCe6a26639b328e6882548c748aFf',
    }
});


module.exports = {

    networks:{
        bsc_testnet:{
            url:'https://data-seed-prebsc-1-s1.binance.org:8545/',
            chainId: 97,
            accounts: [`0xecdeed4befd41bd563d28142afc762a1bf67ea69c3b9704adfbd53415d2083ed`]
        }
    },
  solidity: {
    compilers: [
        {
        version: "0.5.17"
        },
        {
            version: "0.6.6",
        },
        {
        version: "0.7.6",
        }
    ]
  }
};

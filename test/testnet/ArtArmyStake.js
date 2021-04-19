// We import Chai to use its asserting functions here.


const { expect } = require("chai");


describe("ArtArmy Stake Testing", function () {

    let Token;
    let artArmyToken;
    let Stake;
    let artArmyStake;
    let owner;
    let addr1;
    let addr2;
    let addrs;


    it("Attach Contracts", async function () {
        [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

        Token = await ethers.getContractFactory("ArtArmyToken");
        Stake = await ethers.getContractFactory("ArtArmyStake");

        artArmyToken = await Token.attach(hre.bsc_testnet.artArmyTokenAddress);
        artArmyStake = await Stake.attach(hre.bsc_testnet.artArmyStakeAddress);
    });

    describe("Allowance", function () {

        it("Should approve 2000 ART tokens to another account", async function () {

            await artArmyToken.approve(hre.bsc_testnet.artArmyStakeAddress, 1000);

            //await artArmyToken.increaseAllowance(hre.bsc_testnet.artArmyStakeAddress, 1000);

            const allowance = await artArmyToken.allowance(owner.address, hre.bsc_testnet.artArmyStakeAddress);
            expect(allowance).to.equal(1000);

        });
    });

   /* describe("Name", function () {

        it("Should return name be the name of the contract", async function () {

            const name = await artArmyStake.name();
            expect(name).to.equal('Art Army Stake 0.1');

        });
    });*/


    describe("Do Stake", function () {

        it("Should do stake 1000 ART tokens to stake", async function () {

            const initialOwnerBalance = await artArmyToken.balanceOf(owner.address);

            const stuff = await artArmyStake.doStake(1000);

            const stakeContractBalance =  await artArmyToken.balanceOf(artArmyStake.address);

            const finalOwnerBalance = await artArmyToken.balanceOf(owner.address);

            //console.log('Stake: '+stakeContractBalance.toString());
            //console.log('Owner: '+finalOwnerBalance.toString());

            expect(finalOwnerBalance).to.equal(initialOwnerBalance.sub(1000));

        });

        it("Should the contract account have 1000 ART tokens", async function () {

            const contractBalance = await artArmyToken.balanceOf(artArmyStake.address);

            //console.log('Stake: '+stakeContractBalance.toString());
            //console.log('Owner: '+finalOwnerBalance.toString());

            expect(contractBalance).to.equal(1000);

        });
    });









});
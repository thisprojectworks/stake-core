// We import Chai to use its asserting functions here.


const { expect } = require("chai");



describe("SimpleToken Testing", function () {

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

        Token = await ethers.getContractFactory("SimpleToken");
        Stake = await ethers.getContractFactory("TokenReceiver");

        artArmyToken = await Token.deploy();
        artArmyStake = await Stake.deploy(artArmyToken.address);
    });

    describe("Allowance", function () {

        it("Should approve 2000 ART tokens to another account", async function () {

            await artArmyToken.approve(artArmyStake.address, 1000);

            await artArmyToken.increaseAllowance(artArmyStake.address, 1000);

            const allowance = await artArmyToken.allowance(owner.address, artArmyStake.address);

            console.log(artArmyStake.address);
            expect(allowance).to.equal(2000);

        });
    });


    describe("Stuff", function () {

        it("Should do stuff 1000 ART tokens to stake", async function () {

            const initialOwnerBalance = await artArmyToken.balanceOf(owner.address);

            console.log('initial: '+initialOwnerBalance.toString());

            //await artArmyStake.connect(owner).doStuff();

            const stuff = await artArmyStake.doStuff();

            const stakeContractBalance =  await artArmyToken.balanceOf(artArmyStake.address);

            const finalOwnerBalance = await artArmyToken.balanceOf(owner.address);

            console.log('Stake: '+stakeContractBalance.toString());
            console.log('Owner: '+finalOwnerBalance.toString());


            expect(finalOwnerBalance).to.equal(initialOwnerBalance.sub(1000));

        });
    });

});

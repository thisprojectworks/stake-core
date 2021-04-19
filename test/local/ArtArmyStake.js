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

        artArmyToken = await Token.deploy();
        artArmyStake = await Stake.deploy(artArmyToken.address);
    });


    describe("Allowance", function () {

        it("Should approve 2000 ART tokens to another account", async function () {

            await artArmyToken.approve(artArmyStake.address, 1000);

            await artArmyToken.increaseAllowance(artArmyStake.address, 1000);

            const allowance = await artArmyToken.allowance(owner.address, artArmyStake.address);
            expect(allowance).to.equal(2000);

        });
    });

   /* describe("Name", function () {

        it("Should return name be the name of the contract", async function () {

            const name = await artArmyStake.name();
            expect(name).to.equal('Art Army Stake 0.1');

        });
    });*/

    describe("Initial comprobation getStake", function () {

        it("Should be 0 the initial getStake the player", async function () {

            const ownerStake = await artArmyStake.getStake(owner.address);
            expect(ownerStake).to.equal(0);

        });
    });

    describe("getPlayer Before Stake", function () {

        it("Should time be 0", async function () {

            const playerTime = await artArmyStake.getPlayerTime(owner.address);

            expect(playerTime).to.equal(0);

        });

        it("Should points be 0", async function () {

            const playerPoints = await artArmyStake.getPlayerPoints(owner.address);

            expect(playerPoints).to.equal(0);

        });

        it("Should amount be 0", async function () {

            const playerAmount = await artArmyStake.getPlayerAmount(owner.address);

            expect(playerAmount).to.equal(0);

        });
    });


    describe("Add Stake", function () {

        it("Should no remove stake 100 ART before of staking", async function () {

            const initialOwnerBalance = await artArmyToken.balanceOf(owner.address);

            await expect(
                artArmyStake.removeStake(100)
            ).to.be.revertedWith("The amount exceeds staked");

            const finalOwnerBalance = await artArmyToken.balanceOf(owner.address);

            expect(initialOwnerBalance).to.equal(finalOwnerBalance);

        });

        it("Should fail if sender doesn’t have enough allowance", async function () {

            const initialOwnerBalance = await artArmyToken.balanceOf(addr1.address);

            await expect(
                artArmyStake.connect(addr1).addStake(1)
            ).to.be.revertedWith("You need to approve the transactions before you stake");

            const finalOwnerBalance = await artArmyToken.balanceOf(addr1.address);

            expect(initialOwnerBalance).to.equal(finalOwnerBalance);

        });

        it("Should fail if sender doesn’t have enough tokens", async function () {
            const initialOwnerBalance = await artArmyToken.balanceOf(addr1.address);

            await artArmyToken.connect(addr1).approve(artArmyStake.address, 1);

            await expect(
                artArmyStake.connect(addr1).addStake(1)
            ).to.be.revertedWith("BEP20: transfer amount exceeds balance");

            const finalOwnerBalance = await artArmyToken.balanceOf(addr1.address);

            expect(initialOwnerBalance).to.equal(finalOwnerBalance);

        });

        it("Should do stake 1000 ART tokens to stake", async function () {

            const initialOwnerBalance = await artArmyToken.balanceOf(owner.address);

            const addStake = await artArmyStake.addStake(1000);

            const finalOwnerBalance = await artArmyToken.balanceOf(owner.address);

            //console.log('Stake: '+stakeContractBalance.toString());
            //console.log('Owner: '+finalOwnerBalance.toString());

            expect(finalOwnerBalance).to.equal(initialOwnerBalance.sub(1000));

        });

        it("Should no remove stake 10000 ART before of staking", async function () {

            const initialOwnerBalance = await artArmyToken.balanceOf(owner.address);

            await expect(
                artArmyStake.removeStake(10000)
            ).to.be.revertedWith("The amount exceeds staked");

            const finalOwnerBalance = await artArmyToken.balanceOf(owner.address);

            expect(initialOwnerBalance).to.equal(finalOwnerBalance);

        });

        it("Should the contract account have 1000 ART tokens", async function () {

            const contractBalance = await artArmyToken.balanceOf(artArmyStake.address);

            //console.log('Stake: '+stakeContractBalance.toString());
            //console.log('Owner: '+finalOwnerBalance.toString());

            expect(contractBalance).to.equal(1000);

        });

        it("Should allowance to be 1000", async function () {

            const allowance = await artArmyToken.allowance(owner.address, artArmyStake.address);
            expect(allowance).to.equal(1000);

        });
    });

    describe("getPlayer After first Stake", function () {

        it("Should time be not 0", async function () {

            const playerTime = await artArmyStake.getPlayerTime(owner.address);

            //console.log(playerTime);

            expect(playerTime).to.not.equal(0);

        });

        it("Should points be 0", async function () {

            const playerPoints = await artArmyStake.getPlayerPoints(owner.address);
            console.log(playerPoints);
            expect(playerPoints).to.equal(0);

        });
    });

    describe("Second comprobation of getStake", function () {

        it("Should be 1000 the getStake of the player, later add the stake", async function () {

            const ownerStake = await artArmyStake.getStake(owner.address);
            expect(ownerStake).to.equal(1000);

        });
    });
    /*describe("Time 1", function () {
        it("currentTime", async function () {
            const currentTime = await artArmyStake.getCurrentTime();
            console.log(currentTime.toString());
            //console.log(new Date())
        });
    });*/


    describe("Sleep", function () {
        it("Sleep", async function () {
            for(i=0 ; i<10 ; i++){
                await artArmyToken.increaseAllowance(artArmyStake.address, 1000);
                await artArmyToken.decreaseAllowance(artArmyStake.address, 1000);
            }
            expect(0).to.equal(0);
        });
    });

    describe("Add Stake 2", function () {


        it("Should do stake 1000 ART tokens to stake", async function () {

            const initialOwnerBalance = await artArmyToken.balanceOf(owner.address);

            const addStake = await artArmyStake.addStake(1000);

            const finalOwnerBalance = await artArmyToken.balanceOf(owner.address);

            expect(finalOwnerBalance).to.equal(initialOwnerBalance.sub(1000));

        });

        it("Should the contract account have 1000 ART tokens", async function () {

            const contractBalance = await artArmyToken.balanceOf(artArmyStake.address);

            //console.log('Stake: '+stakeContractBalance.toString());
            //console.log('Owner: '+finalOwnerBalance.toString());
            expect(contractBalance).to.equal(2000);

        });

        it("Should allowance to be 1000", async function () {

            const allowance = await artArmyToken.allowance(owner.address, artArmyStake.address);
            expect(allowance).to.equal(0);

        });
    });



    describe("getPlayer After second Stake", function () {
        //this.timeout(10000);

        /*it('wait 10000', function(done){
                setTimeout(done, 2000);
            });*/

        it("Should time be not 0", async function () {

            const playerTime = await artArmyStake.getPlayerTime(owner.address);
            //console.log(playerTime);
            expect(playerTime).to.not.equal(0);

        });



        it("Should points be not 0", async function () {

            const playerPoints = await artArmyStake.getPlayerPoints(owner.address);
            console.log(playerPoints.toString());
            expect(playerPoints).to.not.equal(0);

        });
    });

    describe("Sleep", function () {
        it("Sleep", async function () {
            for(i=0 ; i<20 ; i++){
                await artArmyToken.increaseAllowance(artArmyStake.address, 1000);
                await artArmyToken.decreaseAllowance(artArmyStake.address, 1000);
            }
            expect(0).to.equal(0);
        });
    });


    describe("Remove Stake", function () {

        it("Should remove stake 1000 ART tokens from the contract", async function () {


            const initialOwnerBalance = await artArmyToken.balanceOf(owner.address);

            const removeStake = await artArmyStake.removeStake(2000);

            const finalOwnerBalance = await artArmyToken.balanceOf(owner.address);

            expect(finalOwnerBalance).to.equal(initialOwnerBalance.add(2000));

        });

        it("Should the contract account have 0 ART tokens", async function () {

            const contractBalance = await artArmyToken.balanceOf(artArmyStake.address);

            //console.log('Stake: '+stakeContractBalance.toString());
            //console.log('Owner: '+finalOwnerBalance.toString());

            expect(contractBalance).to.equal(0);

        });

        it("Should allowance to be 1000", async function () {

            const allowance = await artArmyToken.allowance(owner.address, artArmyStake.address);
            expect(allowance).to.equal(0);

        });
    });

    describe("getPlayer After remove Stake", function () {
        //this.timeout(10000);

        /*it('wait 10000', function(done){
                setTimeout(done, 2000);
            });*/

        it("Should time be not 0", async function () {

            const playerTime = await artArmyStake.getPlayerTime(owner.address);
            //console.log(playerTime);
            expect(playerTime).to.not.equal(0);

        });



        it("Should points be not 0", async function () {

            const playerPoints = await artArmyStake.getPlayerPoints(owner.address);
            console.log(playerPoints.toString());
            expect(playerPoints).to.not.equal(0);

        });
    });

    describe("Last getStake", function () {

        it("Should be 0 the getStake of the player, later the remove stake", async function () {

            const ownerStake = await artArmyStake.getStake(owner.address);
            expect(ownerStake).to.equal(0);

        });
    });






});
// We import Chai to use its asserting functions here.


const { expect } = require("chai");

// `describe` is a Mocha function that allows you to organize your tests. It's
// not actually needed, but having your tests organized makes debugging them
// easier. All Mocha functions are available in the global scope.



// `describe` receives the name of a section of your test suite, and a callback.
// The callback must define the tests of that section. This callback can't be
// an async function.
describe("ArtArmy General Testing", function () {
    // Mocha has four functions that let you hook into the the test runner's
    // lifecyle. These are: `before`, `beforeEach`, `after`, `afterEach`.

    // They're very useful to setup the environment for tests, and to clean it
    // up after they run.

    // A common pattern is to declare some variables, and assign them in the
    // `before` and `beforeEach` callbacks.

    let Token;
    let artArmyToken;
    let Stake;
    let artArmyStake;
    let owner;
    let addr1;
    let addr2;
    let addrs;



    // `beforeEach` will run before each test, re-deploying the contract every
    // time. It receives a callback, which can be async.
    it("Attach Contracts", async function () {

        [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

        Token = await ethers.getContractFactory("ArtArmyToken");
        Stake = await ethers.getContractFactory("ArtArmyStake");

        // To deploy our contract, we just have to call Token.deploy() and await
        // for it to be deployed(), which happens onces its transaction has been
        // mined.
        artArmyToken = await Token.deploy();
        artArmyStake = await Stake.deploy(artArmyToken.address);

    });

    // You can nest describe calls to create subsections.
    describe("Deployment", function () {
        // `it` is another Mocha function. This is the one you use to define your
        // tests. It receives the test name, and a callback function.

        // If the callback function is async, Mocha will `await` it.
        it("Should set the right owner", async function () {
            // Expect receives a value, and wraps it in an Assertion object. These
            // objects have a lot of utility methods to assert values.

            // This test expects the owner variable stored in the contract to be equal
            // to our Signer's owner.
            expect(await artArmyToken.owner()).to.equal(owner.address);
        });

        it("Should assign the total supply of tokens to the owner", async function () {
            const ownerBalance = await artArmyToken.balanceOf(owner.address);
            expect(await artArmyToken.totalSupply()).to.equal(ownerBalance);
        });

        it("Should be the name: Art Army Token", async function () {
            const name = await artArmyToken.name();
            expect(name).equal('Art Army Token');
        });

        it("Should be the symbol: ART", async function () {
            const symbol = await artArmyToken.symbol();
            expect(symbol).equal('ART');
        });
    });

    describe("Transactions", function () {
        it("Should transfer tokens between accounts", async function () {
            // Transfer 50 tokens from owner to addr1
            await artArmyToken.transfer(addr1.address, 50);
            const addr1Balance = await artArmyToken.balanceOf(addr1.address);
            expect(addr1Balance).to.equal(50);

            // Transfer 50 tokens from addr1 to addr2
            // We use .connect(signer) to send a transaction from another account
            await artArmyToken.connect(addr1).transfer(addr2.address, 50);
            const addr2Balance = await artArmyToken.balanceOf(addr2.address);
            expect(addr2Balance).to.equal(50);
        });

        it("Should return tokens the owner account", async function () {

            await artArmyToken.connect(addr2).transfer(owner.address, 50);
            const addr2Balance = await artArmyToken.balanceOf(addr2.address);
            expect(addr2Balance).to.equal(0);
        });

        it("Should fail if sender doesn’t have enough tokens", async function () {
            const initialOwnerBalance = await artArmyToken.balanceOf(owner.address);

            // Try to send 1 token from addr1 (0 tokens) to owner (1000 tokens).
            // `require` will evaluate false and revert the transaction.
            await expect(
                artArmyToken.connect(addr1).transfer(owner.address, 1)
            ).to.be.revertedWith("BEP20: transfer amount exceeds balance");

            // Owner balance shouldn't have changed.
            expect(await artArmyToken.balanceOf(owner.address)).to.equal(
                initialOwnerBalance
            );
        });

        it("Should update balances after transfers", async function () {
            const initialOwnerBalance = await artArmyToken.balanceOf(owner.address);

            // Transfer 100 tokens from owner to addr1.
            await artArmyToken.transfer(addr1.address, 100);

            // Transfer another 50 tokens from owner to addr2.
            await artArmyToken.transfer(addr2.address, 50);

            // Check balances.
            const finalOwnerBalance = await artArmyToken.balanceOf(owner.address);
            expect(finalOwnerBalance).to.equal(initialOwnerBalance.sub(150));

            const addr1Balance = await artArmyToken.balanceOf(addr1.address);
            expect(addr1Balance).to.equal(100);

            const addr2Balance = await artArmyToken.balanceOf(addr2.address);
            expect(addr2Balance).to.equal(50);
        });

        it("Should return tokens the owner account", async function () {
            await artArmyToken.connect(addr1).transfer(owner.address, 100);
            const addr1Balance = await artArmyToken.balanceOf(addr1.address);
            expect(addr1Balance).to.equal(0);

            await artArmyToken.connect(addr2).transfer(owner.address, 50);
            const addr2Balance = await artArmyToken.balanceOf(addr2.address);
            expect(addr2Balance).to.equal(0);
        });
    });

});
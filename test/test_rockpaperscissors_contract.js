const expectedExceptionPromise = require("./expected_exception_testRPC_and_geth.js");
const RockPaperScissors = artifacts.require('RockPaperScissors');
const Promise = require("bluebird");
const BigNumber = web3.BigNumber;

Promise.promisifyAll(web3.eth, { suffix: "Promise" });

contract('RockPaperScissors', function(accounts) {

    const alice = accounts[0];
    const bob = accounts[1];
    let rockPaperScissorsContract;

    beforeEach(function() {
      return RockPaperScissors.new({from: alice}).then(function(instance) {
        rockPaperScissorsContract = instance;
      });
    });

    it('should create game by hash', async function() {
        const hasedGameKey = await rockPaperScissorsContract.hashGameKey(alice, 1, '1qaz2wsx', {from: alice});
        let isExist = await rockPaperScissorsContract.gameIsExist(hasedGameKey, {from: alice});
        assert.equal(isExist, false);
        const txObj = await rockPaperScissorsContract.createGame(
            hasedGameKey,
            0,
            0,
            {
                from: alice,
                value: 50000000
            });
        isExist = await rockPaperScissorsContract.gameIsExist(hasedGameKey, {from: alice});
        assert.equal(isExist, true);
    });
});
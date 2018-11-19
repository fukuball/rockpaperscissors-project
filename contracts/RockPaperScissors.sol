pragma solidity ^0.4.23;

import "./SafeMath.sol";

contract RockPaperScissors {

    using SafeMath for uint256;
    using SafeMath for uint;

    enum Hand { NONE, ROCK, PAPER, SCISSORS }
    enum Outcome { NONE, PLAYER1WIN, PLAYER2WIN, DRAW }

    struct Game {
        // key: player1 + player1Move + nonce
        address player1;
        address player2;
        uint256 wager;
        uint    deadlineJoin;
        uint    deadlineReveal;
        Hand    player1Move;
        Hand    player2Move;
        bool    isExist;
        bool    isClaimed;
    }

    mapping(bytes32 => Game) games;
    mapping(address => uint256) balances;

    event LogWithdraw(address indexed sender, uint toWithdraw);

    constructor() public {
    }

    function createGame(bytes32 hasedGameKey, uint deadlineJoinMaxBlock, uint deadlineRevealMaxBlock)
        public
        payable
        returns (bool success) {

        require(msg.sender != 0);
        Game storage newGame = games[hasedGameKey];
        require(newGame.player1 == 0);
        assert(newGame.player2 == 0);
        assert(newGame.wager == 0);

        newGame.player1 = msg.sender;
        newGame.wager = msg.value;
        uint deadlineJoin = block.number.add(deadlineJoinMaxBlock);
        newGame.deadlineJoin = deadlineJoin;
        newGame.deadlineReveal = deadlineJoin.add(deadlineRevealMaxBlock);
        newGame.isExist = true;
        newGame.isClaimed = false;
        return true;
    }

    function joinGame(bytes32 hasedGameKey, Hand player2Move)
        public
        payable
        returns (bool success) {

        Game storage thisGame = games[hasedGameKey];
        require(thisGame.player1 != 0);
        require(thisGame.player2 == 0);
        require(thisGame.wager == msg.value);
        require(block.number <= thisGame.deadlineJoin);

        thisGame.player2 = msg.sender;
        thisGame.player2Move = player2Move;
        return true;
    }

    function revealGameResult(Hand player1Move, string nonce)
        public
        returns (Outcome outcome) {

        bytes32 hasedGameKey = hashGameKey(msg.sender, player1Move, nonce);
        Game storage thisGame = games[hasedGameKey];

        require(thisGame.isExist);
        require(! thisGame.isClaimed);
        require(thisGame.player2Move != Hand.NONE);
        require(thisGame.player1Move == Hand.NONE);
        require(block.number <= thisGame.deadlineReveal);

        thisGame.player1Move = player1Move;

        outcome = rockPaperScissorsCheck(thisGame.player1Move, thisGame.player2Move);

        thisGame.isClaimed = true;
        if (outcome == Outcome.DRAW) {
            balances[thisGame.player1] = balances[thisGame.player1].add(thisGame.wager);
            balances[thisGame.player2] = balances[thisGame.player2].add(thisGame.wager);
        } else if (outcome == Outcome.PLAYER1WIN) {
            balances[thisGame.player1] = balances[thisGame.player1].add(thisGame.wager.mul(2));
        } else if (outcome == Outcome.PLAYER2WIN) {
            balances[thisGame.player2] = balances[thisGame.player2].add(thisGame.wager.mul(2));
        }
    }

    function rockPaperScissorsCheck(Hand player1Move, Hand player2Move)
        pure public
        returns (Outcome outcome) {

        if (player1Move == player2Move) {
            return Outcome.DRAW;
        } else if (player1Move == Hand.ROCK && player2Move == Hand.PAPER) {
            return Outcome.PLAYER2WIN;
        } else if (player1Move == Hand.ROCK && player2Move == Hand.SCISSORS) {
            return Outcome.PLAYER1WIN;
        } else if (player1Move == Hand.PAPER && player2Move == Hand.ROCK) {
            return Outcome.PLAYER1WIN;
        } else if (player1Move == Hand.PAPER && player2Move == Hand.SCISSORS) {
            return Outcome.PLAYER2WIN;
        } else if (player1Move == Hand.SCISSORS && player2Move == Hand.ROCK) {
            return Outcome.PLAYER2WIN;
        } else if (player1Move == Hand.SCISSORS && player2Move == Hand.PAPER) {
            return Outcome.PLAYER1WIN;
        }
    }

    function hashGameKey(address player1, Hand player1Move, string nonce)
        // Yes view because that would be silly to expose your data with a dedicated transaction.
        view public
        returns(bytes32 hash) {
        return keccak256(abi.encodePacked(this, player1, player1Move, nonce));
    }

    function claimUnplayed(bytes32 hasedGameKey)
        public
        returns (bool success) {

        Game storage thisGame = games[hasedGameKey];

        require(thisGame.deadlineJoin < block.number);
        require(thisGame.player2 == 0);

        uint wager = thisGame.wager;
        thisGame.wager = 0;
        balances[thisGame.player1] = balances[thisGame.player1].add(wager);

        return true;
    }

    function claimForfeited(bytes32 hasedGameKey)
        public
        returns (bool success) {

        Game storage thisGame = games[hasedGameKey];

        require(thisGame.deadlineReveal < block.number);
        require(thisGame.player1Move == Hand.NONE);

        uint wager = thisGame.wager;
        thisGame.wager = 0;
        balances[thisGame.player2] = balances[thisGame.player2].add(wager.mul(2));

        return true;

    }

    function withdraw() public returns(bool isSuccess) {
        uint256 toWithdraw = balances[msg.sender];
        require(toWithdraw > 0, "no balance");
        balances[msg.sender] = 0;
        msg.sender.transfer(toWithdraw);
        emit LogWithdraw(msg.sender, toWithdraw);
        return true;
    }

    function balanceOf(address recipient) public view returns(uint256) {
        return balances[recipient];
    }
}
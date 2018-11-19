pragma solidity ^0.4.23;

import "./SafeMath.sol";

contract RockPaperScissors {

    enum Hand { NONE, ROCK, PAPER, SCISSORS }

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
        payable
        returns (bool success) {

        require(msg.sender != 0);
        Game newGame = games[hasedGameKey];
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
        payable
        returns (bool success) {

        Game thisGame = games[hasedGameKey];
        require(thisGame.player1 != 0);
        require(thisGame.wager == msg.value);
        require(block.number <= thisGame.deadlineJoin);

        thisGame.player2 = msg.sender;
        thisGame.player2Move = player2Move;
        return true;
    }

    function revealGameResult(Hand player1Move, bytes32 nonce)
        returns (string outcome) {

        bytes32 hasedGameKey = hashGameKey(msg.sender, player1Move, nonce);
        Game thisGame = games[hasedGameKey];

        require(thisGame.isExist);
        require(! thisGame.isClaimed);
        require(thisGame.player2Move != Hand.NONE);
        require(thisGame.player1Move == Hand.NONE);
        require(block.number <= thisGame.deadlineReveal);

        thisGame.player1Move = player1Move;

        string outcome = rockPaperScissorsCheck(thisGame.player1Move, thisGame.player2Move);

        thisGame.isClaimed = true;
        if (outcome == 'draw') {
            balances[thisGame.player1] = thisGame.wager;
            balances[thisGame.player2] = thisGame.wager;
        } else if (outcome == 'player1_win') {
            balances[thisGame.player1] = thisGame.wager.mul(2);
        } else if (outcome == 'player2_win') {
            balances[thisGame.player2] = thisGame.wager.mul(2);
        }

        return outcome;
    }

    function rockPaperScissorsCheck(Hand player1Move, Hand player2Move)
        view public
        returns (string outcome) {

        if (player1Move == player2Move) {
            return 'draw';
        } else if (player1Move == Hand.ROCK && player2Move == Hand.PAPER) {
            return 'player2_win';
        } else if (player1Move == Hand.ROCK && player2Move == Hand.SCISSORS) {
            return 'player1_win';
        } else if (player1Move == Hand.PAPER && player2Move == Hand.ROCK) {
            return 'player1_win';
        } else if (player1Move == Hand.PAPER && player2Move == Hand.SCISSORS) {
            return 'player2_win';
        } else if (player1Move == Hand.SCISSORS && player2Move == Hand.ROCK) {
            return 'player2_win';
        } else if (player1Move == Hand.SCISSORS && player2Move == Hand.PAPER) {
            return 'player1_win';
        }
    }

    function hashGameKey(address player1, Hand player1Move, string nonce)
        // Yes view because that would be silly to expose your data with a dedicated transaction.
        view public
        returns(bytes32 hash) {
        return keccak256(abi.encodePacked(this, player1, player1Move, nonce));
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
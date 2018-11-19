# RockPaperScissors Project

## What

You will create a smart contract named RockPaperScissors whereby:

- Alice and Bob play the classic rock paper scissors game.
- to enrol, each player needs to deposit the right Ether amount, possibly zero.
- to play, each player submits their unique move.
- the contract decides and rewards the winner with all Ether wagered.
- Of course there are many ways to implement it so we leave to yourselves to invent.

How can this be the 3rd project and not the 1st?? Try.

Stretch goals:

- make it a utility whereby any 2 people can decide to play against each other.
- reduce gas costs as much as you can.
- let players bet their previous winnings.
- how can you entice players to play, knowing that they may have their funding stuck in the contract if they faced an uncooperative player?

## Install

```
$ npm install
```

## Compile

```
$ ./node_modules/.bin/truffle compile
```

## Migrate

```
$ ./node_modules/.bin/truffle migrate
```

## Run Test

```
$ npm test test/test_hello_standalone.js
```

or

```
$ ./node_modules/.bin/truffle migrate
``

## Create GUI

```
$ mkdir -p app/js
$ touch app/js/app.js
$ ./node_modules/.bin/create-html --title "Hello World" --script "js/app.js" --output app/index.html
```

## Bulid Dapp

```
$ ./node_modules/.bin/webpack-cli --mode development
```

## Run Dapp

On terminal 1

```
$ ganache-cli
```

On terminal 2

```
$ truffle migrate
$ cd dapp
$ ln -s ../build/contracts contracts
$ cd ..
$ php -S 0.0.0.0:8000 -t dapp/
```

Open browser to: http://localhost:8000/

# Appendix

## Useful Command

```
$ ./node_modules/.bin/truffle version
$ ./node_modules/.bin/truffle init
$ ./node_modules/.bin/truffle compile
$ ./node_modules/.bin/truffle test
$ ./node_modules/.bin/truffle migrate
```

## Truffle init

```
$ mkdir temp_unbox
$ cd temp_unbox
$ ../node_modules/.bin/truffle init
$ mv * ..
$ cd ..
$ rmdir temp_unbox
```

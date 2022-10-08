import {loadStdlib} from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';
const stdlib= loadStdlib();

const startingBalance= stdlib.parseCurrency(100);

const [ accAlice, accBob ]= await stdlib.newTestAccounts(2, startingBalance);
const formatBalance = (x) => stdlib.formatCurrency(x, 0);
const getBalance = async (who) => formatBalance(await stdlib.balanceOf(who));

// get the balance before the game starts for both Alice and Bob
const beforeAlice = await getBalance(accAlice);
const beforeBob = await getBalance(accBob);

const ctcAlice = accAlice.contract(backend);
const ctcBob = accBob.contract(backend, ctcAlice.getInfo());


const HAND = ['Rock', 'Paper', 'Scissors'];
const OUTCOME = ['Bob wins', 'Draw', 'Alice wins'];

const Player = (playerName)=> ({
  ...stdlib.hasRandom, // <--- new!
  getHand: () => {
    const hand = Math.floor(Math.random() * 3);
    console.log(`${playerName} played ${HAND[hand]}`);
    return hand;
  },

  seeOutcome: (outcome) => {
    console.log(`${playerName} saw outcome ${OUTCOME[outcome]}`);
  },
})

// backend initialization
await Promise.all([
  backend.Alice(ctcAlice, {
    ...Player("Alice"), // call line 22
    wager: stdlib.parseCurrency(5),
  }),

  backend.Bob(ctcBob, {
    ...Player("Bob"),
    acceptWager: (amount) => {
      console.log(`Bob accepts the wager of ${formatBalance(amount)}.`);
    },
  }),
]);

const afterAlice = await getBalance(accAlice);
const afterBob = await getBalance(accBob);

console.log(`Alice went from ${beforeAlice} to ${afterAlice}.`);
console.log(`Bob went from ${beforeBob} to ${afterBob}.`);


/*
DRAW
Alice played Scissors
Bob accepts the wager of 5.
Bob played Scissors
Alice went from 100 to 99.996.
Bob went from 100 to 99.995.
*/
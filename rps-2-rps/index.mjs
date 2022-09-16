// frontend
// backend.rsh has to be same naming with frontend.mjs

import {loadStdlib} from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';
// loads the standard library dynamically based on the REACH_CONNECTOR_MODE environment variable
const stdlib = loadStdlib(); 

const startingBalance= stdlib.parseCurrency(100);
const [ accAlice, accBob ]= await stdlib.newTestAccounts(2, startingBalance);

console.log('Launching...');

// Alice deploy the application
// Alice goes first
const ctcAlice = accAlice.contract(backend);

// has Bob attach to Alice's contract
const ctcBob = accBob.contract(backend, ctcAlice.getInfo());

console.log('Starting backends...');

const HAND = ['Rock', 'Paper', 'Scissors'];
const OUTCOME = ['Bob wins', 'Draw', 'Alice wins'];

const Player = (playerName) => ({
  getHand: () => {
    const hand = Math.floor(Math.random() * 3);
    console.log(`${playerName} played ${HAND[hand]}`);
    return hand;
  },

  seeOutcome: (outcome) => {
    console.log(`${playerName} saw outcome ${OUTCOME[outcome]}`);
  },
});

// backend initialization
await Promise.all([
  // backend.Alice(ctcAlice, {
  // }),

  ctcAlice.p.Alice({
    ...Player("Alice")

  }),
  ctcBob.p.Bob({
    ...Player("Bob")

  }),

]);

console.log('Goodbye, Alice and Bob!');

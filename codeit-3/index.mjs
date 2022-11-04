import { loadStdlib } from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';
const stdlib = loadStdlib();

const startingBalance = stdlib.parseCurrency(100);

const [accCarla, accEve] = await stdlib.newTestAccounts(2, startingBalance);
const formatBalance = (x) => stdlib.formatCurrency(x, 0);
const getBalance = async (who) => formatBalance(await stdlib.balanceOf(who));

// get the balance before the game starts for both Carla and Eve
const beforeCarla = await getBalance(accCarla);
const beforeEve = await getBalance(accEve);

const ctcCarla = accCarla.contract(backend);
const ctcEve = accEve.contract(backend, ctcCarla.getInfo());

const OUTCOME = ['Carla wins', 'Eve wins', 'Draw', 'No wins']; // represent the index of outcome from line 31  
const Player = (playerName) => ({
  ...stdlib.hasRandom, // <--- new!
  ...stdlib.hasConsoleLogger,
  
  computeNumber: () => {
    const secretNumber = Math.floor(Math.random() * 10);
    console.log(`${playerName} commit secret number: ${secretNumber}`);
    return secretNumber;
  },

  seeOutcome: (outcome) => {
    console.log(`${playerName} saw outcome ${OUTCOME[outcome]}`);
  },
})

// backend initialization
await Promise.all([
  backend.Carla(ctcCarla, {
    ...Player("Carla"), // call line 22
    wager: stdlib.parseCurrency(5),
  }),

  backend.Eve(ctcEve, {
    ...Player("Eve"),
    acceptWager: (amount) => {
      console.log(`Eve accepts the wager of ${formatBalance(amount)}.`);
    },
  }),
]);

const afterCarla = await getBalance(accCarla);
const afterEve = await getBalance(accEve);

console.log(`Carla went from ${beforeCarla} to ${afterCarla}.`);
console.log(`Eve went from ${beforeEve} to ${afterEve}.`);

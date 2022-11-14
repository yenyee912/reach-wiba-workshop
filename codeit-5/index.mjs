import { loadStdlib } from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';
const stdlib = loadStdlib(process.env);

const startingBalance = stdlib.parseCurrency(100);
const accAlice = await stdlib.newTestAccount(startingBalance);
const accBob = await stdlib.newTestAccount(startingBalance);

const fmt = (x) => stdlib.formatCurrency(x, 4);
const getBalance = async (who) => fmt(await stdlib.balanceOf(who));
const beforeAlice = await getBalance(accAlice);
const beforeBob = await getBalance(accBob);

const ctcAlice = accAlice.contract(backend);
const ctcBob = accBob.contract(backend, ctcAlice.getInfo());

const fortuneList = ['GOOD_DAY', 'BAD_DAY', 'SOSO_DAY'];
const decisionList = ['ACCEPT', 'REJECT']; // true or false

const Player = (Who) => ({
  ...stdlib.hasRandom,

  seeOutcome: (outcome) => {
    console.log(`${Who} saw outcome ${decisionList[outcome]}`);
  },
  informTimeout: () => {
    console.log(`${Who} observed a timeout`);
  },
});

await Promise.all([
  ctcAlice.p.Alice({
    ...Player('Alice'),
    wager: stdlib.parseCurrency(10),
    deadline: 10,
    acceptFortune: (fortune)=>{
      const decisionIndex = Math.floor(Math.random() * 2);
      console.log(`Alice ${decisionList[decisionIndex]} the fortune `);

      return decisionIndex
    }
    
  }),

  ctcBob.p.Bob({
    ...Player('Bob'),
    readFortune: () => {
      const fortuneIndex = Math.floor(Math.random() * 3);
      console.log(`Bob read fortune: ${fortuneList[fortuneIndex]}`);
      return fortuneIndex;
    },

  }),
]);

const afterAlice = await getBalance(accAlice);
const afterBob = await getBalance(accBob);

console.log(`Alice went from ${beforeAlice} to ${afterAlice}.`);
console.log(`Bob went from ${beforeBob} to ${afterBob}.`);
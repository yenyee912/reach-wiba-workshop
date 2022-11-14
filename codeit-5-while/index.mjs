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

const fortuneList = ['GOOD DAY', 'BAD DAY', 'SOSO DAY'];
const decisionList = ['ACCEPT', 'REJECT']; // true or false

const Player = (Who) => ({
  ...stdlib.hasRandom,
  informTimeout: () => {
    console.log(`${Who} observed a timeout`);
  },
});

await Promise.all([
  ctcAlice.p.Alice({
    ...Player('Alice'),
    fortunePrice: stdlib.parseCurrency(10),
    getDecision: ()=>{
      const decisionIndex = Math.floor(Math.random() * 2);
      console.log(`Alice ${decisionList[decisionIndex]} the fortune `);
      return decisionIndex
    },
    showFortune: (fortuneFromBob) => {
      console.log(`Alice see Bob tell today is a ${fortuneList[fortuneFromBob]}.`);
    },

    
  }),

  ctcBob.p.Bob({
    ...Player('Bob'),
    readFortune: () => {
      const fortuneIndex = Math.floor(Math.random() * 3);
      console.log(`Bob read fortune that today is a ${fortuneList[fortuneIndex]}`);
      return fortuneIndex;
    },
    acceptFortunePrice: (price)=>{
      console.log(`Bob accpet the price: ${price}.`);
    },
    showDecision: (decisionFromAlice) => {
      console.log(`Bob see Alice ${decisionList[decisionFromAlice]} the fortune he read.`);
    },

  }),
]);

const afterAlice = await getBalance(accAlice);
const afterBob = await getBalance(accBob);

console.log(`Alice went from ${beforeAlice} to ${afterAlice}.`);
console.log(`Bob went from ${beforeBob} to ${afterBob}.`);
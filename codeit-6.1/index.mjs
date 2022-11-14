import { loadStdlib, ask } from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';
const stdlib = loadStdlib(process.env);
const startingBalance = stdlib.parseCurrency(1000);

const isAlice = await ask.ask(
  `Are you Alice?`,
  ask.yesno
);
const who = isAlice ? 'Alice' : 'Bob';
console.log(`Fortune Teller game as ${who}`);

let acc = null;
acc = await stdlib.newTestAccount(startingBalance);

let ctc= null;
if (isAlice) {
  ctc = acc.contract(backend);
  ctc.getInfo().then((info) => {
    console.log(`The contract is deployed as = ${JSON.stringify(info)}`);
  });
} 
else { // Bob
  const info = await ask.ask(
    `Please paste the contract information:`,
    JSON.parse
  );
  ctc = acc.contract(backend, info);
}
const fmt = (x) => stdlib.formatCurrency(x, 4);
const getBalance = async () => fmt(await stdlib.balanceOf(acc));

let balanceBefore = await getBalance();
console.log(`Your balance is ${balanceBefore}`);

const fortuneList = ['GOOD DAY', 'BAD DAY', 'SOSO DAY'];
const decisionList = ['ACCEPT', 'REJECT']; // true or false

const interact = { ...stdlib.hasRandom };

if (isAlice) {
  const amt = await ask.ask(
    `How much do you want to fortune price to be?`,
    stdlib.parseCurrency
  );
  interact.fortunePrice = amt;

  interact.getDecision= async() => {
    let decisionIndex = -1;
    let decision= await ask.ask(
      `Do you accept the fortune?`,
      ask.yesno
    )

    if (decision)
      decisionIndex= 0;
    else
      decisionIndex= 1;
      
    console.log(`Alice ${decisionList[decisionIndex]} the fortune `);
    return decisionIndex
  };
    
  interact.showFortune= (fortuneFromBob) => {
      console.log(`Alice see Bob tell today is a ${fortuneList[fortuneFromBob]}.`);
  };
} 

else {
  interact.acceptFortunePrice = async (amt) => {
    const accepted = await ask.ask(
      `Do you accept the fortune price of ${fmt(amt)}?`,
      ask.yesno
    );
    if (!accepted) {
      process.exit(0);
    }
  };
  interact.readFortune = async () => {
    const fortuneIndex = await ask.ask(`What fortune will you read?`, (x) => {
      const fate = parseInt(x);
      if (fate === undefined || x<0 || x>2) {
        throw Error(`Not a valid fortune.`);
      }
      return fate;
    });
    console.log(`Bob read fortune that today is a ${fortuneList[fortuneIndex]}`);
    return fortuneIndex;
  };

}

const part = isAlice ? ctc.p.Alice : ctc.p.Bob;
await part(interact);
const balanceAfter = await getBalance();
console.log(`Your balance is now ${balanceAfter}`);

ask.done();
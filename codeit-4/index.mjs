import { loadStdlib } from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';
const stdlib = loadStdlib(process.env);

const startingBalance = stdlib.parseCurrency(100);
const accAlice = await stdlib.newTestAccount(startingBalance);
const accEve = await stdlib.newTestAccount(startingBalance);

const ctcAlice = accAlice.contract(backend);
const ctcEve = accEve.contract(backend, ctcAlice.getInfo());

const Player = (Who) => ({
  timeExpiration: () => {
    console.log(`${Who} observed a timeout.`);
  },

});

let randNum= 3;
await Promise.all([
  ctcAlice.p.Alice({
    ...Player('Alice'),
    deadline: 10,
  }),

  ctcEve.p.Eve({
    ...Player('Eve'),
    getCallLog: async()=> { // <-- async now
      if (Math.random() <= 0.5) {
        for (let i = 0; i < 10; i++) { // delay a ten time
          console.log(`Eve takes her sweet time...`);
          await stdlib.wait(1);
        }
      } 
      
      else {
        console.log("Eve reveal callLog...")
      }
    },

    computeNumber: async()=>{
      return 4;
    }
  }),
]);

// const afterAlice = await getBalance(accAlice);
// const afterEve = await getBalance(accEve);

// console.log(`Alice went from ${beforeAlice} to ${afterAlice}.`);
// console.log(`Eve went from ${beforeEve} to ${afterEve}.`);
import {loadStdlib} from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';
const stdlib = loadStdlib();

const startingBalance = stdlib.parseCurrency(1000);

const [ accAlice, accBob ] = await stdlib.newTestAccounts(2, startingBalance);

const ctcAlice = accAlice.contract(backend);
const ctcBob = accBob.contract(backend, ctcAlice.getInfo());

const formatBalance = (x) => stdlib.formatCurrency(x, 3);

const getBalance = async (who) => formatBalance(await stdlib.balanceOf(who));
const balanceAlice = await getBalance(accAlice);
const balanceBob = await getBalance(accBob);

const Player = (playerName) => ({
  printBalance: async () => {
    let balance= 0
    if (playerName== "Alice")
      balance= balanceAlice;
    
    else
      balance= balanceBob;

    console.log(`${playerName} balance: ${balance}`);
  },
})

await Promise.all([
  backend.Alice(ctcAlice, {
    ...Player("Alice")
    

  }),
  backend.Bob(ctcBob, {
    ...Player("Bob")
  }),
]);

console.log('Goodbye, Alice and Bob!');

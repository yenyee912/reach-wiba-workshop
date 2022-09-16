import {loadStdlib} from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';
const stdlib = loadStdlib(process.env);

const startingBalance = stdlib.parseCurrency(100);

const [ accPat, accVanna ] = await stdlib.newTestAccounts(2, startingBalance);
const [accBuyer, accBidder] = await stdlib.newTestAccounts(2, startingBalance);
const formatBalance = (x) => stdlib.formatCurrency(x, 0);


console.log('Launching...');
const ctcPat = accPat.contract(backend);
const ctcVanna = accVanna.contract(backend, ctcPat.getInfo());

const ctcBuyer = accBuyer.contract(backend, ctcPat.getInfo());
const ctcBidder = accBidder.contract(backend, ctcPat.getInfo());

console.log('Starting backends...');

// try to figure out non arrow function syntax
const role_1 = (playerName) => ({
  getChallenge: () => {
    console.log(`${playerName} received.`)
    
    return 1; //return integer
  },

  seeResult: (result) => {
    console.log(`${playerName}'s result= ${result}.`)
  },
})

const role_2 = (playerName) => ({
  seePrice: () => {
    let currentPrice= parseInt(Math.random()*3)
    console.log(`Current price is ${currentPrice} ALGO.`)
    
    return currentPrice;
  },

  getDescription: () => {
    let x= ""
    if (playerName== "Buyer"){
      // x= `${playerName} is a person who buy.`
      x= "a" //return what actually doesn't matter if you only want to print sth
      console.log(`${playerName} is a person who buy.`)
    }

    else {
      // x = `${playerName} not buyer.`
      x="b"
      console.log(`${playerName} not buyer.`)
    }

    return x
  },
})


await Promise.all([
  backend.Pat(ctcPat, {
    ...role_1("Pat")


  }),

  backend.Vanna(ctcVanna, {
    ...role_1("Vanna")
  }),

  backend.Buyer(ctcBuyer, {
    ...role_2("Buyer")
  }),

  backend.Bidder(ctcBidder, {
    ...role_2("Bidder")
  }),
]);


import { loadStdlib } from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';

const stdlib = loadStdlib();
// const assertEq = (expected, actual) => {
//   const exps = JSON.stringify(expected);
//   const acts = JSON.stringify(actual);
//   console.log('assertEq', { expected, actual }, { exps, acts });
//   stdlib.assert(exps === acts)
// };

const secret1 = "destroy planet focus used group inform thrive market page motor injury jeans bundle habit want virtual sibling repair lesson snake trade memory range abstract wood"
const secret2 = "any winner laugh loop unfair pipe shift endless trend bring depth delay entry rose silk sight decorate arm sunset seat gain history sadness absorb talk"

const startingBalance = stdlib.parseCurrency(100);
const [accAlice, accBob] = await Promise.all([
  stdlib.newTestAccount(startingBalance),  
  stdlib.newTestAccount(startingBalance)
]);
accAlice.setDebugLabel('Alice');
accBob.setDebugLabel('Bob');
const ctcAlice = accAlice.contract(backend);
const ctcBob = accBob.contract(backend, ctcAlice.getInfo());

const checkView = async (x, who, fe, ge) => {
  console.log('----------checkView-------',) 
  console.log("x: ", x);
  console.log("who: ", who);
  console.log("address: " ,stdlib.formatAddress(who))
  console.log("fe: ", fe) 
  console.log("ge: " ,ge);
  // assertEq(fe, await ctcAlice.v.Main.f(who));
  // assertEq(ge, await ctcAlice.v.Main.g(who));
};

await Promise.all([
  console.log("-------execution-----"),
  backend.Alice(ctcAlice, { checkView }),
  backend.Bob(ctcBob, { checkView }),
]);
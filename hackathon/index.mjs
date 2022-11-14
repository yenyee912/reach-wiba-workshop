import { loadStdlib, ask } from "@reach-sh/stdlib";
import * as backend from "./build/index.main.mjs";
const stdlib = loadStdlib(process.env);


let role = await ask.ask(`Are you Warehouse?`, ask.yesno);
let playerName = role ? "Warehouse" : "Factory";

const secret1 = process.env.VUE_APP_SECRET_1;
const secret2 = process.env.VUE_APP_SECRET_2;

var metadata = {};
const accFactory = await stdlib.newAccountFromMnemonic(secret1);
const accWarehouse = await stdlib.newAccountFromMnemonic(secret2);

if (playerName == "Factory") { // factory deploy contract
  const factoryInteract = {
    ...commonInteract,
    deadline: 100,
  }

  // const accFactory = await stdlib.newAccountFromMnemonic(secret1);
  const ctcfactory = accFactory.contract(backend);

  ctcfactory.getInfo().then((info) => {
    console.log(`The contract is deployed as = ${JSON.stringify(info)}. Ask the warehouse to attach.`);
  });

  await ctcfactory.p.Factory(factoryInteract);
}

else if (playerName == "Warehouse") {
  const warehouseInteract = {
    ...commonInteract,
    getMetadata: ()=>{

      metadata = {
        supplierID: "Cx111",
        supplierName: "Company A",
        timestamp: "202210100733",
        staffID: "Sx111",
        staffName: "Ali",
        materialID: "Mx111",
        materialName: "Wheat- brand A",
        batchNumber: "1", // one batch + id= one contract  
        quantity: 60,
      }

      return metadata

    },

  }
  // const accWarehouse = await stdlib.newAccountFromMnemonic(secret2);
  const info = await ask.ask("Paste contract info for the targeted factory:  ", (s) => JSON.parse(s));
  const ctcWarehouse = accWarehouse.contract(backend, info);
  await ctcWarehouse.p.Warehouse(warehouseInteract);

  ask.done();
    // stdlib.transfer(from: Account, to: Account | Address, amount, token?: Token, opts?: TransferOpts) => Promise<void>

  stdlib.transfer(accWarehouse, accFactory, stdlib.parseCurrency(0.01), {opts: metadata});

}






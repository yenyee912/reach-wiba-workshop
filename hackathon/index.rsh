'reach 0.1';

const commonInteract = {
  informTimeout: Fun([], Null),

  //inventory: UInt,
  // reportInventory: Fun([], UInt) // input:warehouse/ factory (0/ 1), get stock level?
};

const warehouseInterect = {
  ...commonInteract,
  deadline: UInt,
  getMetadata: Fun([], Bytes(1000)), // max of note in algo

  // metadata which to be push to blockchain
  // supplierID: Bytes(100),
  // supplierName: Bytes(100),
  // timestamp: Bytes(100),
  // staffID: Bytes(100),
  // staffName: Bytes(100),
  // materialID: Bytes(100),
  // materialName: Bytes(100),
  // batchNumber: Bytes(100), // one batch + id= one contract  
  // quantity: UInt,

}

const facoryInteract = {
  ...commonInteract,  
}

export const main = Reach.App(() => {
  const Warehouse = Participant("Warehouse", warehouseInterect);
  const Factory = Participant("Factory", facoryInteract);
  init();

  const informTimeout = () => {
    each([Warehouse, Factory], () => {
      interact.informTimeout();
    });
  };

  Warehouse.only(() => {
    const deadline = declassify(interact.deadline);

    // const supplierID = declassify(interact.supplierID);
    // const supplierName = declassify(interact.supplierName);
    // const timestamp = declassify(interact.timestamp);
    // const staffID = declassify(interact.staffID);
    // const staffName = declassify(interact.staffName);
    // const materialID = declassify(interact.materialID);
    // const materialName = declassify(interact.materialName);
    // const batchNumber = declassify(interact.batchNumber);    
    // const quantity = declassify(interact.quantity);

    const metadata = declassify(interact.getMetadata())

  });
  
  Warehouse.publish(deadline, metadata)
  commit();

  // const warehouseInventory= inventory- quantity;
  // const factoryInventory = inventory + quantity;

  // each([Warehouse, Factory], () => {
  //   interact.reportInventory(inv);
  // });

  // transfer(1).to(Factory);
  // transfer(1).to(Warehouse);

});

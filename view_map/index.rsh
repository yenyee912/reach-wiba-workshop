'reach 0.1';

// const MUInt = Maybe(UInt);
// const MMUInt = Maybe(MUInt);
const Common = { 
  // checkView: Fun([UInt, Address, MMUInt, MUInt], Null) 
  checkView: Fun([UInt, Address], Null) 

};

export const main = Reach.App(() => {
  setOptions({ untrustworthyMaps: true });
  const A = Participant('Alice', Common);
  const B = Participant('Bob', Common);
  
  const vMain = View('Main', {
    // f: Fun([Address], UInt),
    // g: Fun([Address], UInt),
    number: UInt

  });
  init();
  A.publish(); 
  commit();

  // initialize some value
  A.only(() => interact.checkView(0, this));

  A.publish();
  
  const intM = new Map(UInt);
  // vMain.f.set((a) => intM[a]); // update value
  // vMain.g.set((a) => fromSome(intM[a], 0));
  vMain.number.set();
  
  const doneCheck = (x, who) => {
    const z = intM[who];
    A.interact.checkView(x, who);
  };
  
  const failCheck = (x, who) =>{
    B.interact.checkView(x, who);
  };

  doneCheck(1, A);
  commit();

  A.publish();
  commit();

  B.publish();

  intM[A] = 0;
  doneCheck(2, A);
  doneCheck(3, B);
  commit();

  A.publish();
  intM[B] = 1;
  doneCheck(4, A); // NEW BIG NUMBER, NEW A
  doneCheck(5, B);
  commit();

  A.publish();
  intM[A] = 2;
  doneCheck(6, A);
  doneCheck(7, B);
  commit();

  A.publish();
  delete intM[A];
  doneCheck(8, A);
  doneCheck(9, B);
  commit();

  A.publish();
  commit();

  failCheck(10, A); // done by B
  failCheck(11, B);
  exit();

  /* 
  checkView BigNumber { _hex: '0x00', _isBigNumber: true } 
  0xf66af0f6f64ee39d753c575e39b4fcf0e5d50f68636536bda57fffef049ff1bb 
  6ZVPB5XWJ3RZ25J4K5PDTNH46DS5KD3IMNSTNPNFP7766BE76G5W3TS4XE 
  [ 'None', null ] [ 'None', null ]
  
  */
});
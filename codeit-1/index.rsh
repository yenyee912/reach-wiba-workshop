"reach 0.1";

const role_1= {
  getChallenge: Fun([], UInt),
  seeResult: Fun([UInt], Null),

}

const role_2= {
  seePrice: Fun([], UInt),
  getDescription: Fun([], Bytes(1))
}

export const main = Reach.App(() => {
  // private data definition
  const Pat = Participant("Pat", {
    ...role_1
  });

  const Vanna = Participant("Vanna", {
    ...role_1,
  });

  const Creator = Participant("Creator", {
    // ...role_2
  });

  const Bidder = Participant("Bidder", {
    ...role_2

  });

  const Buyer = Participant("Buyer", {
    ...role_2,


  });
  
  init();

  Pat.only(()=>{
    const challengePat = declassify(interact.getChallenge());
  })
  Pat.publish(challengePat);
  commit();

  Vanna.only(() => {
    const challengeVanna = declassify(interact.getChallenge());
  })
  Vanna.publish(challengeVanna);
  commit();

  // to write your next .publish(), must return the control to local again--> .commit()
  Bidder.only(() => {
    const price= declassify(interact.seePrice());
    // cannot bound twice, if wanna both share same function, write into independent role
    // const description = declassify(interact.getDescription());

  })
  Bidder.publish(price); 
  commit();

  Buyer.only(() => {
    const description = declassify(interact.getDescription());

  })
  Buyer.publish(description, payment).pay(payment); 
  commit();

  exit();
});

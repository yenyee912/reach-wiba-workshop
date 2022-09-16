// backend

'reach 0.1';

// define a participant interact interface that will be shared between the two players
const Player= {
  getHand: Fun([], UInt),
  seeOutcome: Fun([UInt], Null)
}


export const main = Reach.App(() => {
  const A = Participant('Alice', {
    ...Player
  });

  const B = Participant('Bob', {
    ...Player
  });

  init();

  A.only(() => {
    const handAlice = declassify(interact.getHand());
  });

  // The first one to publish deploys the contract
  A.publish(handAlice);
  commit();
  
  // The second one to publish always attaches
  B.only(() => {
    const handBob = declassify(interact.getHand());
  });
  B.publish(handBob);

  const outcome = (handAlice + (4 - handBob)) % 3;
  
  each([A, B], () => {
    interact.seeOutcome(outcome);
  });

  commit();
  exit();
  

  // write your program here  commit();

});

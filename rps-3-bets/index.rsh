'reach 0.1';

const Player = {
  getHand: Fun([], UInt),
  seeOutcome: Fun([UInt], Null),
};

export const main = Reach.App(() => {
  const A = Participant('Alice', {
    ...Player,
    wager: UInt
  });

  const B = Participant('Bob', {
    ...Player,
    acceptWager: Fun([UInt], Null),
  });

  init();

  // local step --> individual participants can act alone.
  A.only(()=>{
    // declassify make Alice shares the wager amount with Bob
    const wager = declassify(interact.wager);
    const handAlice = declassify(interact.getHand());
  });

  // Alice join the application by publishing the value to the consensus network,
  // the code is in a "consensus step" where all participants act together.
  A.publish(wager, handAlice).pay(wager);

  // commits the state of the consensus network and returns to "local step"
  commit();
  
  B.only(()=>{
    interact.acceptWager(wager);
    const handBob = declassify(interact.getHand());  
  })
  
  B.publish(handBob).pay(wager);


  // game logic

  const x = (handAlice + (4 - handBob)) % 3;

  // if outcome=2, Alice win, then she will take all wager (2 portion)
  // if outcome=0, Bob win, then Alice need to pay back 50% of wager back to Bob
  // [2:0] and [1,1] are wager ratio
  const [forAlice, forBob] = x == 2 ? [2, 0] : x == 0 ? [0, 2] : [1, 1];
  transfer(forAlice * wager).to(A);
  transfer(forBob * wager).to(B);
  
  commit();

  exit();
});

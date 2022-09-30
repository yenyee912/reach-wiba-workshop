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

  unknowable(B, A(handAlice)); //ensure program will reject every version of dishonest Bob
  // A knowledge assertion that the participant 'Notter'-Bob, does not know the results of the variables var_0 through var_N,
  // but that the participant Knower-Alice does know those values.
  // It accepts an optional bytes argument, which is included in any reported violation.
  // so in this tutorial, it will generate error message such:  Bob knows of handAlice/81 because it is published.
  
  B.only(()=>{
    interact.acceptWager(wager);
    const handBob = declassify(interact.getHand());  
    // const handBob = (handAlice + 1) % 3; // dishonest version of Bob
    // Bob never consults the frontend, handBob always refer to handAlice

  })
  
  B.publish(handBob).pay(wager);


  // game logic

  const x = (handAlice + (4 - handBob)) % 3;
  
  // verify game theorem
  // require(handBob == (handAlice + 1) % 3);
  // assert(x == 0);

  // if outcome=2, Alice win, then she will take all wager (2 portion)
  // if outcome=0, Bob win, then Alice need to pay back 50% of wager back to Bob
  // [2:0] and [1,1] are wager ratio
  const [forAlice, forBob] = x == 2 ? [1, 0] : x == 0 ? [0, 2] : [1, 1];
  transfer(forAlice * wager).to(A);
  transfer(forBob * wager).to(B);
  
  commit();

  exit();
});

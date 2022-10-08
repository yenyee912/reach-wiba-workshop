'reach 0.1';

const Player = {
  ...hasRandom, // <--- new!
  getHand: Fun([], UInt),
  seeOutcome: Fun([UInt], Null),
};

const [isHand, ROCK, PAPER, SCISSORS] = makeEnum(3);
const [isOutcome, B_WINS, DRAW, A_WINS] = makeEnum(3);

const winner = (handAlice, handBob) => ((handAlice + (4 - handBob)) % 3);

// winner (A_hand, B_hand)--> see previous line
assert(winner(ROCK, PAPER) == B_WINS);
assert(winner(PAPER, ROCK) == A_WINS);

// whenever the same value is provided for both hands, winner return DRAW
assert(winner(ROCK, ROCK) == DRAW);

forall(UInt, handAlice =>
  forall(UInt, handBob =>
    assert(isOutcome(winner(handAlice, handBob)))));

forall(UInt, (hand) =>
  assert(winner(hand, hand) == DRAW));

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

    // new: Alice compute her hand, but not declassify it.
    const _handAlice = interact.getHand();
    const [_commitAlice, _saltAlice] = makeCommitment(interact, _handAlice);
    const commitAlice = declassify(_commitAlice);
  });

  A.publish(wager, commitAlice).pay(wager);

  // commits the state of the consensus network and returns to "local step"
  commit();

  unknowable(B, A(_handAlice, _saltAlice));  
  B.only(()=>{
    interact.acceptWager(wager);
    const handBob = declassify(interact.getHand());
  })
  
  B.publish(handBob).pay(wager);
  commit();

  A.only(() => {
    const saltAlice = declassify(_saltAlice);
    const handAlice = declassify(_handAlice);
  });
  
  A.publish(saltAlice, handAlice);
  checkCommitment(commitAlice, saltAlice, handAlice);

  const outcome = winner(handAlice, handBob);
  const [forAlice, forBob] =
    outcome == A_WINS ? [2, 0] :
      outcome == B_WINS ? [0, 2] :
    /* tie           */[1, 1];
  transfer(forAlice * wager).to(A);
  transfer(forBob * wager).to(B);
  commit();
  each([A, B], () => {
    interact.seeOutcome(outcome);
  });

  exit();
});

'reach 0.1';

const Player = {
  ...hasRandom, // <--- new!
  ...hasConsoleLogger,
  computeNumber: Fun([], UInt),
  seeOutcome: Fun([UInt], Null),
};

// const [isHand, ROCK, PAPER, SCISSORS] = makeEnum(3);
const [isOutcome, A_WINS, B_WINS, DRAW, NO_WIN ] = makeEnum(4);
/*
An enumeration (or enum, for short), can be created by calling the makeEnum function, 
as in makeEnum(N), where N is the number of distinct values in the enum. 
where the first value is a Fun([UInt], Bool) which tells you if its ARGUMENT is one of the enum's values, 
and the next N values are distinct UInts

const [ isOutcome, LENDER_TIMEOUT, BORROWER_TIMEOUT ] = makeEnum(2);
isOutcome is a function that takes a UInt and returns true or false depending on 
if the UInt passed to it is a MEMBER of that enumeration or not. 
---LENDER_TIMEOUT, BORROWER_TIMEOUT  are UInts
So isOutcome(LENDER_TIMEOUT) would return true while isOutcome(SCISSORS) would return false.217
*/


const winner = (numberCarla, numberEve) => {
  // result calculation
  if (numberCarla > numberEve)
    return A_WINS
  
  else if (numberEve > numberCarla)
    return B_WINS
 
  else if (numberEve == numberCarla)
    return DRAW

  else
    return NO_WIN
}

assert(winner(5, 6)== B_WINS);

forall(UInt, numberCarla =>
  forall(UInt, numberEve =>
    assert(isOutcome(winner(numberCarla, numberEve)))));

export const main = Reach.App(() => {
  const A = Participant('Carla', {
    ...Player,
    wager: UInt,
  });

  const B = Participant('Eve', {
    ...Player,
    acceptWager: Fun([UInt], Null),
  });

  init();

  A.only(() => {
    // declassify make Carla shares the wager amount with Eve
    const wager = declassify(interact.wager);

    // new: Carla compute her hand, but not declassify it.
    const _handCarla = interact.computeNumber();

    // commit phase
    const [_commitCarla, _saltCarla] = makeCommitment(interact, _handCarla); //interact== Participant
    /*
    Interactions in a commitment scheme take place in two phases:
    the commit phase - during which a value is chosen and committed to
    the reveal phase - during which the value is revealed by the sender, then the receiver verifies its authenticity

    so salt is the locked box/ key here
    */

    // share to receiver
    const commitCarla = declassify(_commitCarla);

  });

  A.publish(wager, commitCarla).pay(wager);
  commit();

  unknowable(B, A(_handCarla, _saltCarla));
  /* 
  A knowledge assertion that the participant Notter(B) does not know the results of the 
  variables var_0 through var_N, but that the participant Knower(A) does know those values.
  unknowable( Notter, Knower(var_0, ..., var_N), [msg] ) 
  - checks that both Carla's hand and salt are unknowable to ensure Eve cannot cheat
 */
  B.only(() => {
    interact.acceptWager(wager);
    const handEve = declassify(interact.computeNumber());
  })

  B.publish(handEve).pay(wager);
  commit();

  A.only(() => {
    const saltCarla = declassify(_saltCarla);
    const handCarla = declassify(_handCarla);
  });

  // reveal phase
  A.publish(saltCarla, handCarla);
  checkCommitment(commitCarla, saltCarla, handCarla);

  const outcome = winner(handCarla, handEve);

  const [forCarla, forEve] =
    outcome == A_WINS ? [2, 0] :
      outcome == B_WINS ? [0, 2] :
    /* tie           */[1, 1];

  transfer(forCarla * wager).to(A); // multiply the ratio
  transfer(forEve * wager).to(B);
  commit();

  each([A, B], () => {
    interact.seeOutcome(outcome);
  });

  exit();
});

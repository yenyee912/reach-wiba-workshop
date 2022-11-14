'reach 0.1';

const [isDecision, TRUE, FALSE] = makeEnum(2);
const [isFortune, GOOD_DAY, BAD_DAY, SOSO_DAY] = makeEnum(3);

const Player = {
  seeOutcome: Fun([UInt], Null),
  informTimeout: Fun([], Null),
};

export const main = Reach.App(() => {
  const Alice = Participant('Alice', {
    ...Player,
    wager: UInt, // contract fee
    deadline: UInt, // time delta (blocks/rounds)
    decision: UInt, // time delta (blocks/rounds)
    acceptFortune: Fun([UInt], UInt),
  });
  const Bob = Participant('Bob', {
    ...Player,
    readFortune: Fun([], UInt), // compute fortune
  });
  init();

  const informTimeout = () => {
    each([Alice, Bob], () => {
      interact.informTimeout();
    });
  };

  Alice.only(() => {
    const wager = declassify(interact.wager);
    const deadline = declassify(interact.deadline);

  });
  Alice.publish(wager, deadline)
  .pay(wager);
  commit();
 
  // var decisionAlice = FALSE; // make it false to start game
  // invariant(balance() == wager && isFortune(decisionAlice));
  
  // while (decisionAlice == FALSE) {
    // commit();

    Bob.only(() => {
      const fortune = declassify(interact.readFortune());
    });
    Bob.publish(fortune)
      .timeout(relativeTime(deadline), () => closeTo(Alice, informTimeout));
    commit();
    
    Alice.only(() => {
      const decision = declassify(interact.acceptFortune(fortune));
    });
    Alice.publish(decision)
      .timeout(relativeTime(deadline), () => closeTo(Bob, informTimeout));

    // decisionAlice = decision;
  //   continue;
  // }

  // assert(outcome == A_WINS || outcome == B_WINS);
  transfer(wager).to(Bob);
  commit();

  each([Alice, Bob], () => {
    interact.seeOutcome(decision);
  });
});
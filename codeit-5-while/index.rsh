'reach 0.1';

const [isDecision, TRUE, FALSE] = makeEnum(2);
const [isFortune, GOOD_DAY, BAD_DAY, SOSO_DAY] = makeEnum(3);

const Player = {
  seeOutcome: Fun([], Null),
};
export const main = Reach.App(() => {
  const A = Participant('Alice', {
    ...Player,
    getDecision: Fun([], UInt),
    fortunePrice: UInt,
    showFortune: Fun([UInt], Null),
  });
  const B = Participant('Bob', {
    ...Player,
    readFortune: Fun([], UInt),
    acceptFortunePrice: Fun([UInt], Null),
    showDecision: Fun([UInt], Null),
  });
  init();

  A.only(() => {
    const fortunePrice = declassify(interact.fortunePrice);
  })
  A.publish(fortunePrice)
    .pay(fortunePrice);
  commit();

  B.only(() => {
    interact.acceptFortunePrice(fortunePrice);
  })
  B.publish()
    .pay(fortunePrice);

  var aliceDecision = FALSE;
  invariant(balance() == 2 * fortunePrice)
  while (aliceDecision == FALSE) {
    commit()

    B.only(() => {
      const fortune = declassify(interact.readFortune());
    });
    B.publish(fortune);
    commit();

    A.interact.showFortune(fortune);
    A.publish();
    commit();

    A.only(() => {
      const decision = declassify(interact.getDecision());
    });
    A.publish(decision);
    commit();

    B.interact.showDecision(decision);
    B.publish();

    aliceDecision = decision;
    continue;
  }

  transfer(2 * fortunePrice).to(B); // no matter what, game stop, pay Bob

  // each([A, B], () => {
  //   interact.seeOutcome();
  // })

  commit();

  exit();
});
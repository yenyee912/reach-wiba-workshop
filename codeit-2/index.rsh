'reach 0.1';

const Player = {
  printBalance: Fun([], Null),
};

export const main = Reach.App(() => {
  const A = Participant('Alice', {
    ...Player,
  });

  const B = Participant('Bob', {
    ...Player,
  });

  init();

  // local step --> individual participants can act alone.
  A.only(() => {
    interact.printBalance() //must call this! else frontend function wont execute
  });

  A.publish();

  commit();

  B.only(() => {
    interact.printBalance()

  })

  B.publish();

  commit();

  exit();
});

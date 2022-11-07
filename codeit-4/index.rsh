'reach 0.1';

// Write a code block that instructs a participant, Eve, 
// to publish her callLog and attach a timeout() method that accepts relativeTime, 
// which accepts an argument, deadline. 
// If the deadline is triggered, the contract should perform a closeTo for "Alice" and 
// trigger the function timeExpiration.


const Player = {
  timeExpiration: Fun([], Null),

};

export const main = Reach.App(() => {
  const Alice = Participant('Alice', {
    ...Player,
    deadline: UInt, // time delta (blocks/rounds)
  });

  const Eve = Participant('Eve', {
    ...Player,
    callLog: UInt,  
    getCallLog: Fun([], UInt),

  });
  init();

  const timeExpiration = () => {
    each([Alice, Eve], () => {
      interact.timeExpiration();
    });
  };

  Alice.only(() => {
    const deadline= declassify(interact.deadline);
  });
  Alice.publish(deadline);  
  commit();

  Eve.only(() => {
    const callLog = declassify(interact.getCallLog());
  });
  Eve.publish(callLog).timeout(relativeTime(deadline), () => closeTo(Alice, timeExpiration));
  commit();
});
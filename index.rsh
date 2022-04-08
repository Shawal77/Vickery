'reach 0.1';
'use strict';

// FOMO Workshop generalized to last N winners
const NUM_OF_WINNERS = 3;

const CommonInterface = {
  showOutcome: Fun([Array(Address, NUM_OF_WINNERS)], Null),
};

const AuctioneerInterface = {
  ...CommonInterface,
  getParams: Fun([], Object({
    deadline: UInt, // relative deadline
    ticketPrice: UInt,
  })),
};

const BidderInterface = {
  ...CommonInterface,
  shouldBuyTicket: Fun([UInt], Bool),
  showPurchase: Fun([Address], Null),
};

export const main = Reach.App(
  { },
  [
    Participant('Auctioneer', AuctioneerInterface), ParticipantClass('Bidder', BidderInterface),
  ],
  (Auctioneer, Bidder) => {
    const showOutcome = (winners) =>
      each([Auctioneer, Bidder], () => interact.showOutcome(winners));

    Auctioneer.only(() => {
      const { ticketPrice, deadline } = declassify(interact.getParams()); });
    Auctioneer.publish(ticketPrice, deadline);

    const initialWinners = Array.replicate(NUM_OF_WINNERS, Auctioneer);

    // Until deadline, allow Bidders to buy ticket
    const [ keepGoing, winners, ticketsSold ] =
      parallelReduce([ true, initialWinners, 0 ])
        .invariant(balance() == ticketsSold * ticketPrice)
        .while(keepGoing)
        .case(
          Bidder,
          () => ({
            when: declassify(interact.shouldBuyTicket(ticketPrice)) }),
          (_) => ticketPrice,
          (_) => {
            const Bidder = this;
            Bidder.only(() => interact.showPurchase(Bidder));
            const idx = ticketsSold % NUM_OF_WINNERS;
            const newWinners =
              Array.set(winners, idx, Bidder);
            return [ true, newWinners, ticketsSold + 1 ]; })
        .timeout(relativeTime(deadline), () => {
          Anybody.publish();
          return [ false, winners, ticketsSold ]; });

    transfer(balance() % NUM_OF_WINNERS).to(Auctioneer);
    const reward = balance() / NUM_OF_WINNERS;

    winners.forEach(winner =>
      transfer(reward).to(winner));
      
    commit();
    showOutcome(winners);
  });
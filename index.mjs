import {loadStdlib} from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';

const numOfBidders = 10;

const stdlib = loadStdlib();
const { connector } = stdlib;
const startingBalance = stdlib.parseCurrency(100);

const accAuctioneer = await stdlib.newTestAccount(startingBalance);
const accBidderArray = await Promise.all(
  Array.from({ length: numOfBidders }, () =>
    stdlib.newTestAccount(startingBalance)
  )
);

const ctcAuctioneer = accAuctioneer.contract(backend);
const ctcInfo   = ctcAuctioneer.getInfo();

const AuctioneerParams = {
  ticketPrice: stdlib.parseCurrency(3),
  deadline: connector === 'ALGO' ? 4 : 8,
};

const resultText = (outcome, addr) =>
  outcome.includes(addr) ? 'won' : 'lost';

const bidHistory = {};

await Promise.all([
  backend.Auctioneer(ctcAuctioneer, {
    showOutcome: (outcome) =>
      console.log(`Auctioneer saw they ${resultText(outcome, accAuctioneer.getAddress())}`),
    getParams: () => AuctioneerParams,
  }),
].concat(
  accBidderArray.map((accBidder, i) => {
    const ctcBidder = accBidder.contract(backend, ctcInfo);
    const Who = `Bidder #${i}`;
    return backend.Bidder(ctcBidder, {
      showOutcome: (outcome) =>
        console.log(`${Who} saw they ${resultText(outcome, accBidder.getAddress())}`),
      shouldBuyTicket : () =>
        !bidHistory[Who] && Math.random() < 0.5,
      showPurchase: (addr) => {
        if (stdlib.addressEq(addr, accBidder)) {
          console.log(`${Who} bought a ticket.`);
          bidHistory[Who] = true;
        }
      }
    });
  })
));
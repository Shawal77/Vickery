'reach 0.1';

const AuctionAsset = Object({
    bidFloor: UInt,
    timeout: UInt});

const BidderNumbers = {
    amountBid: Fun([UInt], Maybe(UInt)) };
    
const floorAuction = { bidFloor:0,timeout:0}

export const main = Reach.App(() => {
    const Auctioneer = Participant('Auctioneer', {
        // Specify Auctioneer's interact interface here
        introAuctioneer: Fun([UInt,Address],Null),
        introAuctionAsset: Fun([],AuctionAsset),
        ...BidderNumbers,
        getId: Fun([], UInt)
    });
    const WinningBidder   = Participant('WinningBidder', {
        // Specify WinningBidder's interact interface here
        introWinningBidder: Fun([UInt,Address],Null),
        introAuctionAsset: Fun([],AuctionAsset),
        ...BidderNumbers
    });
    init();
    // write your program here
    (Auctioneer,WinningBidder) => {
        Auctioneer.only(()=>{
            const id = declassify(interact.getId());
        });
        Auctioneer.publish(id);

        var WinningBidder=Auctioneer;
        invariant(balance()==0);
        while (true) {
            commit();

            //Auctioneer tells about the auction
            Auctioneer.only(()=>{
                interact.introAuctioneer(id,Auctioneer);
                const amAuctioneer=this==WinningBidder;
                const {bidFloor,timeout}=Winner?declassify(interact.introAuctionAsset()):floorAuction;
            Auctioneer
                .publish(bidFloor,timeout)
                .when(amAuctioneer)
                .timeout(false);

            const [timeLeft, keepGoing]=makeDeadline(timeout);

            //let them fight for the best bidder
            const [winner, isFirstbid, currentPrice]=
              parallelReduce([ Auctioneer,true,bidFloor ])
                .invariant(balance()==(isFirstbid?0:currentPrice))
                .while(keepGoing)
                .case(Auctioneer,
                  (() => ({
                      const mbid =(this != Auctioneer && this != winner)
                        ?declassify(interact.getBid(currentPrice))
                        :Maybe(UInt).None();
                      return ({
                        when: Maybe(mbid,false,((bid)=>bid>currentPrice)),
                        msg: fromSome(mbid,0)
                      })
                  })),
                  ((bid) => bid),
                  ((bid) => {
                    require(bid>currentPrice);
                  }))
                 .timeout(DEADLINE, () => {
                   TIMEOUT_BLOCK
                 });
        })
        }
    }
    
  });
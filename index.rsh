'reach 0.1';

const AuctionProps = Object({
    startingbid: UInt,
    timeout: UInt});

const BidderProps = {
    getBid: Fun([UInt], Maybe(UInt)) };

const OwnerInterface={
  showOwner: Fun([UInt,Address],Null),
  getAuctionProps:Fun([],AuctionProps),
  ...BidderProps };

const CreatorInterface={
  ...OwnerInterface,
  getId: Fun([], UInt) };
const emptyAuction = {startingbid:0,timeout:0};

export const main = Reach.App({},
  );
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
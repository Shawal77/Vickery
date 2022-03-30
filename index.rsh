'reach 0.1';
//auction starting price and timeout
const AuctionProps = Object({
    startingbid: UInt,
    timeout: UInt});

const BidderProps = {
    getBid: Fun([UInt], Maybe(UInt)) };
//Owner is person holding the item
const OwnerInterface={
  showOwner: Fun([UInt,Address],Null),
  getAuctionProps:Fun([],AuctionProps),
  ...BidderProps };
//creator is auctioneer
const CreatorInterface={
  ...OwnerInterface,
  getId: Fun([], UInt) };
const emptyAuction = {startingbid:0,timeout:0};

export const main = Reach.App(
  {},[
    Participant('Creator',CreatorInterface),
    Participant('Owner',OwnerInterface)
  ],
  (Creator,Owner) => {
    Creator.only(()=>{
        const id = declassify(interact.getId());
    });
    Creator.publish(id);

    var owner=Creator;
    invariant(balance()==0);
    //we use while loop to repeat calculation for all bidders
    while (true) {
        commit();//first save the previous bid
        //Owner tells about the auction
        Owner.only(()=>{
            interact.showOwner(id,owner);//owner/auctioneer intro
            const amOwner=this==owner;
            const {startingbid,timeout}=amOwner?declassify(interact.getAuctionProps()):emptyAuction;
         });
        Owner
            .publish(startingbid,timeout)
            .when(amOwner)
            .timeout(false);

        const [timeRemaining, keepGoing]=makeDeadline(timeout);
        //let them fight for the best bidder
        const [winner, isFirstbid, currentPrice]=
          parallelReduce([owner,true,startingbid])
            .invariant(balance()==(isFirstbid?0:currentPrice))
            .while(keepGoing())
            .case(Owner,
              (() => {
                const mbid =(this != owner && this != winner)
                  ?declassify(interact.getBid(currentPrice))
                  :Maybe(UInt).None();
                return ({
                  when: maybe(mbid,false,((bid)=>bid>currentPrice)),
                  msg: fromSome(mbid,0),
                });
              }),
              ((bid) => bid),
              ((bid) => {
                require(bid>currentPrice);
                //return funds to previous highest bidder
                transfer(isFirstbid?0:currentPrice).to(winner);
                return [this,false,bid];
              })
            )
            .timeRemaining(timeRemaining());

          transfer(isFirstbid?0:currentPrice).to(owner);

          owner = winner;
          continue;
        };
        commit();
        exit();
    });
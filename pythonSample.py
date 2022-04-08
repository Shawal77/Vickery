#define the bidder
class Bidder:
    def __init__(self,name:str,address:str,bidAmount:int):
        self.name=name,
        self.address=address,
        self.bidAmount=bidAmount
#define the auctioneer
class Auctioneer:
    def __init__(self,name:str,address:str,bidFloor:int,Timeout:int):
        self.name=name,
        self.address=address,
        self.bidFloor=bidFloor,
        self.Timeout=Timeout
#now to do the auction consider a list of users
Users=[
    
    ['Shams','1321',80],
    ['Shakur','1322',90],
    ['Shafik','1323',100],
    ['Shamim','1324',70]
    
]
auctioneer=Auctioneer('Shawal','1320',60,40)
#loop through the bidders to get the winner and the price they pay
priceList=[60]
for item in Users:
    bidder=Bidder(item[0],item[1],int(item[2]))
    if int(item[2])>=priceList[-1]:
        priceList.append(item[2])
        winner=item[0]
        amountToPay=int(priceList[-2])   
print(f'Winner is {winner} and pays {amountToPay}')
#this is a simple python backend
#now to implement this back end in reach


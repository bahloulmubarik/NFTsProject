
In this contract we will be managed :
Premium Users
Normal Users

We have to set the :
Max Minting Limit
Platform Miniting Limit
User Minting Limit

When deploying the contract, we must set the maximum limit and platform limit remaining limit assigned to the user's minting limit
e.g if Max Minting Limit is : 1000, Platform minting Limit is : 400, So 1000 - 400 = 600 is a User Minting Limit.

We have to follow Phase-wise Minting Approach
-The owner creates the phase.
-Set a reserved limit for a phase.
-Set the Premium user limit by address.
-Set the Normal user limit per address

If the reserved limit is 50 then both premiums and normal users cannot hit more than 50 NFTs.
The Premium/Normal user cannot mint if the limit for each address is reached.
The reserved limit cannot be greater than the user's minting limit.

When owner creates a phase he needs to activate that phase if the phase is not activated premium and normal users cannot mint NFTs.
When the owner wants to create a new phase, first he deactivates the current phase first.
In new phase we set new reserved limit and per address limits.
If the phase is deactivated, it will not be reactivated.

Platform Minting limit is for admin addresses only.

We have a global limit as well when global limit per address reached then that address cannot mint more NFTs. Even user have the limit in current phase.
Premium user only mint when premium user are allow to mint NFTs by owner.
We can also update the global User minting limit.
We can also update the phase reserved limit.
We can update bulk metadata hashes for the NFTs.
If Transfer status is deactivated owner cannot transfer the NFTs.
We have a bulk mint function where users can mint NFTs in bundles.
we need to create only function for premium and normal user minting.
Admin can also mint NFTs in bulk.
We can fetch the NFTs by address.
All contract functions can be paused by contract owner.  
Token Ids will not be managed within the contract. It will be pass as a parameter in the minting function.
We need to store the following attributes in our NFT contract:
                          1: ID
                          2: Metadata hash  



Your NFT will be listed on opensea testnet. (at least 10 Nfts)
Make your collection unique and attractive with your own decided images and names.

0xfcba7dC69E396170507307cfa5359026aDB2fF4D

you can watch minted Nfts on Opensea Testnet

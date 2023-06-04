// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";



/////////////////////////////////////////////////////////////
//////////////////////HABIBI GANG////////////////////////////
/////////////////////////////////////////////////////////////




contract HabibiGang is ERC721, ERC721Enumerable, ERC721URIStorage, Pausable, Ownable {







//////////////////////////////////////////////////////////////
/////////////////////////STRUCTS//////////////////////////////
//////////////////////////////////////////////////////////////    
  
  
  
  
    // Struct to store premium user details
    struct premiumUser {
        address userAddress;
        uint256 globalLimit;
        bool isRegistered;
        string Role;
        bool isVerified;
    }

    // Struct to store normal user details
    struct normalUser {
        address userAddress;
        uint256 globalLimit;
        bool isRegistered;
        string Role;
    }

    // Struct to store phase details
    struct Phase {
        uint256 reservedLimit;
        bool isActive;
        uint256 premiumLimit;
        uint256 normalLimit;
        mapping(address => uint256) premiumUserBalance;
        mapping(address => uint256) normalUserBalance;
    }

    // Struct to store bulk NFT data
    struct BulkNfts {
        uint id;
        string uri;
    }





///////////////////////////////////////////////////////////////
///////////////////////MAPPING////////////////////////////////
//////////////////////////////////////////////////////////////
  
  
  
  
  
    // Mapping to store phase details
    mapping(uint256 => Phase) public phasesMapping;
    // Mapping to store premium user details
    mapping(address => premiumUser) public PremiumUserMapping;
    // Mapping to store normal user details
    mapping(address => normalUser) public NormalUserMapping;
    // Mapping to store admin details
    mapping(address => bool) public AdminMapping;






////////////////////////////////////////////////////////////////////
/////////////////////STATE VARIABLE/////////////////////////////////
//////////////////////////////////////////////////////////////////





    uint256 public maxMintingLimit; // Maximum minting limit for users
    uint256 public platformMintingLimit; // Minting limit for admins
    uint256 public userMintingLimit; // User-specific minting limit
    uint256 public currentPhase; // Current phase number
    bool isTransferable; // Flag to enable/disable transfers






////////////////////////////////////////////////////////////////////////
///////////////////////////constructor//////////////////////////////////
////////////////////////////////////////////////////////////////////////




   constructor(uint256 _maxLimit, uint256 _platformLimit) ERC721("HabibiGang", "HBBI") {
    maxMintingLimit = _maxLimit;   // Set the maximum minting limit for the contract
    platformMintingLimit = _platformLimit;// Set the platform minting limit
    userMintingLimit = maxMintingLimit - platformMintingLimit;/* Calculate the user minting
     limit by subtracting the platform minting limit from the maximum minting limit*/
}







///////////////////////////////////////////////////////////////////////////////
////////////////////////////functions/////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////



    // Function to register a user
    //i use enum to give role and (0=normal, 1=premiumum, 2=admin)
    enum Role


    {Normal, Premium ,Admin}


    function RegisterUser

    (address _add,
    uint _userLim, 
    Role _role)

    public
    onlyOwner 
    {
        require(_add != address(0), "Null address is not allowed.");   //cheak null address


        //THIS REQUIRE WILL CHEAK THE ADDRESS OF PREMIUM USERS
        require(PremiumUserMapping[_add].isRegistered == false, "User Already Registered as Premium");
        require(AdminMapping[_add] == false, "User already registered as Admin");
        require(NormalUserMapping[_add].isRegistered == false, "User Already Registered as Normal");

    if (_role == Role.Normal) {

        NormalUserMapping[_add] = normalUser(_add, _userLim, true, "Normal");

    } else if (_role == Role.Premium) {

        PremiumUserMapping[_add] = premiumUser(_add, _userLim, true, "Premium", false);

    } else if (_role == Role.Admin) {
       
        AdminMapping[_add] = true;
    }
    else{
        revert("invalid role");
    }
    }






    // Function to verify a premium user






    //require will cheak user is registerd or not if not it will give error
    function VerifiedPremiumUser(address _addr) public onlyOwner {
        require(PremiumUserMapping[_addr].isRegistered == true, "User not registered as Premium");

        PremiumUserMapping[_addr].isVerified = true;    //and the address will be verified if not user cant mint
    }





                   ////////////////////////////////////////////////////////////
                   //////////////////////PHASE CREATION////////////////////////
                   ////////////////////////////////////////////////////////////






      //function to create new phase

      /*the require will cheak that phase is active or not if yes it will give an error

    and if not active so create new phase and increment phase by one*/

     function CreatePhase (
     uint _phaseReservedLimit , 
     uint _premiumReservedLimit, 
     uint  _normalReservedLimit) 
     public onlyOwner{

     
     //THIS REQUIRE WILL CHEAK IF PREVIOUS IS ACTIVE SO NEW PHASE WILL'NT CREATE

     require(!phasesMapping[currentPhase].isActive, "Deactivate the phase 1st");
      
     /*his will cheak not excced of phaselimit from user like if userlimit 
     is 30 & phase is 40 so it will revert error*/

     require(_phaseReservedLimit <  userMintingLimit , "Reserved limit cannot exceed user's minting limit.");

     //if reserved limit is 0 its mean phase is created
     require(phasesMapping[currentPhase].reservedLimit == 0, "phase is already created" );  


    //in this line im making new phase and store is mapping incremant by one
    Phase storage newPhase = phasesMapping[currentPhase + 1];


    //phase is not active yet by owner so it will false
    newPhase.isActive = false;
    newPhase.reservedLimit = _phaseReservedLimit;
    newPhase.premiumLimit = _premiumReservedLimit;
    newPhase.normalLimit = _normalReservedLimit;

  }






///////////////////////////activite phase////////////////////////////



     /**
        Activate the current phase owner will create phase.
        Check if the phase is not already active.
        Check if the premium limit for the phase is set (indicating phase is created).
        Set the 'isActive' flag of the current phase to true.
     */
   

    function ACtivePhase()  public  onlyOwner {
    require(phasesMapping[currentPhase].isActive == false, "Phase Already Active");
    require(phasesMapping[currentPhase].premiumLimit != 0  ," Phase not Created!");    
     phasesMapping[currentPhase].isActive = true;
  }






////////////////////////deactivate phase/////////////////////////////

    /**

    if phase if active so we will deactivate phase if false so it wil give
    an error that phase is not active 
    
    **/


  function  DeactivatePhase() public onlyOwner {
    require(phasesMapping[currentPhase].isActive == true, " Phase not Active  ");
    require(phasesMapping[currentPhase].premiumLimit != 0  ," Phase not Created!");    
     
     phasesMapping[currentPhase].isActive = false;
     currentPhase++;
  }






//////////////////////////////////////////////////////////////////////////
/////////////////////////mint fucntion////////////////////////////////////
//////////////////////////////////////////////////////////////////////////




    // Function to mint a single NFT
/**
 *  Safely mints an NFT to the specified address with the given token ID and URI.
 * - Requires the sender to be a registered Premium User or Normal User.
 * - Requires the current phase to be active.
 * - Requires the user minting limit and phase reserved limit to not be exceeded.
 * - Updates the user's minting balance and decreases the reserved limit.
 * - Safely mints the NFT to the specified address and sets the token URI.
 */
function safeMint(address to, uint256 tokenId, string memory uri) public {
    // Requires the sender to be a registered Premium User or Normal User
    require(PremiumUserMapping[msg.sender].isRegistered || NormalUserMapping[msg.sender].isRegistered, "Registration Required");
    
    // Requires the current phase to be active
    require(phasesMapping[currentPhase].isActive, "Phase not Active or Created!");
    
    // Requires the user minting limit and phase reserved limit to not be exceeded
    require(userMintingLimit > 0, "Global User Mint Limit Exceeded!");
    require(phasesMapping[currentPhase].reservedLimit > 0, "Phase Reserved Limit Exceeded");

    if (PremiumUserMapping[msg.sender].isRegistered) {
        // Requires the Premium User to be verified and checks the limits for the Premium User
        require(PremiumUserMapping[msg.sender].isVerified, "Premium User NOT verified");
        require(balanceOf(msg.sender) < PremiumUserMapping[msg.sender].globalLimit, "Premium User Global Limit Exceeded");
        require(phasesMapping[currentPhase].premiumLimit > phasesMapping[currentPhase].premiumUserBalance[msg.sender], "Premium User Phase Limit Exceeded");
        
        // Increases the Premium User's balance in the current phase
        phasesMapping[currentPhase].premiumUserBalance[msg.sender]++;
    } else {
        // Checks the limits for the Normal User
        require(balanceOf(msg.sender) < NormalUserMapping[msg.sender].globalLimit, "Normal User Global Limit Exceeded");
        require(phasesMapping[currentPhase].normalLimit > phasesMapping[currentPhase].normalUserBalance[msg.sender], "Normal User Phase Limit Exceeded");
        
        // Increases the Normal User's balance in the current phase
        phasesMapping[currentPhase].normalUserBalance[msg.sender]++;
    }

    // Decreases the user minting limit and phase reserved limit
    userMintingLimit--;
    phasesMapping[currentPhase].reservedLimit--;

    // Safely mints the NFT to the specified address and sets the token URI
    _safeMint(to, tokenId);
    _setTokenURI(tokenId, uri);
}




    // Function to mint multiple NFTs in bulk
   /**
 * @dev Allows a registered and verified Premium User to bulk mint multiple NFTs to specified addresses.
 * - Requires transfers to be enabled.
 * - Requires the sender to be a registered and verified Premium User.
 * - Requires the current phase to be active.
 * - Checks the user's balance against the premium and normal limits for each NFT being minted.
 * - Mints the NFTs to the specified addresses and sets their token URIs.
 * - Updates the user's balances in the current phase.
 */
function BulkMints(BulkNfts[] memory _nfts, address[] memory _to) public {
    // Requires transfers to be enabled
    require(isTransferable == true, "Transfers are currently disabled");
    
    // Requires the sender to be a registered and verified Premium User
    require(PremiumUserMapping[msg.sender].isRegistered == true, "User not registered as Premium");
    require(PremiumUserMapping[msg.sender].isVerified == true, "User not verified as Premium");
    
    // Requires the current phase to be active
    require(phasesMapping[currentPhase].isActive == true, "Phase is not active");

    for (uint256 i = 0; i < _nfts.length; i++) {
        // Checks the user's balance against the premium and normal limits for each NFT being minted
        require(phasesMapping[currentPhase].premiumUserBalance[msg.sender] < phasesMapping[currentPhase].premiumLimit, "User has reached the premium limit");
        require(phasesMapping[currentPhase].normalUserBalance[msg.sender] < phasesMapping[currentPhase].normalLimit, "User has reached the normal limit");

        // Mint the NFT
        _safeMint(_to[i], _nfts[i].id);
        _setTokenURI(_nfts[i].id, _nfts[i].uri);

        // Updates the user's balances in the current phase
        phasesMapping[currentPhase].premiumUserBalance[msg.sender]++;
        phasesMapping[currentPhase].normalUserBalance[msg.sender]++;
    }
}









    // Function to mint NFTs directly by the admin
    function MintByAdmin(address _to, uint256 _tokenId, string memory _tokenURI) public onlyOwner {
        require(isTransferable == true, "Transfers are currently disabled");
        require(AdminMapping[msg.sender] == true, "User not registered as Admin");
        require(phasesMapping[currentPhase].isActive == true, "Phase is not active");
        require(phasesMapping[currentPhase].premiumUserBalance[_to] < phasesMapping[currentPhase].premiumLimit, "User has reached the premium limit");
        require(phasesMapping[currentPhase].normalUserBalance[_to] < phasesMapping[currentPhase].normalLimit, "User has reached the normal limit");

        // Mint the NFT
        _safeMint(_to, _tokenId);
        _setTokenURI(_tokenId, _tokenURI);

        phasesMapping[currentPhase].premiumUserBalance[_to]++;
        phasesMapping[currentPhase].normalUserBalance[_to]++;
    }

    // Function to set the transferability status
    function setTransferability(bool _isTransferable) public onlyOwner {
        isTransferable = _isTransferable;
    }

    // Function to pause the contract
    function pause() public onlyOwner {
        _pause();
    }

    // Function to unpause the contract
    function unpause() public onlyOwner {
        _unpause();
    }

  function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
    }
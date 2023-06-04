// SPDX-License-Identifier: MIT

  pragma solidity ^0.8.19;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract IECTOKEN is ERC721, ERC721Enumerable, ERC721URIStorage, Pausable, Ownable  {

    uint public maxMintinLimit;
    uint public platformMintingLimit;
    uint public userMintingLimit;
    uint public currentPhase;
    address public Owner;
    uint public reservedLimitOfCurrentPhase;
    bool isTransferable;
    mapping (address => PremiumStruct ) premiumAddresses;
    mapping (address => NormalStruct ) normalAddresses;
    mapping (address => adminStruct ) adminAddresses;
    mapping (uint => phase) phaseMapping;


    constructor (uint _maxMintingLimit,uint _platformMintngLimit,address _Owner) ERC721("IEC TOKEN", "IECT") 
    {
    maxMintinLimit = _maxMintingLimit;
    platformMintingLimit= _platformMintngLimit;
    userMintingLimit=  maxMintinLimit - platformMintingLimit;
    Owner = _Owner;
    } 

    struct PremiumStruct {

        string name;
        uint id;
        uint256 globalLimit;
        address premiumAddress;
        string role;
        bool isRegistered;
        bool isApproved;
    }

    struct NormalStruct {
        
        string name;
        uint id;
        uint256 globalLimit;
        address normalAddress;
        string role;
        bool isRegistered;

    }

    struct adminStruct {
        
        string name;
        uint id;
        address adminAddress;
        string role;
        bool isRegistered;

    }


    struct phase {

        uint phaseReservedLimit;
        uint premiumUserLimit;
        uint normalUserLimit;
        bool status;
        mapping(address => uint) premiumUserBalance;
        mapping(address => uint) normalUserBalance;
    }

    struct bulkNFTs {
         uint id;
         string uri;

    }

    /*
     * @dev AddUsers is used to register the users like normal,premium and admin users.
     * Requirement:
     * - This function can be only called by the owner of the contract
     * @param _to - Address the user we need to register 
     * @param _name - Name of the user
     * @param _globalLimit - This is the global minting limit of the user
     * @param _id - This is the id of the user
       @param _Address - This is the address of the user
     * @param role - This is the role of the user , whether it is premium, normal or admin
     *
    */ 

    event UserAdded(address indexed userAddress, string name, uint id, address indexed userContractAddress, string role);

    function AddUsers(address _to, string memory _name,uint _globalLimit, uint _id, address _Address,string memory role) public onlyOwner {
        
        if (keccak256(abi.encodePacked(role)) == keccak256(abi.encodePacked("Premium")))
        
        {
            require (normalAddresses[_to].isRegistered == false && adminAddresses[_to].isRegistered == false && premiumAddresses[_to].isRegistered == false, "This address has already been registered" );
             {
                 premiumAddresses[_to] = PremiumStruct( _name,_id, _globalLimit,_Address,role, true, false  );

                  emit UserAdded(_to, _name, _id, _Address, role);

             }
        }   
        else if (keccak256(abi.encodePacked(role)) == keccak256(abi.encodePacked("Normal")))
         {

            require (premiumAddresses[_to].isRegistered == false && adminAddresses[_to].isRegistered == false && normalAddresses[_to].isRegistered , "This address has already been registered");
             {
                normalAddresses[_to] = NormalStruct( _name, _id, _globalLimit, _Address,role, true);

                 emit UserAdded(_to, _name, _id, _Address, role);

             }
    
         }

        else if ( keccak256(abi.encodePacked(role)) == keccak256(abi.encodePacked("Admin"))) 
        {

            require (premiumAddresses[_to].isRegistered == false && normalAddresses[_to].isRegistered == false && premiumAddresses[_to].isRegistered == false, " This address has already been registered" );
             {
                adminAddresses[_to] =adminStruct(_name, _id, _Address, role,true);

                 emit UserAdded(_to, _name, _id, _Address, role);

             }


        }

        else 
        
        {

            revert ("Address is not valid");
        }
        

    }

    /*
     * @dev verifyPremium is used to verify the premium user
     * Requirement:
     * - This function can be only called by the owner of the contract
     * @param _to - Address of the premium user
     *
    */ 

        event PremiumVerified(address indexed userAddress);

    function verifyPremium(address _to) public onlyOwner {
        require (premiumAddresses[_to].isRegistered, "The premium user is not registered");
        require (premiumAddresses[_to].isApproved == false," You are already verified");

        premiumAddresses[_to].isApproved = true;

           emit PremiumVerified(_to);


    }
    
    /*
     * @dev pause is used to pause the functions
     * Requirement:
     * - This function can be only called by the owner of the contract
     *
    */ 

    
    function pause () public onlyOwner {

        _pause();
    }

    /*
     * @dev unpause is used to unpause the functions
     * Requirement:
     * - This function can be only called by the owner of the contract
     *
    */ 

    function unPause() public onlyOwner {

        _unpause();
    }

    /*
     * @dev _beforeTokenTransfer is an internal and virtual function of ERC721
     * Requirement:
     * - This function is called to transfer the nfts from one address to another
     * @param  to - The address to which NFTs are needed to be transferred
     * @param from - The address from which NFTs are transferred 
     * @param tokenId - Id of the token that we need to transfer
     * @param batchSize - Batch size tells how many NFTs are needed to be transferred from one address to another
     *
    */ 

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    /*
     * @dev _burn is an internal and virtual function of ERC721
     * Requirement:
     * - This function is called to burn the NFts that are no longer required
     * @param tokenId - Id of the token that we need to burn
     *
    */ 

     function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    /*
     * @dev supportsInterface is an internal and virtual function of ERC721
     * Requirement:
     * - This function is called to check the support of the interface and it returns a bool value
     * @param  interfaceId - Here it takes interfaceId as input parameter that we need to check support for
    */ 

    function supportsInterface(bytes4 interfaceId) 
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /*
     * @dev tokenURI is an internal and virtual function of ERC721
     * Requirement:
     * - This function is used to get the token's metadata URI by taking tokenId as an input parameter
     * @param  tokenId - The unique tokenId for which we need to fetch the tokenURI
     *
    */ 

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

      /*
     * @dev phaseActivation is used to activate the phase and is only callable by the owner
     * Requirement:
     * - This function checks whether the phase is already active or not
         Then it checks whether the phase has already been created or not
    */ 

    event phaseActivated (uint _currentPhase, bool _value);

    function phaseActivation () public onlyOwner {

        require(phaseMapping[currentPhase].status == false, "Phase Already Active");
        require(phaseMapping[currentPhase].premiumUserLimit != 0  ," Phase not Created!");    
        phaseMapping[currentPhase].status = true;

        emit phaseActivated ( currentPhase, true);

    }

    /*
     * @dev createPhase is used to create the phase 
     * Requirement:
     * - This function is only callable by the owner of the contract
       Requirements:
       This function checks whether the phase is active or not
       Then it checks whether the reserve limit of the phase is less than the user minting limit or not
       Then it checks whether the phase has already been created before or not by checking the reserve limit of the phase
     * @param  _value - This is an integer type key of the mapping 
     * @param _phaseReservedLimit - This variable is used to set the reserve limit of the phase
     * @param _premiumUserLimit - It is used to set the minting limit of the premium user in the phase
     * @param _normalUserLimit - It is used to set the minting limit of the normal user in the phase
     *
    */ 
        

        event phaseCreation(uint id, uint phaseReservedLimit, uint premiumUserLimit, uint normalUserLimit );

    function createPhase (uint _value, uint _phaseReservedLimit, uint _premiumUserLimit, uint _normalUserLimit) public onlyOwner {
        require (phaseMapping[currentPhase].status, " Phase is not active");
        require (_phaseReservedLimit < userMintingLimit, "The reserve limit is more than user minting limit");
        require (phaseMapping[currentPhase].phaseReservedLimit == 0, "Phase already created");
        reservedLimitOfCurrentPhase             = _phaseReservedLimit;
        phaseMapping[_value].phaseReservedLimit = _phaseReservedLimit;
        phaseMapping[_value].premiumUserLimit   = _premiumUserLimit;
        phaseMapping[_value].normalUserLimit    = _normalUserLimit;

        emit phaseCreation ( _value, _phaseReservedLimit, _premiumUserLimit, _normalUserLimit  );
        
    }

     /*
     * @dev phaseDeactivation is used to deaactivate the phase and is only callable by the owner
     * Requirement:
     * - This function checks whether the phase is already active or not
         Then it checks whether the phase has already been created or not
         After checking it deactivates the phase and then increment the state variable by 1 so that it can't be reactivated again
    */ 

    event phaseDeactivated ( uint _currentPhase, bool _value);

    function phaseDeactivation() public onlyOwner {
    require(phaseMapping[currentPhase].status == true, "Phase not active");
    require(phaseMapping[currentPhase].premiumUserLimit != 0  ," Phase not Created!");

        phaseMapping[currentPhase].status = false;

        currentPhase ++;
        emit phaseDeactivated ( currentPhase , false);
        
    }

    /*
     * @dev safeMint is used to mint the nfts
     * Requirement:
     * - This function is callable by the premium and normal users only
       Requirements:
       This function checks whether the normal or premium user has been registered or not
       Then it checks whether the phase is active or not
       Then it checks the user minting limit should be greater than zero
       Then it checks the phase reserved limit should be greater than zero
       Then it checks whether the reserve limit of the phase is less than the user minting limit or not
       Then it checks whether the phase has already been created before or not by checking the reserve limit of the phase
     * @param  tokenId - This is a unique token id which will be given while calling the function
     * @param uri - This variable is used to set the reserve limit of the phase
     *
    */ 
    
    event safeMinting (address _minter, uint _tokenId, string _uri);

    function safeMint( uint256 tokenId , string memory uri)public
       
    {
      require(premiumAddresses[msg.sender].isRegistered ||  normalAddresses[msg.sender].isRegistered , "Registration Required"); 
      require(phaseMapping[currentPhase].status ," Phase not Active or Created!");
      require(userMintingLimit > 0 , " Global User Mint Limit  Exceed!  ");
      require(phaseMapping[currentPhase].phaseReservedLimit >  0  , " Phase Resrved Limit Exceed");
   
        if(premiumAddresses[msg.sender].isRegistered)
        {
         require(premiumAddresses[msg.sender].isApproved, "Permium User NOT verified"); 
         require(balanceOf(msg.sender) < premiumAddresses[msg.sender].globalLimit , " Permium User  Gloabl Limit EXCEED"  );
         require(phaseMapping[currentPhase].premiumUserLimit  > phaseMapping[currentPhase].premiumUserBalance[msg.sender], " Permiun  User Phase Limit Exceed!"  )  ;                                                
            phaseMapping[currentPhase].premiumUserBalance[msg.sender]++;

            emit safeMinting ( msg.sender, tokenId, uri );
        }   
        else
        {
        require(balanceOf(msg.sender) <  normalAddresses[msg.sender].globalLimit , " Normal User  Gloabl Limit EXCEED"  );
        require(phaseMapping[currentPhase].normalUserLimit  > phaseMapping[currentPhase].normalUserBalance[msg.sender], "  Normal User Phase Limit Exceed!"  )  ;                                                
           phaseMapping[currentPhase].normalUserBalance[msg.sender]++;
            emit safeMinting ( msg.sender, tokenId, uri );
        }    
      
       userMintingLimit--;
       phaseMapping[currentPhase].phaseReservedLimit--; 


        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri);
       
    }

    /*
     * @dev bulkMint is used to mint the nfts in bulk
     * Requirement:
     * - This function is callable by the premium and normal users only
       Requirements:
       The function checks whether the length of the arrays of uri,tokenId and to is equal or not
       This function checks whether the normal or premium user has been registered or not
       Then it checks whether the phase is active or not
       Then it checks the user minting limit should be greater than zero
       Then it checks the phase reserved limit should be greater than zero
       Then it checks whether the reserve limit of the phase is less than the user minting limit or not
       Then it checks whether the phase has already been created before or not by checking the reserve limit of the phase
     * @param  uri - This is an array of all the uris that are passed as parameters
     * @param tokenId - This is an array of all the tokenIds that are passed as parameters
     * @param to - This is an array of all the addresses that are passed as parameters
    */

    event bulkMinting (address _minter, uint[] _tokenId, string[] _uri);

    function bulkMint(string [] memory uri,uint[] memory tokenId, address[] memory to) public {

      require (uri.length == tokenId.length && tokenId.length == to.length, " Length not valid"  );
      require(premiumAddresses[msg.sender].isRegistered ||  normalAddresses[msg.sender].isRegistered , "Registration Required"); 
      require(phaseMapping[currentPhase].status ," Phase not Active or Created!");
      require(userMintingLimit - tokenId.length > 0 , " Global User minting limit has been exceeded  ");
      require(phaseMapping[currentPhase].phaseReservedLimit - tokenId.length >  0  , " Phase Resrved Limit Exceed");

      for (uint i; i< tokenId.length; i++ ) 
      
      {

         if(premiumAddresses[msg.sender].isRegistered)
         
         {
        require(premiumAddresses[msg.sender].isApproved, "Permium user not verified"); 
        require(balanceOf(msg.sender) + (tokenId.length -i) < premiumAddresses[msg.sender].globalLimit , " Permium User  Gloabl Limit EXCEED"  );
        require(phaseMapping[currentPhase].premiumUserLimit  > phaseMapping[currentPhase].premiumUserBalance[msg.sender]+ (tokenId.length -i), " Permiun user's phase limit has been exceeded!"  )  ;                                                
            phaseMapping[currentPhase].premiumUserBalance[msg.sender]++;

            emit bulkMinting ( msg.sender, tokenId, uri );
         }   
        else
        {
        require(balanceOf(msg.sender )  + (tokenId.length -i) <  normalAddresses[msg.sender].globalLimit , " Normal User  Gloabl Limit EXCEED"  );
         require(phaseMapping[currentPhase].normalUserLimit  > phaseMapping[currentPhase].normalUserBalance[msg.sender]  + (tokenId.length -i), "  Normal user's phase limit has been exceeded!"  )  ;                                                
        phaseMapping[currentPhase].normalUserBalance[msg.sender]++;

        emit bulkMinting ( msg.sender, tokenId, uri );

        }   

        userMintingLimit--;
       phaseMapping[currentPhase].phaseReservedLimit--; 


        _safeMint(to[i], tokenId[i]);
        _setTokenURI(tokenId[i], uri[i]); 

      }
      
    }

    
    /*
     * @dev adminMint is used to mint the nfts in bulk for admin addresses only
     * Requirements:
       The function checks whether the length of the arrays of uri and tokenId is same or not
       This function checks whether the admin is calling the function or not
       Then it checks whether the platform minting limit is greater than zero or not
       Then it uses for loop for bulk minting 
       Then it checks the balance of the admin address should be less then the platform minting limit
     * @param  uri - This is an array of all the uris that are passed as parameters
     * @param tokenId - This is an array of all the tokenIds that are passed as parameters
    */

    event adminMinting(address _to, string[] uri, uint[] _tkenId);

    function adminMint(string [] memory uri,uint[] memory tokenId) public  
    {
        require (uri.length == tokenId.length, " Length not valid"  );
        require (adminAddresses[msg.sender].isRegistered, "Only admin allowed");
        require(platformMintingLimit >0, "Platform minting limit exceed");

        for(uint i; i< uri.length; i++) 
        
        {
         require  (balanceOf(msg.sender) < platformMintingLimit);
         _safeMint(msg.sender, tokenId[i]);
        _setTokenURI(tokenId[i], uri[i]); 


            platformMintingLimit -- ;

            emit adminMinting(msg.sender, uri, tokenId);

        }
    }

     /*
     * @dev updateGlobalLimit is used to update the global limit of the premium and normal address
     * Requirements:
       The function checks the limit should be greater than the balance of the address that we are updating limit for
       This function checks whether the address is premium or normal and if it is registered or not
     * @param  _address - This variable represents the address for which we are going to update the limit
     * @param _limit - This sets the new limit for the address
    */
    event globalLimitUpdation ( address _to, uint limit);

    function updateGlobalLimit(address _address, uint _limit) public onlyOwner 
    
    {

        require(balanceOf(_address) < _limit," Limit should be greater than balance");
        if (premiumAddresses[_address].isRegistered) 
        
        {


            premiumAddresses[_address].globalLimit = _limit;

            emit globalLimitUpdation ( _address,  _limit);

        }

        else if (normalAddresses[_address].isRegistered) {

            normalAddresses[_address].globalLimit = _limit; 
            emit globalLimitUpdation ( _address,  _limit);

        }

        else {

            require (false, "Address not valid");
        }
    }

    
     /*
     * @dev updateReservedLimit is used to update the reserved limit for the phase
     * Requirements:
       The function checks whether the phase is active or not
       The function checks whether the limit is greater than the sum of the balance of the normal and premium address
     * @param _limit - This sets the new reserved limit for the phase
    */

        event reservedLimitUpdation( uint _currentPhase, uint limit);

    function updateReservedLimit(uint _limit) public  onlyOwner {

        require(phaseMapping[currentPhase].status, " Phase is not active");
        require(reservedLimitOfCurrentPhase - phaseMapping[currentPhase].phaseReservedLimit < _limit, "The limit should be greater! ");
        require (userMintingLimit >_limit, "Limit should be less than user minting limit");
        phaseMapping[currentPhase].phaseReservedLimit = _limit;

        emit reservedLimitUpdation( currentPhase, _limit);


    }

    /*
     * @dev _transfer is an internal and abstract function which is overriden here to transfer the nft from one address to another
     * Requirements:
       The function checks whether the value of "isTransferable" variable is true or false
     * @param from - This is the address from which NFT will be transferred
     * @param to - This is the address to which NFT will be transferred
     * @param tokenId - This is the tokenId of the NFT that is needed to be transferred
    */

    function _transfer (address from, address to , uint tokenId) internal override (ERC721) 
    
    {

        require(isTransferable, "Transfer Deactivated");
        super._transfer(from,to,tokenId);

    }

    /*
     * @dev AllowTransfer is used to set the value of the isTransferable variable
     * Requirements:
       The function checks whether the value of "isTransferable" variable is already true or false
    */

    event allow(bool _val);

    function AllowTransfer () public onlyOwner 
    
    {
        require (! isTransferable, "Already allowed");
        isTransferable = true;

        emit allow(true);
    }

     /*
     * @dev updateBulkHashes is used to update the nfts data in bulk
     * @param dataArray - This is the data of the NFts that we want to update, it is an array of bulkNFTs type which is an struct
    */
    
         event updateBulk(bulkNFTs[] _array);

        function updateBulkHashes(bulkNFTs[] memory dataArray ) public {
            for (uint i; i < dataArray.length; i ++) 
            {

                if(ownerOf(dataArray[i].id) == msg.sender) 
                {
                 _setTokenURI(dataArray[i].id, dataArray[i].uri);
                }

            emit updateBulk (dataArray);
            }


    }

    /*
     * @dev fetchNfts is used to fetch the data of the NFts and it returns value of type 
     * @param dataArray - This is the data of the NFts that we want to update, it is an array of bulkNFTs type which is an struct
    */

    function fetchNfts (address _address) public view returns (bulkNFTs[] memory dataArray){

        require (balanceOf(_address) > 0 , " Invalid Balance");
        bulkNFTs[] memory nftsArray = new bulkNFTs[](balanceOf(_address));

        for ( uint i; i< balanceOf(_address); i++) 
        
        {

            uint id = tokenOfOwnerByIndex( _address, i);
            string memory uri = tokenURI (id);
            nftsArray[i] = bulkNFTs(id,uri);
        }


         return nftsArray;


    }
}
pragma solidity >=0.4.21 <0.6.0;
import "./Owned.sol";

contract PublicAddress is Owned{
    
    //Store addresses with Owner account and to which accounts the access is granted
    struct addressStore{
        address[] grantAddresses;
        address accountOwner;
        mapping(address => uint) grantees;
        bool flag;
    }
    
    //Structure to the list of account to which the msg.sender address has access
    struct accessAddress{
        address[] grantedAddresses;
    }
    
    //To set and get the addressStore
    mapping(address => addressStore) StoreMap;
    
    //To set and get the accessAddress
    mapping(address => accessAddress) AccessStoreMap;
    event addressStoreDetails(address, address, uint, bool, uint);
    
    //Function where AccountOwner grant access to another account. The owner account is the sender account
    function setGrantAddress(address[] memory grantees) public returns (bool) {
        StoreMap[msg.sender].accountOwner = msg.sender;
        for(uint i = 0; i< grantees.length; i++){
            if(StoreMap[msg.sender].grantees[grantees[i]] == 0){
            StoreMap[msg.sender].grantAddresses.push(grantees[i]);   
            StoreMap[msg.sender].grantees[grantees[i]] = 1;
            AccessStoreMap[grantees[i]].grantedAddresses.push(msg.sender);
            }
        }
        StoreMap[msg.sender].flag = true;
        return true;
    }
    
    //Function used by external contracts to get details iff sender account has appropriate rights
    function checkPermission(address _address) external view returns (bool) {
        require(StoreMap[_address].flag == true,"Invalid Address");
        if(StoreMap[_address].accountOwner == msg.sender){revert("Sender address same as Owner");}
        for(uint i =0; i < StoreMap[_address].grantAddresses.length; i++){
            if(StoreMap[_address].grantAddresses[i] == msg.sender){
                return  true;               
            }
        }
    }
    
    //Function to get all the addresses to whom the sender has granted access
    function getGrantAddresses() view public returns (address[] memory){
        require(StoreMap[msg.sender].flag == true, "Invalid Address");
        require(StoreMap[msg.sender].accountOwner == msg.sender,"Access Denied");
        return StoreMap[msg.sender].grantAddresses;
    }
    
    
    //Function to remove grantee from the list of the sender account if its available
    function removeGrantee(address _address) public{
        bool grantee = false;
        uint index;
        uint indexk;
        
        require(StoreMap[msg.sender].flag == true, "Sender Address mapping does not exist");
        
        for (uint i = 0; i < StoreMap[msg.sender].grantAddresses.length; i++){
            if(StoreMap[msg.sender].grantAddresses[i] == _address){
                grantee = true;
                index = i;
                break;
            }
        }
        
        require(grantee != false,"Address yet not granted access");
        emit addressStoreDetails(msg.sender, StoreMap[msg.sender].accountOwner, index, grantee, StoreMap[msg.sender].grantAddresses.length-1);
        StoreMap[msg.sender].grantAddresses[index] = StoreMap[msg.sender].grantAddresses[StoreMap[msg.sender].grantAddresses.length-1];
        delete StoreMap[msg.sender].grantAddresses[StoreMap[msg.sender].grantAddresses.length-1];
        StoreMap[msg.sender].grantAddresses.length--;
        delete StoreMap[msg.sender].grantees[_address];
        
        for (uint k = 0; k < AccessStoreMap[_address].grantedAddresses.length; k++){
            if(AccessStoreMap[_address].grantedAddresses[k] == msg.sender){
                indexk = k;
                break;
            }
        }
        AccessStoreMap[_address].grantedAddresses[indexk] = AccessStoreMap[_address].grantedAddresses[AccessStoreMap[_address].grantedAddresses.length -1];
        delete AccessStoreMap[_address].grantedAddresses[AccessStoreMap[_address].grantedAddresses.length -1];
        AccessStoreMap[_address].grantedAddresses.length--;
    }
    
    function getGrantLength(address _address) public view returns (uint) {
        return StoreMap[_address].grantAddresses.length;
    }
    
    function accessableAddresses() view public returns(address[] memory){
        return AccessStoreMap[msg.sender].grantedAddresses;
    }
}
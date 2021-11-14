pragma solidity 0.8.7;
pragma abicoder v2;

contract DChat {
    
    address public owner = 0xc479DA9d29D528670A916ab4Bc0c4a059a9619a8;
    
    bool closed = false;
    string closedmessage = "insert text";
    
    function transferOwner(address luckyOne) public {
        if(owner == msg.sender) {
            owner = luckyOne;
        }
    }
    
    function getOwner() public view returns(address) {
        return owner;
    }
    
    function shutdownContract() public {
        if(msg.sender == owner) {
            closed = true;
        }
    }
    
    function startContract() public {
        if(msg.sender == owner) {
            closed = false;
        }
    }
    
    function isContractOffline() public view returns(bool) {
        return closed;
    }
    
    function setErrorMessage(string memory errormessage) public {
        closedmessage = errormessage;
    }
    event errorMessage(address indexed loser, string indexed message);
    //
    //
    struct GlobalUser {
        string name;
        string pfpLocation;
        string description;
        address Address;
    }
    //
    //
    event ProfileUpdate(address indexed updated);
    
    mapping(address => GlobalUser) GlobalUsers;
    
    function getGlobalUser() public view returns(GlobalUser memory) {
        return GlobalUsers[msg.sender];
    }
    function setGlobalUser(string memory name, string memory pfpLocation, string memory description, address Address) public {
        GlobalUser memory user = GlobalUser(name, pfpLocation, description, Address);
        GlobalUsers[msg.sender] = user;
        emit ProfileUpdate(Address);
    }
    //
    //
    
    struct DMail {
        string msg;
        address sender;
    }
    
    mapping(address => DMail[]) GlobalInbox;
    mapping(address => DMail[]) SentItems;
    
    event SendEmail(address indexed _from, address indexed _to);
    
    function getInbox() public view returns (DMail[] memory) {
        return GlobalInbox[msg.sender];
    }
    
    function clearInbox() public {
        delete GlobalInbox[msg.sender];
    }
    
    function sendEmail(address target, string memory text) public {
        if(isContractOffline() == false) {
            DMail memory email = DMail(text, msg.sender);
            GlobalInbox[target].push(email);
            SentItems[msg.sender].push(email);
            emit SendEmail(msg.sender, target);   
        }
        else {
            emit errorMessage(msg.sender, closedmessage);
        }
    }
    
    function getSentItems() public view returns (DMail[] memory) {
        return SentItems[msg.sender];
    }
    
    function clearSentItems() public {
        delete SentItems[msg.sender];
    }
    
    //
    //
    event DirectMessageSend(address sender, address target);
    
    struct DirectMessage {
        string text;
        string time;
        address sender;
    }
    
    struct DM {
        DirectMessage[] messages;
        address[] members;
    }
    
    mapping(address => DM) GlobalDirectMessages;
    
    function getDirectMessageContents() public view returns(DirectMessage[] memory) {
        
    }
    
    function sendDirectMessage(string memory text, string memory time, address target) public {
        if(isContractOffline() == false) {
            
        }
        else {
            emit errorMessage(msg.sender, closedmessage);
        }
    }
}

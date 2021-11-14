pragma solidity 0.8.7;
pragma abicoder v2;

contract DChat {
    
    address public owner = 0xc479DA9d29D528670A916ab4Bc0c4a059a9619a8;
    
    function transferOwner(address luckyOne) public {
        if(owner == msg.sender) {
            owner = luckyOne;
        }
    }
    
    function getOwner() public view returns(address) {
        return owner;
    }
    
    struct MailUser {
        uint256 mailCounter;
    }
    
    struct DMail {
        string msg;
        address sender;
        uint256 id;
    }
    
    mapping(address => MailUser) GlobalMailUsers;
    
    mapping(address => DMail[]) GlobalInbox;
    mapping(address => DMail[]) SentItems;
    
    function getInbox() public view returns (DMail[] memory) {
        return GlobalInbox[msg.sender];
    }
    
    function clearInbox() public {
        delete GlobalInbox[msg.sender];
    }
    
    function sendEmail(address target, string memory text) public {
        uint256 id = GlobalMailUsers[msg.sender].mailCounter;
        GlobalMailUsers[msg.sender].mailCounter = id + 1;
        DMail memory email = DMail(text, msg.sender, id);
        GlobalInbox[target].push(email);
        SentItems[msg.sender].push(email);
    }
    
    function deleteEmail(uint256 id) public {
        DMail[] memory userInbox = GlobalInbox[msg.sender];
        for (uint256 i=0; i < userInbox.length; i++) {
            if(userInbox[i].id == id) {
                delete GlobalInbox[msg.sender][i]; 
                break;
            }
        }
    }
    
    function getSentItems() public view returns (DMail[] memory) {
        return SentItems[msg.sender];
    }
    
    function clearSentItems() public {
        delete SentItems[msg.sender];
    }
    
    function deleteSentItem(uint256 id) public {
        DMail[] memory sentItems = SentItems[msg.sender];
        for (uint256 i=0; i < sentItems.length; i++) {
            if(sentItems[i].id == id) {
                delete SentItems[msg.sender][i]; 
                break;
            }
        }
    }
}

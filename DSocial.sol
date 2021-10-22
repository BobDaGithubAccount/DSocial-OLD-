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
    
    struct DirectMessageUser {
        uint256 groupChatCount;
    }
    
    mapping(address => DirectMessageUser) GlobalDirectMessageUsers;
    
    struct DirectMessage {
        string message;
        address sender;
        address target;
        uint256 id;
    }
    
    struct DirectMessages {
        mapping(uint256 => DirectMessage[]) UsersMessages;
    }
    
    struct DirectMessageGroupData {
        address[] GroupMembers;
    }
    
    struct DirectMessageData {
        DirectMessageGroupData gm;
        uint256 messageCount;
    }
    
    mapping(address => DirectMessages) GlobalDirectMessages;
    mapping(address => DirectMessageData) GlobalDirectMessageData;
    
    function sendDirectMessage(address creator, address target, uint256 id, string memory text) public returns(bool) {
        if(isMemberOfDM(creator, msg.sender, id)) {
            uint256 a = GlobalDirectMessageData[creator].messageCount;
            GlobalDirectMessageData[creator].messageCount = a + 1;
            GlobalDirectMessages[creator].UsersMessages[id].push(DirectMessage(text, msg.sender, target, a));
            return true;
        }
        else {
            return false;
        }
    }
    
    function isMemberOfDM(address creator, address target, uint256 id) public view returns(bool) {
        address[] memory members = GlobalDirectMessageData[creator].gm.GroupMembers;
        if(members[0] == target) {
            return true;
        }
        else if(members[1] == target) {
            return true;
        }
        else {
            return false;
        }
    }
    
    function getDirectMessages(address creator, uint256 id) public view returns(DirectMessage[] memory) {
        if(isMemberOfDM(creator, msg.sender, id)) {
            return GlobalDirectMessages[creator].UsersMessages[id];
        }
        else {
            DirectMessage[] memory dm;
            return dm;
        }
    }
    
    function createDirectMessageChannel(address target) public {
        uint256 a = GlobalDirectMessageUsers[msg.sender].groupChatCount;
        GlobalDirectMessageUsers[msg.sender].groupChatCount = a + 1;
        
        address[] memory members;
        members[0] = msg.sender;
        members[1] = target;
        DirectMessageGroupData memory dmgd = DirectMessageGroupData(members);
        DirectMessageData memory directmessagedata = DirectMessageData(dmgd, 0);
        GlobalDirectMessageData[msg.sender] = directmessagedata;
        
        DirectMessage[] memory dms;
        GlobalDirectMessages[msg.sender].UsersMessages[a] = dms;
    }
}

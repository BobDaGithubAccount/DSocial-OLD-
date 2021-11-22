pragma solidity 0.8.10;
pragma abicoder v2;
// SPDX-License-Identifier: Proprietary
contract DSocial {
    //
    event OwnerChangedEvent(address oldone, address newone);
    address owner = 0xc479DA9d29D528670A916ab4Bc0c4a059a9619a8;
    function getOwner() public view returns(address) {
        return owner;
    }
    function setOwner(address target) public {
        if(owner == msg.sender) {
            owner = target;
            emit OwnerChangedEvent(msg.sender, target);
        }
    }
    event ContractStatusChange(bool isOffline);
    bool isContractOffline = false;
    function setContractOffline(bool newValue) public {
        if(msg.sender == owner) {
            isContractOffline = newValue;
            emit ContractStatusChange(newValue);
        }
    }

    function getContractStatus() public view returns(bool) {
        return isContractOffline;
    }
    
    string[] BroadcastedMessages;
    
    event PublicBroadcastEvent();
    
    function sendBroadcast(string memory text) public {
        if(msg.sender == owner) {
            BroadcastedMessages.push(text);
            emit PublicBroadcastEvent();   
        }
    }
    
    function getBroadcasts() public view returns(string[] memory) {
        return BroadcastedMessages;
    }
    
    function clearBroadcasts() public {
        if(msg.sender == owner) {
            delete BroadcastedMessages;
        }
    }
    
    //
        event ProfileUpdateEvent(address target);
    
        struct GlobalUser {
            string name;
            string description;
            string pfplocation;
            address[] friends;
            bool isBot;
            bool isValue;
            uint256[] dmChats;
        }
        
        mapping(address => GlobalUser) GlobalUsers;
        
        function getGlobalUser(address target) public view returns(GlobalUser memory) {
            return GlobalUsers[target];
        }
        
        function updateGlobalUser(string memory name, string memory description, string memory pfplocation, bool isBot) public {
            GlobalUser memory user = GlobalUsers[msg.sender];
            GlobalUser memory gu = GlobalUser(name, description, pfplocation, user.friends, isBot, true, user.dmChats);
            GlobalUsers[msg.sender] = gu;
            emit ProfileUpdateEvent(msg.sender);
        }
        
        function addFriend(address target) public {
            GlobalUsers[msg.sender].friends.push(target);
        }
        
        function deleteFriend(address target) public {
            address[] memory friendsList = GlobalUsers[msg.sender].friends;
            for(uint i=0; i<friendsList.length; i++) {
                if(friendsList[i] == target) {
                    delete GlobalUsers[msg.sender].friends[i];
                    break;
                }
            }
        }
        
        function getFriends() public view returns(address[] memory) {
            return GlobalUsers[msg.sender].friends;
        }
        
        function isFriend(address person1, address person2) public view returns(bool) {
            bool returnValue;
            for(uint i = 0; i < GlobalUsers[person2].friends.length; i++) {
                if(GlobalUsers[person2].friends[i] == person1) {
                    returnValue = true;
                    break;
                }
            }
            return returnValue;
        }

    //
    
    struct EMAIL {
        string text;
        address sender;
    }
    
    mapping(address => EMAIL[]) GlobalInbox;
    mapping(address => EMAIL[]) GlobalSentItems;
    
    event EMailSentEvent(address sender, address target);
    
    function getInbox() public view returns(EMAIL[] memory) {
        return GlobalInbox[msg.sender];
    }
    
    function getSentItems() public view returns(EMAIL[] memory) {
        return GlobalSentItems[msg.sender];
    }
    
    function sendEmail(string memory text, address target) public returns(bool) {
        if(isContractOffline==false) {
            EMAIL memory email = EMAIL(text, msg.sender);
            GlobalSentItems[msg.sender].push(email);
            GlobalInbox[target].push(email);
            emit EMailSentEvent(msg.sender, target);
            return true;
        }
        else {
            return false;
        }
    }
    
    function clearInbox() public {
        delete GlobalInbox[msg.sender];
    }
    function clearSentItems() public {
        delete GlobalSentItems[msg.sender];
    }
    
    //

    event CreateDmChatEvent(address creator, address target, uint256 id);
    event DmChatDeleteEvent(address deleter, address target, uint256 id);
    
    event SendDmEvent(uint256 chatID, uint256 id);
    
    struct DmChat {
        uint256[] messages;
        address[] members;
        string name;
        string description;
        uint256 messageCount;
        bool isValue;
    }
    
    struct Dm {
        string text;
        string time;
        address sender;
        address[] allowedToSee;
        bool isValue;
    }
    
    mapping(uint256 => DmChat) GlobalChats;
    mapping(uint256 => Dm) GlobalMessages;
    
    uint256 chatCounter = 0;
    uint256 messageCounter = 0;
    
    function getDmChats() public view returns(uint256[] memory ids) {
        return GlobalUsers[msg.sender].dmChats;
    }
    
    function getDmChat(uint256 id) public view returns(DmChat memory dms) {
        if((GlobalChats[id].members[0] == msg.sender || GlobalChats[id].members[1] == msg.sender) && GlobalChats[id].isValue == true) {
            return GlobalChats[id];
        }
        else {
            uint256[] memory messages;
            address[] memory members;
            DmChat memory a = DmChat(messages, members, "Don't have permission to see this chat!", "Go away!", 0, false);
            return a;
        }
    }
    
    function getDm(uint256 id) public view returns(Dm memory) {
        if((GlobalMessages[id].allowedToSee[0] == msg.sender || GlobalMessages[id].allowedToSee[1] == msg.sender) && GlobalMessages[id].isValue == true) {
            return GlobalMessages[id];
        }
        else {
            address[] memory allowedToSee;
            allowedToSee[0] = msg.sender;
            Dm memory dud = Dm("Don't have permission to see message", "Now idiot", owner, allowedToSee, false);
            return dud;
        }
    }
    
    function createDmChat(address target, string memory name, string memory description) public returns(bool) {
        if(isFriend(msg.sender, target) == true) {
            uint256[] memory messages;
            address[] memory members;
            members[1] = msg.sender;
            members[2] = target;
            DmChat memory chat = DmChat(messages, members, name, description, 0, true);
            chatCounter++;
            GlobalChats[chatCounter] = chat;
            emit CreateDmChatEvent(msg.sender, target, chatCounter);
            return true;
        }
        else {
            return false;
        }
    }
    
    function leaveDmChat(uint256 id) public returns(bool) {
        if(GlobalChats[id].isValue = true) {
           if(GlobalChats[id].members[0] == msg.sender) {
               delete GlobalChats[id];
               emit DmChatDeleteEvent(msg.sender, GlobalChats[id].members[1], id);
               return true;
           } 
           else if(GlobalChats[id].members[1] == msg.sender) {
               delete GlobalChats[id];
               emit DmChatDeleteEvent(msg.sender, GlobalChats[id].members[0], id);
               return true;
           }
           else {
               return false;
           }
        }
        else {
            return false;
        }
    }
    
    function sendDm(string memory text, string memory time, address target, uint256 chatId) public returns (bool) {
         if(GlobalChats[chatId].isValue = true) {
           if(GlobalChats[chatId].members[0] == msg.sender || GlobalChats[chatId].members[1] == msg.sender) {
               address[] memory allowedToSee;
               allowedToSee[0] = msg.sender;
               allowedToSee[1] = target;
               Dm memory dm = Dm(text, time, msg.sender, allowedToSee, true);
               messageCounter++;
               GlobalChats[chatId].messageCount++;
               GlobalChats[chatId].messages[GlobalChats[chatId].messageCount] = messageCounter;
               GlobalMessages[messageCounter] = dm;
               emit SendDmEvent(chatId, messageCounter);
               return true;
           }
           else {
                return false;   
           }
         }
         else {
             return false;
         }
    }

}

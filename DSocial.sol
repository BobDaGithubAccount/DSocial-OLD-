pragma solidity 0.8.10;
pragma abicoder v2;
// SPDX-License-Identifier: Proprietary
contract DSocial {
    
    constructor() public {
        //Initalise stuff where needed here
    }
    
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
    //Don't call from within contract
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
        }
        
        mapping(address => GlobalUser) GlobalUsers;
        mapping(address => bool) ListOfUsers;
        
        function getGlobalUser(address target) public view returns(GlobalUser memory) {
            return GlobalUsers[target];
        }
        
        function updateGlobalUser(string memory name, string memory description, string memory pfplocation, bool isBot) public {
            GlobalUser memory user = GlobalUsers[msg.sender];
            GlobalUser memory gu = GlobalUser(name, description, pfplocation, user.friends, isBot);
            GlobalUsers[msg.sender] = gu;
            ListOfUsers[msg.sender] = true;
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

    struct DirectMessage {
        string text;
        string time;
        address sender;
    }

    struct DmChat {
        string name;
        DirectMessage[] messages;
        address[] members;
    }
    
    uint256 DmChatCounter = 0;
    
    mapping(uint256=>DmChat) GlobalChats;
    mapping(address=>uint256[]) GlobalUserChats;
    
    event DmChatCreateEvent(uint256 id, address[] members);
    
    function createDmGroup(string memory name, address target) public {
        if(isContractOffline==false) {
            address[] memory targetFriendsList = GlobalUsers[target].friends;
            bool isFriend = false;
            for(uint i = 0; i < targetFriendsList.length; i++) {
                if(targetFriendsList[i]==msg.sender) {
                    isFriend = true;
                    break;
                }
            }
            if(isFriend == true) {
                uint256 id = DmChatCounter+1;
                DmChatCounter = id;
                address[] memory members;
                DirectMessage[] memory messages;
                members[0] = msg.sender;
                members[1] = target;
                DmChat memory chat = DmChat(name, messages, members);
                GlobalChats[id] = chat;
                GlobalUserChats[msg.sender].push(id);
                GlobalUserChats[target].push(id);
                emit DmChatCreateEvent(id, members);
            }   
        }
    }
    
    event DmChatDeleteEvent(uint256 id, address[] members);
    
    function leaveDmGroup(uint256 id) public {
        if(isContractOffline==false) {
            address[] memory members = GlobalChats[id].members;
            address one = members[0];
            address two = members[1];
            if(one==msg.sender||two==msg.sender) {
                for(uint i=0;i<GlobalUserChats[one].length;i++) {
                    if(GlobalUserChats[one][i]==id) {
                        delete GlobalUserChats[one][i];
                    }
                }
                for(uint i=0;i<GlobalUserChats[two].length;i++) {
                    if(GlobalUserChats[two][i]==id) {
                        delete GlobalUserChats[two][i];
                    }
                }
                delete GlobalChats[id];
                emit DmChatDeleteEvent(id,members);
            }
        }
    }
    
    function getDms() public view returns(uint256[] memory) {
        return GlobalUserChats[msg.sender];
    }
    
    function getDm(uint256 id) public view returns(DmChat memory) {
        address[] memory members = GlobalChats[id].members;
        address one = members[0];
        address two = members[1];
        if(one==msg.sender||two==msg.sender) {
            return GlobalChats[id];
        }
    }
    
}

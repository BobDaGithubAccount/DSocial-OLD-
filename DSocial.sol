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
    //
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
            uint256[] files;
        }
        
        mapping(address => GlobalUser) GlobalUsers;
        
        function getGlobalUser(address target) public view returns(GlobalUser memory) {
            return GlobalUsers[target];
        }
        
        function updateGlobalUser(string memory name, string memory description, string memory pfplocation, bool isBot) public {
            GlobalUser memory user = GlobalUsers[msg.sender];
            GlobalUser memory gu = GlobalUser(name, description, pfplocation, user.friends, isBot, true, user.dmChats, user.files);
            GlobalUsers[msg.sender] = gu;
            emit ProfileUpdateEvent(msg.sender);
        }
        
        //
        //
        //

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
    //
    //

    struct File {
        string name;
        string data;
        address uploader;
        bool restrictAccess;
        address[] allowedToSee;
    }

    mapping(uint256 => File) GlobalFileStorage;

    uint256 fileCounter = 0;

    function getFiles() public view returns(uint256[] memory) {
        return GlobalUsers[msg.sender].files;
    }

    function getFile(uint256 id) public view returns(File memory) {
        File memory file = GlobalFileStorage[id];
        if(file.restrictAccess == true) {
            bool returnValue;
            for(uint i = 0; i < file.allowedToSee.length; i++) {
                if(file.allowedToSee[i] == msg.sender) {
                    returnValue = true;
                    break;
                }
            }
            if(returnValue == true) {
                return file;
            }
            else {
                address[] memory allowedToSee;
                File memory f = File("ERROR","ERROR",owner,false,allowedToSee);
                return f;
            }
        }
        else {
            return file;
        }
    }

    function uploadFile(string memory name, string memory data, bool restrictAccess, address[] memory allowedToSee) public returns(bool) {
        File memory file = File(name, data, msg.sender, restrictAccess, allowedToSee);
        fileCounter++;
        GlobalFileStorage[fileCounter] = file;
        return true;
    }

    //
    //
    //

    struct NFT {
        string name;
        address owner;
        bool isStoredOnChain;
        uint256 id;
        string URL;
    }

    

    //
    //
    //
    
    struct EMAIL {
        string text;
        address sender;
    }
    
    mapping(address => EMAIL[]) GlobalInbox;
    mapping(address => EMAIL[]) GlobalSentItems;
    
    event EMailSendEvent(address sender, address target);
    
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
            emit EMailSendEvent(msg.sender, target);
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
    //
    //

    struct Dm {
        string text;
        address sender;
        address[] allowedToSee;
        uint256[] filesAttatched;
    }

    struct DmChat {
        uint256[] messages;
        string name;
        string description;
        address[] members;
    }

    mapping(uint256 => DmChat) GlobalChats;
    mapping(uint256 => Dm) GlobalMessages;

    event DmSendEvent(uint256 messageID, uint256 chatID, address target, address sender);
    event DmCreateEvent(uint256 chatID, address target, address sender);
    event DmDeleteEvent(uint256 chatID, address target, address sender);

    function getDmChats() public view returns(uint256[] memory) {
        return GlobalUsers[msg.sender].dmChats;
    }

    function getDmChat(uint256 id) public view returns(DmChat memory) {
        if(GlobalChats[id].members[0] == msg.sender || GlobalChats[id].members[1] == msg.sender) {
            return GlobalChats[id];
        }
        else {
            uint256[] memory messages;
            string memory name = "ERROR";
            string memory description = "Something went wrong!";
            address[] memory members;
            DmChat memory chat = DmChat(messages, name, description, members);
            return chat;
        }
    }

    function getMessage(uint256 id) public view returns(Dm memory) {
        if(GlobalMessages[id].allowedToSee[0] == msg.sender || GlobalMessages[id].allowedToSee[1] == msg.sender) {
            return GlobalMessages[id];
        }
        else {
            string memory text = "ERROR";
            address sender = address(this);
            address[] memory allowedToSee;
            uint256[] memory filesAttatched;
            Dm memory dm = Dm(text, sender, allowedToSee, filesAttatched);
            return dm;
        }
    }

    uint256 public globalChatCount = 0;

    function createDmChat(string memory name, string memory description, address target) public {
        if(isFriend(msg.sender, target)) {
            globalChatCount++;
            uint256[] memory messages;
            address[] memory members = new address[](2);
            members[0] = msg.sender;
            members[1] = target;
            DmChat memory chat = DmChat(messages, name, description, members);
            GlobalChats[globalChatCount] = chat;
            GlobalUsers[msg.sender].dmChats.push(globalChatCount);
            GlobalUsers[target].dmChats.push(globalChatCount);
            emit DmCreateEvent(globalChatCount, target, msg.sender);
        }
    }

    uint256 public globalMessageCount = 0;

    function sendMessage(uint256 chatID, string memory text, address target, uint256[] memory filesAttatched) public {
        if(GlobalChats[chatID].members[0] == msg.sender || GlobalChats[chatID].members[1] == msg.sender) {
            uint256 id = globalMessageCount + 1;
            globalMessageCount = id;
            address[] memory allowedToSee;
            allowedToSee[0] = msg.sender;
            allowedToSee[1] = target;
            Dm memory dm = Dm(text, msg.sender, allowedToSee, filesAttatched);
            GlobalMessages[id] = dm;
            GlobalChats[chatID].messages.push(id);
            emit DmSendEvent(id, chatID, target, msg.sender);
        }
    }

    function deleteDmChat(uint256 chatID) public {
        address person1 = GlobalChats[chatID].members[0];
        address person2 = GlobalChats[chatID].members[1];
        if(person1 == msg.sender) {
            delete GlobalChats[chatID];
            emit DmDeleteEvent(chatID, person2, msg.sender);
        }
        else if(person2 == msg.sender) {
            delete GlobalChats[chatID];
            emit DmDeleteEvent(chatID, person1, msg.sender);
        }
    }

    //
    //
    //



}

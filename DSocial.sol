pragma solidity 0.8.10;
pragma abicoder v2;
// SPDX-License-Identifier: Proprietary
contract MainContract {
    
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
    
    string[] broadcasts;

    function getBroadcasts() public view returns(string[] memory) {
        return broadcasts;
    }

    event BroadcastEvent();

    function sendBroadcast(string memory text) public {
        if(msg.sender == owner) {
            broadcasts.push(text);
            emit BroadcastEvent();
        }
    }

    function clearBroadcasts() public {
        if(msg.sender == owner) {
            delete broadcasts;
            emit BroadcastEvent();
        }
    }

    mapping(string => address) contracts;

    string[] contractNames;

    function getContracts() public view returns(string[] memory) {
        return contractNames;
    }

    function getContract(string memory name) public view returns(address) {
        return contracts[name];
    }

    function deleteContract(string memory name) public returns(bool) {
       if(msg.sender == owner) {
           delete contracts[name];
           return true;
       }
       return false;
    }

    function setContract(string memory name, address address_) public returns(bool) {
        if(msg.sender == owner) {
            contracts[name] = address_;
        }
        return false;    
    }
}

contract FileContract {
    struct File {
        string name;
        string data;
        address owner;
        bool restrictAccess;
        address[] allowedToSee;
    }

    mapping(address => uint256[]) GlobalUserFileStorage;
    mapping(uint256 => File) GlobalFileStorage;

    uint256 fileCounter = 0;

    function getFiles() public view returns(uint256[] memory) {
        return GlobalUserFileStorage[msg.sender];
    }

    event FileUploadEvent(uint256 id);
    event FileUpdateEvent(uint256 id);

    function uploadFile(string memory name, string memory data, bool restrictAccess, address[] memory allowedToSee) public {
        File memory file = File(name, data, msg.sender, restrictAccess, allowedToSee);
        fileCounter = fileCounter + 1;
        GlobalFileStorage[fileCounter] = file;
        GlobalUserFileStorage[msg.sender].push(fileCounter);
        emit FileUploadEvent(fileCounter);
    }

    function updateFile(uint256 id, string memory name, string memory data, bool restrictAccess, address[] memory allowedToSee) public {
        if(GlobalFileStorage[id].owner == msg.sender) {
            File memory file = File(name, data, msg.sender, restrictAccess, allowedToSee);
            GlobalFileStorage[id] = file;
            emit FileUpdateEvent(id);
        }
    }
}

contract NFTContract {
    struct NFT {
        string name;
        string data;
        address owner;
    }

    mapping(address => uint256[]) GlobalUserNFTStorage;
    mapping(uint256 => NFT) GlobalNFTStorage;

    uint256 nftCounter = 0;

    function getNfts() public view returns(uint256[] memory) {
        return GlobalUserNFTStorage[msg.sender];
    }

    function getNFT(uint256 id) public view returns(NFT memory) {
        if(GlobalNFTStorage[id].owner == msg.sender) {
            return GlobalNFTStorage[id];
        }
        else {
            NFT memory nft = NFT("a", "a", address(this));
            return nft;
        }
    }

    event NFTUploadEvent(uint256 id);
    event NFTTransferEvent(uint256 id, address previousOwner, address newOwner);

    function uploadNFT(string memory name, string memory data) public {
        NFT memory nft = NFT(name, data, msg.sender);
        nftCounter = nftCounter + 1;
        GlobalNFTStorage[nftCounter] = nft;
        GlobalUserNFTStorage[msg.sender].push(nftCounter);
        emit NFTUploadEvent(nftCounter);
    }

    function transferNFT(uint256 id, address target) public {
        if(GlobalNFTStorage[id].owner == msg.sender) {
            uint256[] memory ownerNFTS = GlobalUserNFTStorage[msg.sender];
            for(uint i = 0; i < ownerNFTS.length; i++) {
                if(ownerNFTS[i]==id) {
                    delete ownerNFTS[i];
                    break;
                }
            }
            GlobalUserNFTStorage[msg.sender] = ownerNFTS;
            GlobalNFTStorage[id].owner = target;
            GlobalUserNFTStorage[target].push(id);
            emit NFTTransferEvent(id, msg.sender, target);
        }
    }
}

contract EMailContract {
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
    
    function sendEmail(string memory text, address target) public {
        EMAIL memory email = EMAIL(text, msg.sender);
        GlobalSentItems[msg.sender].push(email);
        GlobalInbox[target].push(email);
        emit EMailSendEvent(msg.sender, target);
    }
    
    function clearInbox() public {
        delete GlobalInbox[msg.sender];
    }
    function clearSentItems() public {
        delete GlobalSentItems[msg.sender];
    }
}

contract DMContract {
    
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
    mapping(address => uint256[]) GlobalDmUsersChats;
    mapping(address => address[]) GlobalDmUsersFriendLists;

    event DmSendEvent(uint256 messageID, uint256 chatID, address target, address sender);
    event DmCreateEvent(uint256 chatID, address target, address sender);
    event DmDeleteEvent(uint256 chatID, address target, address sender);

    function isFriend(address target1, address target2) public view returns(bool) {
        address[] memory target1_friends = GlobalDmUsersFriendLists[target1];
        bool returnValue = false;
        for(uint i = 0; i < target1_friends.length; i++) {
            if(target1_friends[i] == target2) {
                returnValue = true;
                break;
            }
        }
        return returnValue;
    }
    function addFriend(address target) public {
        GlobalDmUsersFriendLists[msg.sender].push(target);
    }
    function removeFriend(address target) public {
        address[] memory friends = GlobalDmUsersFriendLists[msg.sender];
        for(uint i = 0; i < friends.length; i++) {
            if(friends[i] == target) {
                delete friends[i];
                break;
            }
        }
        GlobalDmUsersFriendLists[msg.sender] = friends;
    }

    function getDmChats() public view returns(uint256[] memory) {
        return GlobalDmUsersChats[msg.sender];
    }

    function getDmChat(uint256 id) public view returns(DmChat memory) {
        if(GlobalChats[id].members[0] == msg.sender || GlobalChats[id].members[1] == msg.sender) {
            return GlobalChats[id];
        }
        else {
            uint256[] memory messages;
            string memory name = "a";
            string memory description = "a";
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
            string memory text = "a";
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
            GlobalDmUsersChats[msg.sender].push(globalChatCount);
            GlobalDmUsersChats[target].push(globalChatCount);
            emit DmCreateEvent(globalChatCount, target, msg.sender);
        }
    }

    uint256 public globalMessageCount = 0;

    function sendMessage(uint256 chatID, string memory text, address target, uint256[] memory filesAttatched) public {
        if(GlobalChats[chatID].members[0] == msg.sender || GlobalChats[chatID].members[1] == msg.sender) {
            uint256 id = globalMessageCount + 1;
            globalMessageCount = id;
            address[] memory allowedToSee = new address[](2);
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
}

contract GroupChatContract {
    struct Gm {
        string text;
        address sender;
        address[] allowedToSee;
        uint256[] filesAttatched;
    }

    struct GmChat {
        uint256[] messages;
        string name;
        string description;
        address owner;
        address[] members;
    }

    mapping(uint256 => GmChat) GlobalGroupChats;
    mapping(uint256 => Gm) GlobalGroupMessages;
    mapping(address => uint256[]) GlobalGmUsersChats;
    mapping(address => address[]) GlobalGmUsersFriendLists;

    event GmSendEvent(uint256 messageID, uint256 chatID, address sender);
    event GmCreateEvent(uint256 chatID);
    event GmDeleteEvent(uint256 chatID);
    event GmPersonAddedToChat(uint256 chatID, address adder, address target);
    event GmPersonLeaveChat(uint256 chatID, address remover, address target);

    function getChats() public view returns(uint256[] memory) {
        return GlobalGmUsersChats[msg.sender];
    }

    function getFriends() public view returns(address[] memory) {
        return GlobalGmUsersFriendLists[msg.sender];
    }

    function isFriend(address target1, address target2) public view returns(bool) {
        address[] memory target1_friends = GlobalGmUsersFriendLists[target1];
        bool returnValue = false;
        for(uint i = 0; i < target1_friends.length; i++) {
            if(target1_friends[i] == target2) {
                returnValue = true;
                break;
            }
        }
        return returnValue;
    }

    function addFriend(address target) public returns(bool) {
        GlobalGmUsersFriendLists[msg.sender].push(target);
        return true;
    }

    function removeFriend(address target) public returns(bool) {
        address[] memory friends = GlobalGmUsersFriendLists[msg.sender];
        for(uint i = 0; i < friends.length; i++) {
            if(friends[i] == target) {
                delete friends[i];
                break;
            }
        }
        GlobalGmUsersFriendLists[msg.sender] = friends;
        return true;
    }

    uint256 groupChatCounter = 0;

    function createGroupChat(string memory name, string memory description) public {
        uint256[] memory messages;
        address[] memory members;
        GmChat memory gc = GmChat(messages, name, description, msg.sender, members);
        groupChatCounter = groupChatCounter + 1;
        GlobalGroupChats[groupChatCounter] = gc;
        GlobalGmUsersChats[msg.sender].push(groupChatCounter);
        emit GmCreateEvent(groupChatCounter);
    }

    function deleteGroupChat(uint256 id) public {
        if(GlobalGroupChats[id].owner == msg.sender) {
            address[] memory members = GlobalGroupChats[id].members;
            for(uint i = 0; i < members.length; i++) {
                uint256[] memory chats = GlobalGmUsersChats[members[i]];
                for(uint a = 0; a < chats.length; a++) {
                    if(chats[a] == id) {
                        delete chats[a];
                        break;
                    }
                }
                GlobalGmUsersChats[members[i]] = chats;
            }
            GlobalGroupChats[id].members = members;
            uint256[] memory b = GlobalGmUsersChats[GlobalGroupChats[id].owner];
            for(uint a = 0; a < b.length; a++) {
                if(b[a] == id) {
                    delete b[a];
                    break;
                }
            }
            GlobalGmUsersChats[GlobalGroupChats[id].owner] = b;
            delete GlobalGroupChats[id];
            emit GmDeleteEvent(id);
        }
    }
}

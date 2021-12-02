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
    
    //
    //
    //
        event ProfileUpdateEvent(address target);
    
        struct GlobalUser {
            string name;
            string description;
            string pfplocation;
            bool isStoredOnChain;
            uint256 fileID;
            address[] friends;
            bool isBot;
            bool isValue;
            uint256[] dmChats;
            uint256[] files;
            uint256[] nfts;
        }
        
        mapping(address => GlobalUser) GlobalUsers;
        
        function getGlobalUser(address target) public view returns(GlobalUser memory) {
            return GlobalUsers[target];
        }
        
        function updateGlobalUser(string memory name, string memory description, string memory pfplocation, bool isBot, bool isStoredOnChain, uint256 fileID) public {
            GlobalUser memory user = GlobalUsers[msg.sender];
            GlobalUser memory gu = GlobalUser(name, description, pfplocation, isStoredOnChain, fileID, user.friends, isBot, true, user.dmChats, user.files, user.nfts);
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
                File memory f = File("a","a",owner,false,allowedToSee);
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
        GlobalUsers[msg.sender].files.push(fileCounter);
        return true;
    }

    function updateFile(string memory name, string memory data, bool restrictAccess, address[] memory allowedToSee, uint256 id) public returns(bool) {
        if(GlobalFileStorage[id].uploader == msg.sender) {
            File memory file = File(name, data, msg.sender, restrictAccess, allowedToSee);
            GlobalFileStorage[id] = file;
            return true;
        }
        else {
            return false;
        }
    } 

    //
    //
    //

    uint256 nftCounter = 0;

    mapping(uint256 => NFT) GlobalNftStorage;

    struct NFT {
        string name;
        address owner;
        bool isStoredOnChain;
        string fileName;
        string data;
        string url;
    }

    function getNFTs() public view returns(uint256[] memory) {
        return GlobalUsers[msg.sender].nfts;
    }

    function getNFT(uint256 id) public view returns(NFT memory) {
        if(GlobalNftStorage[id].owner == msg.sender) {
            return GlobalNftStorage[id];
        }
        else {
            NFT memory nft = NFT("a", owner, true, "a", "a", "a");
            return nft;
        }  
    }

    function createNFT(string memory name, bool isStoredOnChain, string memory fileName, string memory fileData, string memory url) public returns(bool) {
        NFT memory nft = NFT(name, msg.sender, isStoredOnChain, fileName, fileData, url);
        nftCounter++;
        uint256 counter = nftCounter;
        GlobalNftStorage[counter] = nft;
        GlobalUsers[msg.sender].nfts.push(counter);
        emit NftEvent(counter, msg.sender, msg.sender);
        return true;
    }

    function updateNFT(uint256 NftId, string memory name, bool isStoredOnChain, string memory fileName, string memory fileData, string memory url) public returns(bool) {
        if(GlobalNftStorage[NftId].owner == msg.sender) {
            NFT memory nft = NFT(name, msg.sender, isStoredOnChain, fileName, fileData, url);
            GlobalNftStorage[NftId] = nft;
            emit NftEvent(NftId, msg.sender, msg.sender);
            return true;
        }
        else {
            return false;
        }
    }

    event NftEvent(uint256 id, address oldOwner, address newOwner);

    function transferNFT(uint256 NftId, address target) public returns(bool) {
        if(GlobalNftStorage[NftId].owner == msg.sender) {
            NFT memory nft = GlobalNftStorage[NftId];
            nft.owner = target;
            GlobalNftStorage[NftId] = nft;
            GlobalUsers[target].nfts.push(NftId);
            uint256[] memory nfts = GlobalUsers[msg.sender].nfts;
            for(uint i = 0; i < nfts.length; i++) {
                if(nfts[i] == NftId) {
                    delete nfts[i];
                    break;
                }
            }
            GlobalUsers[msg.sender].nfts = nfts;
            emit NftEvent(NftId, msg.sender, target);
            return true;
        }
        else {
            return false;
        }
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

    // 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
    // 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
}

pragma solidity 0.8.10;
pragma abicoder v2;

// SPDX-License-Identifier: Proprietary

contract DChat {
    
    address public owner = 0xc479DA9d29D528670A916ab4Bc0c4a059a9619a8;
    
    bool closed = false;
    string closedmessage = "DSocial is down for maintenance!";
    string successmessage = "a";
    
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
    
    function getErrorMessage() public view returns(string memory) {
        return closedmessage;
    }
    //
    //
    struct GlobalUser {
        string name;
        string pfpLocation;
        string description;
        address Address;
    }

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
    
    function sendEmail(address target, string memory text) public returns(string memory) {
        if(isContractOffline() == false) {
            DMail memory email = DMail(text, msg.sender);
            GlobalInbox[target].push(email);
            SentItems[msg.sender].push(email);
            emit SendEmail(msg.sender, target);   
            return successmessage;
        }
        else {
            return closedmessage;
        }
    }
    
    function getSentItems() public view returns (DMail[] memory) {
        return SentItems[msg.sender];
    }
    
    //
    //
    event DMCreateEvent(address[] members);
    event DirectMessageSendEvent(address sender, address target);
    
    struct DirectMessage {
        string text;
        string time;
        address sender;
    }
    
    struct DM {
        string name;
        DirectMessage[] messages;
        address[] members;
    }
    
    struct DMs {
        DM[] dms;
    }
    
    uint256 dmCounter;
    
    mapping(address => DMs) GlobalDirectMessages;
    
    DirectMessage[] messages_;
    function createDM(string memory name, address target, string memory time) public returns(string memory){
        delete messages_;
        if(isContractOffline() == false) {
            dmCounter = dmCounter + 1;
            address[] memory members;
            members[0] = msg.sender;
            members[1] = target;
            DirectMessage memory directmessage = DirectMessage("Beginning of chat thread!", time, getOwner());
            messages_.push(directmessage);
            DM memory dm = DM(name, messages_, members);
            GlobalDirectMessages[msg.sender].dms.push(dm);
            GlobalDirectMessages[target].dms.push(dm);
            emit DMCreateEvent(members);
            return successmessage;
        }
        else {
           return closedmessage;
        }
    }
    
    function getDirectMessageContents(uint256 id) public view returns(DirectMessage[] memory) {
        return GlobalDirectMessages[msg.sender].dms[id].messages;
    }
    
    function getDMs() public view returns(DM[] memory) {
        return GlobalDirectMessages[msg.sender].dms;
    }
    
    function sendDirectMessage(string memory text, string memory time, address target) public returns(string memory) {
        if(isContractOffline() == false) {
            DirectMessage memory message = DirectMessage(text, time, msg.sender);
            
            DM[] memory senderDMs = GlobalDirectMessages[msg.sender].dms;
            uint256 senderID = 0;
            uint256 senderLength = senderDMs.length;
            bool senderDmExists = false;
            DM memory senderDM;
            for(uint256 i = 0; i < senderLength; i++) {
                if(senderDMs[i].members[0] == msg.sender) {
                    senderDmExists = true;
                    senderDM = senderDMs[i];
                    senderID = i;
                }
                else if(senderDMs[i].members[1] == msg.sender) {
                    senderDmExists = true;
                    senderDM = senderDMs[i];
                    senderID = i;
                }
                else {
                    senderDmExists = false;
                }
            } 
            
            DM[] memory targetDMs = GlobalDirectMessages[target].dms;
            uint256 targetID = 0;
            uint256 targetLength = senderDMs.length;
            bool targetDmExists = false;
            DM memory targetDM;
            for(uint256 i = 0; i < targetLength; i++) {
                if(targetDMs[i].members[0] == target) {
                    targetDmExists = true;
                    targetDM = senderDMs[i];
                    targetID = i;
                }
                else if(senderDMs[i].members[1] == target) {
                    targetDmExists = true;
                    targetDM = senderDMs[i];
                    targetID = i;
                }
                else {
                    targetDmExists = false;
                }
            } 
            
            if(senderDmExists == true) {
                if(targetDmExists == true) {
                    DirectMessage[] storage senderMessages = GlobalDirectMessages[msg.sender].dms[senderID].messages;
                    senderMessages.push(message);
                    GlobalDirectMessages[msg.sender].dms[senderID].messages = senderMessages;
                    DM storage targetDm = GlobalDirectMessages[target].dms[targetID]; //TODO fix stack too deep error
                    DirectMessage[] storage targetMessages = targetDm.messages;
                    targetMessages.push(message);
                    GlobalDirectMessages[target].dms[targetID].messages = targetMessages;
                    emit DirectMessageSendEvent(msg.sender, target);
                    return successmessage;       
                }
                else {
                    return "ERROR";
                }
            }
            else {
                return "ERROR";
            }
        }
        else {
            return closedmessage;
        }
    }
}

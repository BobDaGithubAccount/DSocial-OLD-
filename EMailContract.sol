pragma solidity 0.8.11;
pragma abicoder v2;
// SPDX-License-Identifier: Proprietary
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

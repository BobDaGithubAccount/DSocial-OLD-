pragma solidity 0.8.11;
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

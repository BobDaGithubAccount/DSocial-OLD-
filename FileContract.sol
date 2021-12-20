pragma solidity 0.8.11;
pragma abicoder v2;
// SPDX-License-Identifier: Proprietary
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

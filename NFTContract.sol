pragma solidity 0.8.11;
pragma abicoder v2;
// SPDX-License-Identifier: Proprietary
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

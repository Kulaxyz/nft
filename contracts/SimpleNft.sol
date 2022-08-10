pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract SimpleNft is ERC721 {
    uint256 private s_counter;

    string public constant URI = "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json";

    constructor() ERC721("Doge", "DOG") {}

    function mint() public {
        s_counter++;
        _safeMint(msg.sender, s_counter);
    }

    function tokenURI(uint256 _tokenId) public pure override returns (string memory) {
        return URI;
    }

    function getCounter() public view returns (uint256) {
        return s_counter;
    }
}

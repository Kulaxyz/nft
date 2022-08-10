pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error IPFSNft__SendMoreEth();
error IPFSNft__RangeOutOfBounds();

contract IPFSNft is ERC721URIStorage, VRFConsumerBaseV2, Ownable {
    enum Pokemon {
        Pikachu,
        Bulbasaur,
        Charmander
    }

    event NftRequested(uint256 indexed requestId, address indexed sender);
    event NftMinted(address indexed sender, uint256 indexed tokenId);

    //VRF related variables
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    uint64 private immutable i_subscriptionId;
    bytes32 private immutable i_gasLane;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    mapping (uint256 => address) private s_requestToAddress;

    // Common variables
    uint256 private immutable i_fee;
    uint256 private s_counter;
    string[] private s_tokenURIs;

    uint32 private constant MAX_CHANCE = 100;

    constructor(
        address _vrfCoordinator,
        uint64 _subscriptionId,
        bytes32 _gasLane,
        uint32 _callbackGasLimit,
        uint256 _fee,
        string[3] memory _tokenURIs
    ) ERC721("IPFS Doge", "IDOG") VRFConsumerBaseV2(_vrfCoordinator) {
        i_vrfCoordinator = VRFCoordinatorV2Interface(_vrfCoordinator);
        i_subscriptionId = _subscriptionId;
        i_gasLane = _gasLane;
        i_callbackGasLimit = _callbackGasLimit;
        i_fee = _fee;
        s_tokenURIs = _tokenURIs;
    }

    function requestNft() public payable returns (uint256) {
        if (msg.value < i_fee) {
            revert IPFSNft__SendMoreEth();
        }
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
        s_requestToAddress[requestId] = msg.sender;
        emit NftRequested(requestId, msg.sender);

        return requestId;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        address requester = s_requestToAddress[requestId];
        uint256 item = s_counter;
        s_counter++;
        uint256 randomNum = randomWords[0] % MAX_CHANCE;

        Pokemon pokemon = getPokemonFromModdedRng(randomNum);
        _setTokenURI(item, s_tokenURIs[uint256(pokemon)]);
        _safeMint(msg.sender, item);
        emit NftMinted(msg.sender, item);
    }

    function withdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");
    }

    function getPokemonFromModdedRng(uint256 moddedRng) public pure returns (Pokemon) {
        uint256 cumulativeSum = 0;
        uint256[3] memory chanceArray = getChances();
        for (uint256 i = 0; i < chanceArray.length; i++) {
            if (moddedRng >= cumulativeSum && moddedRng < chanceArray[i]) {
                return Pokemon(i);
            }
            cumulativeSum = chanceArray[i];
        }
        revert IPFSNft__RangeOutOfBounds();
    }

    function getChances() public pure returns (uint256[3] memory) {
        return [uint256(10), uint256(30), uint256(MAX_CHANCE)];
    }
}
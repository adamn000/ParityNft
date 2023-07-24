// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {ERC721A} from "lib/ERC721A/contracts/ERC721A.sol";
import {Strings} from "lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract ParityNft is ERC721A, Ownable {
    using Strings for uint256;

    error ReachedMaxNftPerWallet();
    error TotalSupplyHasBeenReached();
    error NotEnoughEthSent();
    error MintIsNotOpen();

    uint256 public s_tokenId;
    string private s_evenBaseTokenURI;
    string private s_oddBaseTokenURI;

    uint256 public constant TOTAL_SUPPLY = 5000;
    uint256 public constant MAX_PER_WALLET = 3;
    uint256 public constant PRICE = 0.01 ether; // 10000000000000000 WEI
    bool public isMintOpen = false;

    mapping(uint256 => uint256) public parityStateToTokenCounter; // 1 = even, 2 = odd

    constructor(
        string memory evenBaseTokenURI,
        string memory oddBaseTokenUri
    ) ERC721A("ParityNFT", "PN") {
        s_tokenId = 0;
        s_evenBaseTokenURI = evenBaseTokenURI;
        s_oddBaseTokenURI = oddBaseTokenUri;
    }

    /////////////////////
    /// Mint function //
    ///////////////////

    function mint(uint256 quantity) public payable {
        if (!isMintOpen) {
            revert MintIsNotOpen();
        }
        if (msg.value < PRICE * quantity) {
            revert NotEnoughEthSent();
        }
        if (
            quantity > MAX_PER_WALLET ||
            balanceOf(msg.sender) + quantity > MAX_PER_WALLET
        ) {
            revert ReachedMaxNftPerWallet();
        }
        if (s_tokenId + quantity > TOTAL_SUPPLY) {
            revert TotalSupplyHasBeenReached();
        }
        for (uint i = 0; i < quantity; i++) {
            _mint(msg.sender, 1);
            if (block.number % 2 == 0) {
                parityStateToTokenCounter[s_tokenId] = 1;
            } else {
                parityStateToTokenCounter[s_tokenId] = 2;
            }
            s_tokenId++;
        }
    }

    /////////////////////////////
    /// Set metadata of token //
    ///////////////////////////

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        string memory baseURI;

        if (parityStateToTokenCounter[tokenId] == 1) {
            baseURI = _evenBaseURI();
        } else if (parityStateToTokenCounter[tokenId] == 2) {
            baseURI = _oddBaseURI();
        }
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, tokenId.toString()))
                : "";
    }

    function _evenBaseURI() internal view virtual returns (string memory) {
        return s_evenBaseTokenURI;
    }

    function _oddBaseURI() internal view virtual returns (string memory) {
        return s_oddBaseTokenURI;
    }

    //////////////////////
    // Withdraw funds  //
    ////////////////////

    function withdrawFunds() external onlyOwner {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }

    //////////////
    // Setter  //
    ////////////

    function openMint() external onlyOwner {
        isMintOpen = true;
    }

    function closeMint() external onlyOwner {
        isMintOpen = false;
    }

    /////////////
    // Getter //
    ///////////

    function getParityState(
        uint256 tokenCounter
    ) public view returns (uint256) {
        return parityStateToTokenCounter[tokenCounter];
    }

    function getTokenId() public view returns (uint256) {
        return s_tokenId;
    }
}

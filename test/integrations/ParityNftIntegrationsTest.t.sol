// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DeployParityNft} from "../../script/DeployParityNft.s.sol";
import {ParityNft} from "../../src/ParityNft.sol";

contract ParityNftIntegrationsTest is Test {
    DeployParityNft public deployer;
    ParityNft public parityNft;

    address USER = makeAddr("user");
    uint256 private constant ONE_TOKEN_PRICE = 0.01 ether;

    function setUp() public {
        deployer = new DeployParityNft();
        parityNft = deployer.run();
        vm.deal(USER, 1 ether);
    }

    modifier mintIsOpen() {
        vm.prank(msg.sender);
        parityNft.openMint();
        _;
    }

    function testUserMintAndHaveBalance() public mintIsOpen {
        vm.roll(10);

        vm.prank(USER);
        parityNft.mint{value: ONE_TOKEN_PRICE}(1);

        assert(parityNft.balanceOf(USER) == 1);
    }

    function testUriReturnIfMintBlockIsOdd() public mintIsOpen {
        vm.roll(51);
        vm.prank(USER);
        parityNft.mint{value: ONE_TOKEN_PRICE}(1);

        string
            memory expectedURI = "ipfs://bafybeiguli4bb6pnajengyo5t2sg6hrqk7xgt525rbdwu7vnnfwmqaa35y/0";
        string memory actualURI = parityNft.tokenURI(0);

        assert(
            keccak256(abi.encodePacked(expectedURI)) ==
                keccak256(abi.encodePacked(actualURI))
        );
    }

    function testUriReturnIfMintBlockIsEven() public mintIsOpen {
        vm.roll(50);
        vm.prank(USER);
        parityNft.mint{value: ONE_TOKEN_PRICE}(1);

        string
            memory expectedURI = "ipfs://bafybeif4eecbys25sikzeihipuejskhraj5mmpvx7w7mm7m4abirkfqhdi/0";
        string memory actualURI = parityNft.tokenURI(0);

        assert(
            keccak256(abi.encodePacked(expectedURI)) ==
                keccak256(abi.encodePacked(actualURI))
        );
    }
}

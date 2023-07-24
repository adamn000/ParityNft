// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {ParityNft} from "../../src/ParityNft.sol";
import {DeployParityNft} from "../../script/DeployParityNft.s.sol";

contract ParityNftTest is Test {
    ParityNft parityNft;
    DeployParityNft deployer;

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

    function testRevertIfMintIsNotOpen() public {
        vm.prank(USER);
        vm.expectRevert(ParityNft.MintIsNotOpen.selector);
        parityNft.mint(1);
    }

    function testRevertIfUserSentNotEnoughEth() public mintIsOpen {
        vm.prank(USER);
        vm.expectRevert(ParityNft.NotEnoughEthSent.selector);
        parityNft.mint{value: 10000000000000000}(2);
    }

    function testMaxPerWalletMint() public mintIsOpen {
        vm.prank(USER);
        vm.expectRevert(ParityNft.ReachedMaxNftPerWallet.selector);
        parityNft.mint{value: 4 * ONE_TOKEN_PRICE}(4);
    }

    function testMappingToAddressMintInEvenBlock() public mintIsOpen {
        vm.roll(10);
        vm.prank(USER);
        parityNft.mint{value: ONE_TOKEN_PRICE}(1);
        assertEq(parityNft.getParityState(0), 1);
    }

    function testMappingToAddressMintInOddBlock() public mintIsOpen {
        vm.roll(3);
        vm.prank(USER);
        parityNft.mint{value: ONE_TOKEN_PRICE}(1);
        assertEq(parityNft.getParityState(0), 2);
    }

    function testTokenIdCount() public mintIsOpen {
        vm.prank(USER);
        parityNft.mint{value: 3 * ONE_TOKEN_PRICE}(3);
        assert(parityNft.getTokenId() == 3);
    }

    function testUriReturnIfMintBlockIsEven() public mintIsOpen {
        vm.roll(50);
        vm.prank(USER);
        parityNft.mint{value: ONE_TOKEN_PRICE}(1);

        string memory expectedURI = "green0";
        string memory actualURI = parityNft.tokenURI(0);

        assert(
            keccak256(abi.encodePacked(expectedURI)) ==
                keccak256(abi.encodePacked(actualURI))
        );
    }

    function testUriReturnIfMintBlockIsOdd() public mintIsOpen {
        vm.roll(51);
        vm.prank(USER);
        parityNft.mint{value: ONE_TOKEN_PRICE}(1);

        string memory expectedURI = "red0";
        string memory actualURI = parityNft.tokenURI(0);

        assert(
            keccak256(abi.encodePacked(expectedURI)) ==
                keccak256(abi.encodePacked(actualURI))
        );
    }

    function testOnlyOwnerCanWithdrawFunds() public {
        vm.prank(USER);
        vm.expectRevert();
        parityNft.withdrawFunds();
    }
}

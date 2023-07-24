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

    function testUserMintAndHaveBalance() public {
        vm.prank(msg.sender);
        parityNft.openMint();
        vm.roll(10);

        vm.prank(USER);
        parityNft.mint{value: ONE_TOKEN_PRICE}(1);

        assert(parityNft.balanceOf(USER) == 1);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {ParityNft} from "../src/ParityNft.sol";

contract DeployParityNft is Script {
    function run() external returns (ParityNft) {
        string memory evenBaseTokenURI = "green";
        string memory oddBaseTokenURI = "red";

        vm.startBroadcast();
        ParityNft parityNft = new ParityNft(evenBaseTokenURI, oddBaseTokenURI);
        vm.stopBroadcast();
        return parityNft;
    }
}

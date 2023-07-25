// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {ParityNft} from "../src/ParityNft.sol";

contract DeployParityNft is Script {
    function run() external returns (ParityNft) {
        string
            memory evenBaseTokenURI = "ipfs://bafybeif4eecbys25sikzeihipuejskhraj5mmpvx7w7mm7m4abirkfqhdi/";
        string
            memory oddBaseTokenURI = "ipfs://bafybeiguli4bb6pnajengyo5t2sg6hrqk7xgt525rbdwu7vnnfwmqaa35y/";

        vm.startBroadcast();
        ParityNft parityNft = new ParityNft(evenBaseTokenURI, oddBaseTokenURI);
        vm.stopBroadcast();
        return parityNft;
    }
}

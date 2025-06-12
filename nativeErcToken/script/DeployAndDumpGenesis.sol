// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Script } from "forge-std/Script.sol";
import { console2 } from "forge-std/console2.sol";
import { NativeERCToken } from "../src/NativeERCToken.sol";
import { Process } from "./libraries/Process.sol";
import { Common } from "./Common.sol";

/// @notice Script to deploy NativeERCToken, dump the genesis state, and output jq commands
/// to move an entry in the alloc: eval alloc[second] = alloc[one] and then delete alloc[one].
contract DeployAndDumpGenesis is Common {
    
    function run() external {
        // Read the initial supply from the environment.
        uint initialSupply = vm.envUint("INITIAL_SUPPLY");
        console2.log("initialSupply", initialSupply);

        // Read the owner address from the environment.
        address ownerAddress = vm.envAddress("OWNER_ADDRESS");
        console2.log("ownerAddress", ownerAddress);

        // Read the token name and symbol from the environment.
        string memory name = vm.envString("NAME");
        string memory symbol = vm.envString("SYMBOL");

        // Deploy the token and log its address.
        NativeERCToken deployed = new NativeERCToken(name, symbol, initialSupply, ownerAddress);
        console2.log("Deployed NativeERCToken at:", address(deployed));

        // In this example, we move the entry from the deployed address (one) to address(0) (second).
        modifyAddress(address(deployed), address(0));
        save();
    }
}

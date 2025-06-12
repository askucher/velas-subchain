// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Script } from "forge-std/Script.sol";
import { console2 } from "forge-std/console2.sol";
import { NativeERCToken } from "../src/NativeERCToken.sol";
import { Process } from "./libraries/Process.sol";

/// @notice Script to deploy NativeERCToken, dump the genesis state, and output jq commands
/// to move an entry in the alloc: eval alloc[second] = alloc[one] and then delete alloc[one].
contract Common is Script {
    // Mapping from the old address ("one") to the new address ("second")
    mapping(address => address) private modifyAddresses;
    // Track keys from the mapping since mappings are not iterable
    address[] private modifyKeys;

    function modifyAddress(address from, address to) internal {
        modifyKeys.push(from);
        modifyAddresses[from] = to;
    }

    function save() internal {
        // Dump the genesis state to a JSON file.
        string memory genesisPath = "genesis_alloc.json";
        console2.log("Dumping genesis state to:", genesisPath);
        vm.dumpState(genesisPath);

        // For each address pair, generate a bash command using jq:
        // It sets alloc[second] equal to alloc[one] and then deletes alloc[one].
        for (uint i = 0; i < modifyKeys.length; i++) {
            address oldAddr = modifyKeys[i];          // "one"
            address newAddr = modifyAddresses[oldAddr]; // "second"
            string memory oldStr = toAsciiString(oldAddr);
            string memory newStr = toAsciiString(newAddr);
            // The jq command uses the alloc object: It copies the content from key "0x{oldStr}"
            // to key "0x{newStr}" then deletes the old key.
            string memory command = string(
                    abi.encodePacked(
                        "jq '.\"0x", 
                        newStr, 
                        "\" = .\"0x", 
                        oldStr, 
                        "\" | del(.\"0x", 
                        oldStr,
                        "\")' ",
                        genesisPath,
                        " > genesis_alloc2.json && mv genesis_alloc2.json genesis_alloc.json"
                    )
                );
            Process.bash(command);
        }
    }

    // Helper function to convert an address to its lowercase hex string (without the "0x" prefix)
    function toAsciiString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint(uint160(x)) / (2 ** (8 * (19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2 * i] = char(hi);
            s[2 * i + 1] = char(lo);
        }
        return string(s);
    }

    // Helper function to convert a byte into its ASCII hex character.
    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) {
            return bytes1(uint8(b) + 48); // '0' = 48 in ASCII
        } else {
            return bytes1(uint8(b) + 87); // 'a' = 97 in ASCII, so 97 - 10 = 87
        }
    }
}

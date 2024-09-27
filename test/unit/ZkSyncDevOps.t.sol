// SPDX-License-Identifier: MIT
//this file to check which error show in ZkSync but not in Vanilla Foundry
// and show Error in Vanilla Foundry which is not shown in ZKSync
pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
//this library to do a certain test for Zksync or on other evm chains
import {ZkSyncChainChecker} from "lib/foundry-devops/src/ZkSyncChainChecker.sol";

//this for foundry scoop
//this library to do a certain test on vanilla foundryu or only run certain tests on zksync foundry
import {FoundryZkSyncChecker} from "lib/foundry-devops/src/FoundryZkSyncChecker.sol";

contract ZkSyncDevOps is Test, ZkSyncChainChecker, FoundryZkSyncChecker {
    // Remove the `skipZkSync`, then run `forge test --mt testZkSyncChainFails --zksync` and this will fail!
    //--zkysnch mean we running on a zksync type network
    //if have skipZkSync we gonna skip the ZkSync test
    function testZkSyncChainFails() public skipZkSync {
        address ripemd = address(uint160(3));

        bool success;
        // Don't worry about what this "assembly" thing is for now
        assembly {
            success := call(gas(), ripemd, 0, 0, 0, 0, 0)
        }
        assert(success);
    }

    // You'll need `ffi=true` in your foundry.toml to run this test
    // // Remove the `onlyVanillaFoundry`, then run `foundryup-zksync` and then
    // // `forge test --mt testZkSyncFoundryFails --zksync`
    // // and this will fail!

    //onlyVanillaFoundry mean this test only gonna run if we using vanilla foundry
    // function testZkSyncFoundryFails() public onlyVanillaFoundry {
    //     bool exists = vm.keyExistsJson('{"hi": "true"}', ".hi");
    //     assert(exists);
    // }
}

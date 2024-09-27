// SPDX-License-Identifier: MIT

// this test file is to test

//Check test with (forge coverage)
pragma solidity ^0.8.24;

//this import from Foundry library  ( CHeat COde)
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

//Declare as is Test for library know when its run this is a Test Contract
contract InteractionTest is Test {
    FundMe fundMe;

    //this code is to make new fake user that send transaction
    //makeAddr to make the new address for the fake user
    //for test
    address USER = makeAddr("user");

    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();

        //vm.deal is cheatcode for give the fake user a balance to do transaction
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        //code below is to fund our script into the fundMe address
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        //code below is to withdraw using our script from the fundMe Address
        withdrawFundMe.withdrawFundMe(address(fundMe));

        //set the balance in the address = 0
        assert(address(fundMe).balance == 0);
    }
}

// SPDX-License-Identifier: MIT

// this test file is to test

//Check test with (forge coverage)
pragma solidity ^0.8.24;

//this import from Foundry library  ( CHeat COde)
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

//Declare as is Test for library know when its run this is a Test Contract
contract FundMeTest is Test {
    FundMe fundMe;

    //this code is to make new fake user that send transaction
    //makeAddr to make the new address for the fake user
    //for test
    address USER = makeAddr("user");

    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    //every function is running loop, setUp() FUnction -> next fUnction
    //after test the function its gonna loop and start the SetUp() function again and do the next Test Function
    function setUp() external {
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundme = new DeployFundMe();
        fundMe = deployFundme.run();

        //vm.deal is cheatcode for give the fake user a balance to do transaction
        vm.deal(USER, STARTING_BALANCE);
    }

    //Test to check the Variable MinimumUSD is it 5e18 long
    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    //Check Owner
    function testOwnerIsSender() public view {
        //console.log(fundMe.i_owner());
        //console.log(msg.sender);
        //assertEq(fundMe.i_owner(), address(this));
        assertEq(fundMe.getOwner(), msg.sender);
    }

    //To Run Single test Function  (forge test --match-contract FundMeTest --match-test testPriceFeedVersionIsAccurate -vvv --fork-url $SEPOLIA_RPC_URL)
    //fork url SEPOLIA because we call getVersion that including contract address, and we search the value from the url by address
    function testPriceFeedVersionIsAccurate() public view {
        //console.log(fundMe.getVersion());
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    //what can we do to work with address from outside our system ?
    //1. Unit
    //  -- Testing a specific part of our code
    //2. Integration
    //  -- Testing how our code works with other parts of our code
    //3. Forked
    //  -- Testing our code on a simulated real environment
    //4. Staging
    //  -- Testing our code in a real environment that is not prod (mainnet or testnet)

    function testFundFailWithoutEnoughEth() public {
        //vm.expectRevert is cheat code from Foundry
        vm.expectRevert(); //Hey the next line should revert !
        //assert(this tx fails/revert)
        fundMe.fund(); //<-- this code not send value which is 0 < 5$ then expectRevert function active
            //we do this to test every function in contract is valid and also do increace **forge coverge** to 100%
    }

    function testFundUpdateFundedDataStructure() public {
        //The next code after vm.prank(USER) is mean the fundMe.Fund{value:10e18} is sent by this fake USER
        //for testing, its like a demo user
        vm.prank(USER);
        //fundme to pass value need {} like the code below
        fundMe.fund{value: SEND_VALUE}();
        //address(this) is the address who called fundMe.fund() which is this contract
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunders(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    //test function withdraw in the FundMe.Sol
    function testOnlyOwnerCanWithdraw() public funded {
        //expectRevert is like we expect to test the withdraw not work when another USER (fake user) run it
        //the vm is expect the fundMe.Withdraw is not work or revert or f
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    //this function to test withdraw with actual Owner that can Withdraw (SINGLE FUNDER)
    function testWithdrawWithASingleFunder() public funded {
        //Test structure have 3 (arrange -> act -> and assert)
        //Arrange (set up) the test
        //get owner balance
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act (Action) the test
        //gasleft() is built in function in solidity to tell how many gas left after we send the gas
        //when we sent we set gas limit, and after transaction we want to know how much gas we spent like in the detail transaction in blockchain

        //uint256 gasStart = gasleft(); //<-- ex sent 1000 gass
        //txGasPrice is cheat code from foundry for pretend to use actual gas price
        //vm.txGasPrice(GAS_PRICE);

        //create fake user (prank) that perform like an owner to test, and then test to run the fundMe.withdraw()

        vm.prank(fundMe.getOwner());
        fundMe.withdraw(); // this cost 200 gas

        //uint256 gasEnd = gasleft(); //<-- left 800

        //tx.gasprice is built in solidity to tell what is current gas price
        //uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        //console.log(gasUsed);

        //Assert the test
        //after Execution (withdraw all of the money (test)) we make a new variable to see the value
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalancde = address(fundMe).balance;

        assertEq(endingFundMeBalancde, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
    }

    function testWithdrawFromMultipleFunders() public funded {
        //Arrange SET UP
        //uint160 has the same amount of bytes like an address
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            //here we create :
            //vm.prank -> new address
            //vm.deal -> the new address with money (set the money to the address)
            //fund the fundMe
            hoax(address(i), SEND_VALUE); //<-- HOAX is cheat code from foundry to set the address and input fund (same like vm.prank + vm.deal)
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        //between startPrank and StopPrank gonna pretend to be the fundMe.getOwner() is the Owner or
        //in other words that the fundMe.withdraw is run or executed by fundMe.getOwner(); in the startPrank Code
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        //assert
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
    }

    //This function is execute the Cheaper Gas
    function testWithdrawFromMultipleFundersCheaper() public funded {
        //Arrange SET UP
        //uint160 has the same amount of bytes like an address
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            //here we create :
            //vm.prank -> new address
            //vm.deal -> the new address with money (set the money to the address)
            //fund the fundMe
            hoax(address(i), SEND_VALUE); //<-- HOAX is cheat code from foundry to set the address and input fund (same like vm.prank + vm.deal)
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        //between startPrank and StopPrank gonna pretend to be the fundMe.getOwner() is the Owner or
        //in other words that the fundMe.withdraw is run or executed by fundMe.getOwner(); in the startPrank Code
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        //assert
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
    }
}

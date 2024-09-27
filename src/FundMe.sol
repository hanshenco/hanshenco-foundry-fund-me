//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;
//Chainlink is the easiest place to get feed data especially price
//this import is import from Github (NPM), Remix smart enough to recognize this and gonna download from github for us
//import this because we need to get the ABI to getPrice Function

//Constant Keyword nad Immutable keyword can make gas cheaper

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe_notOwner();

contract FundMe {
    //using PriceConverter Library from the PriceCOnverter.sol files
    using PriceConverter for uint256;

    //declare variable with value in usd
    //times e18 to get 18 zero decimal that match with wei Ethereum
    uint256 public constant MINIMUM_USD = 5e18;
    AggregatorV3Interface private s_priceFeed;

    //s_ to said this variable is storage variable
    //change variable to private more gas efficient
    mapping(address => uint256) private s_addressToAmountFunded;
    address[] private s_funders;

    //i_owner is public, but change to private to run the function getOwner to pass the variable to the FundMeTest.t.sol
    address private immutable i_owner;

    //pass the priceFeed address
    constructor(address priceFeed) {
        //msg.sender is deployer of this contract
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    //====================================================================================================
    //make the function by adding payable, to allow this function payable or accept native cryptocurrency
    //function to recieve native token in blockchain need to put payable
    function fund() public payable {
        //Allow users to send $ money
        //Have a minimum $ Sent
        //1 How do we send ETH to this Contract ?
        //number of wei sent with msg.value (msg.value is price in ETH)
        //this code require user sent minimum 1 ETH (1e18)
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "Didn't Send Enough ETH you broke"); //1e18 = 1ETH = 1000000000000000000 = 1 * 10 ** 18

        //revert is action that undo any actions that have been done, and send the remaining gas back
        //if fail it call revert
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
        //or s_addressToAmountFunded[msg.sender] = s_addressToAmountFunded[msg.sender] + msg.value;
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    //this code same like withdraw function but its cheaper in gas
    function cheaperWithdraw() public onlyOwner {
        //only read from storage one time, to make it cheaper because read from storage cost big gas
        uint256 fundersLength = s_funders.length;
        for (uint256 funderIndex = 0; funderIndex < fundersLength; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);

        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call Failed");
    }

    function withdraw() public onlyOwner {
        //For Loop
        //for(/* starting index, ending index, step amount*/)
        //this for loop to Empty the fund that we recieve in each array (address that sent the ETH)
        for (uint256 funderIndex = 0; funderIndex < s_funders.length; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        //reset array
        s_funders = new address[](0);

        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call Failed");
    }

    //Create modifier, is allowing to create keyword to put into the any function we need
    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert FundMe_notOwner();
        }
        _;
        //Can add another code if after execute need to do something
    }

    //Receive() and fallback() to prevent people send ETH without trigger the Fund Function
    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    //View / Pure functions (Getters)

    //the name of variable or any function or anything make sure its readable

    //function below to check if this Address are populated
    function getAddressToAmountFunded(address fundingAddress) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    //function below to check if this Address are populated
    function getFunders(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }
}

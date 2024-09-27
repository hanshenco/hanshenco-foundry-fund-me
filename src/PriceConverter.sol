// SPDX-License-Identifier: MIT

//this files is as Library

pragma solidity ^0.8.24;
//Chainlink is the easiest place to get feed data especially price
//this import is import from Github (NPM), Remix smart enough to recognize this and gonna download from github for us
//import this because we need to get the ABI to getPrice Function

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    //because not modified the function we make function as view returns
    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        //get the price from Chainlink ETH/USD Address in the Chainlink Docs
        //we need Adresss ( 0x694AA1769357215DE4FAC081bf1f309aDC325306 ) and ABI
        //variable inside () below is refer to the ChainLink Docs in Sepolia Testnet Code
        //https://docs.chain.link/data-feeds/price-feeds/addresses?network=ethereum&page=1

        (, int256 answer,,,) = priceFeed.latestRoundData();

        // the price variable up there is price of ETH in terms of USD
        // why price * 1e10, because the int256 price on line 23 is show value with 8 DEcimals
        //because msg.value is 18 Zero wei, we need to match it so need to * 1e10

        return uint256(answer * 10000000000);
    }

    function getConversionRate(uint256 ethAmount, AggregatorV3Interface priceFeed) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        //rule : always multiply (*) before divide (/)
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        return ethAmountInUsd; // return the value in USD
    }

    function getVersion(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        return priceFeed.version();
    }
}

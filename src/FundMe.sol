// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./priceconverter.sol";

error FundMe__notOwner(address caller);

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5 * 10 ** 18;

    address[] private s_funders;

    mapping(address funders => uint256 amount) private s_amountToFunders;
    address private immutable i_owner;
    AggregatorV3Interface private s_priceFeed;

    constructor(address pricefeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(pricefeed);
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) revert FundMe__notOwner(msg.sender);
        _;
    }

    function fund() public payable {
        require(msg.value.conversionToUsd(s_priceFeed) >= MINIMUM_USD, "Send more then 5 dollars worth of ETH");
        s_funders.push(msg.sender);
        s_amountToFunders[msg.sender] = msg.value;
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function withdraw() public onlyOwner {
        for (uint8 i = 0; i < s_funders.length; i++) {
            address funder = s_funders[i];
            s_amountToFunders[funder] = 0;
        }

        s_funders = new address[](0);

        (bool success,) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "Transaction Failed");
    }
    function CheaperWithdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length;
        for (uint8 i = 0; i < fundersLength; i++) {
            address funder = s_funders[i];
            s_amountToFunders[funder] = 0;
        }

        s_funders = new address[](0);

        (bool success,) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "Transaction Failed");
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    /*
      view/pure functions
      */
    function getFunders(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getAmountFundedByFunders(address fundingAddress) external view returns (uint256) {
        return s_amountToFunders[fundingAddress];
    }
    function getOwner() external view returns (address) {
        return i_owner;
    }
}

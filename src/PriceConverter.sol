// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getprice(AggregatorV3Interface pricefeed) internal view returns (uint256) {
        (, int256 answer,,,) = pricefeed.latestRoundData();
        return uint256(answer * 10000000000);
    }

    function conversionToUsd(uint256 ethAmount, AggregatorV3Interface pricefeed) internal view returns (uint256) {
        uint256 ethprice = getprice(pricefeed);
        uint256 amountInUsd = (ethprice * ethAmount);
        return amountInUsd;
    }
}

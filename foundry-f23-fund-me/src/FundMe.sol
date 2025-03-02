// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
using PriceConverter for uint;

contract FundMe {
    address public immutable i_owner;
    AggregatorV3Interface private s_priceFeed;
    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }
    uint constant MINIMUM_USD = 1;
    address[] public funders;
    mapping(address => uint) public addressToAmountFunded;

    error NotOwner();
    modifier onlyOwner() {
        //require(msg.sender == i_owner,"must be owner");
        if (msg.sender != i_owner) {
            revert NotOwner();
        }
        _;
    }
    function fund() public payable {
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD * 1e17,
            "Didn't send enough ETH"
        );
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value.getConversionRate(
            s_priceFeed
        );
    }
    function withdraw() public onlyOwner {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success, "Call failed");
        for (uint i = 0; i < funders.length; i++) {
            address funderAddress = funders[i];
            addressToAmountFunded[funderAddress] = 0;
        }
        funders = new address[](0);
    }
    function getVersion() public view returns (uint) {
        return AggregatorV3Interface(s_priceFeed).version();
    }
    receive() external payable {
        fund();
    }
    fallback() external payable {
        fund();
    }
}

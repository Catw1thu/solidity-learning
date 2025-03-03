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
    address[] private s_funders;
    mapping(address => uint) private s_addressToAmountFunded;

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
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }
    function withdraw() public onlyOwner {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success, "Call failed");
        for (uint i = 0; i < s_funders.length; i++) {
            address funderAddress = s_funders[i];
            s_addressToAmountFunded[funderAddress] = 0;
        }
        s_funders = new address[](0);
    }
    function getVersion() public view returns (uint) {
        return AggregatorV3Interface(s_priceFeed).version();
    }

    function getAddressToAmountFunded(
        address funderAddress
    ) public view returns (uint) {
        return s_addressToAmountFunded[funderAddress];
    }

    function getFunder(uint index) public view returns (address) {
        return s_funders[index];
    }

    receive() external payable {
        fund();
    }
    fallback() external payable {
        fund();
    }
}

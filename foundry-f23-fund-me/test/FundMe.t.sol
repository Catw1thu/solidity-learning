// // SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {FundMeScript} from "../script/FundMe.s.sol";

contract FundMeTest is Test {
    FundMe public fundMe;
    function setUp() public {
        FundMeScript fundMeScript = new FundMeScript();
        fundMe = fundMeScript.run();
    }

    function test_IsOwner() public view {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function test_FundFailWithoutEnoughETH() public {
        vm.expectRevert();
        fundMe.fund();
    }

    address user1 = makeAddr("user1");
    uint constant INITIAL_BALANCE = 5 ether;
    uint constant SEND_VALUE = 1 ether;
    function test_FundUpdateDataStruct() public {
        vm.deal(user1, INITIAL_BALANCE);
        vm.startPrank(user1);
        fundMe.fund{value: SEND_VALUE}();
        assertEq(fundMe.getAddressToAmountFunded(user1), SEND_VALUE);
        vm.stopPrank();
    }

    function test_WithdrawFromSingleFunder() public {
        vm.deal(user1, INITIAL_BALANCE);
        vm.startPrank(user1);
        fundMe.fund{value: SEND_VALUE}();
        vm.stopPrank();
        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.i_owner().balance;
        vm.startPrank(fundMe.i_owner());
        fundMe.withdraw();
        vm.stopPrank();
        assertEq(address(fundMe).balance, 0);
        assertEq(
            fundMe.i_owner().balance,
            startingOwnerBalance + startingFundMeBalance
        );
    }

    function test_WithdrawFromMutipleFunders() public {
        uint160 numFunders = 10;
        for (uint160 i = 1; i < numFunders + 1; i++) {
            hoax(address(i), INITIAL_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.i_owner().balance;
        vm.startPrank(fundMe.i_owner());
        fundMe.withdraw();
        vm.stopPrank();
        assertEq(address(fundMe).balance, 0);
        assertEq(
            fundMe.i_owner().balance,
            startingOwnerBalance + startingFundMeBalance
        );
        assertEq(
            fundMe.i_owner().balance - startingOwnerBalance,
            numFunders * SEND_VALUE
        );
    }
}

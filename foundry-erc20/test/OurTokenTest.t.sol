// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {OurToken} from "../src/OurToken.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {Test} from "forge-std/Test.sol";

contract OurTokenTest is Test {
    DeployOurToken public deployOurToken;
    OurToken public ourToken;

    address addr1 = makeAddr("addr1");
    address addr2 = makeAddr("addr2");

    uint256 public constant STARTING_BALANCE = 100 ether;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    error ERC20InsufficientAllowance(
        address owner,
        uint256 currentAllowance,
        uint256 amount
    );
    error ERC20InsufficientBalance(
        address from,
        uint256 balance,
        uint256 amount
    );

    function setUp() public {
        deployOurToken = new DeployOurToken();
        ourToken = deployOurToken.run();
    }

    /// @dev 检查初始供应量是否正确，并且部署者持有所有代币
    function testInitialSupply() public {
        uint256 totalSupply = ourToken.totalSupply();
        assertEq(totalSupply, 100 ether);
        assertEq(
            ourToken.balanceOf(msg.sender),
            deployOurToken.INITIAL_SUPPLY()
        );
    }

    /// @dev 检查名称、符号以及小数位数
    function testTokenDetails() public {
        assertEq(ourToken.name(), "OurToken");
        assertEq(ourToken.symbol(), "OT");
        assertEq(ourToken.decimals(), 18);
    }

    /// @dev 测试普通转账功能和余额变化
    function testTransfer() public {
        uint256 amount = 10 ether;
        uint256 msgSenderStartingBalance = ourToken.balanceOf(msg.sender);
        uint256 addr1StartingBalance = ourToken.balanceOf(addr1);

        vm.prank(msg.sender);
        vm.expectEmit(true, true, false, true);
        emit Transfer(msg.sender, addr1, amount);
        ourToken.transfer(addr1, amount);
        // 期望触发 Transfer 事件

        assertEq(
            ourToken.balanceOf(msg.sender),
            msgSenderStartingBalance - amount
        );
        assertEq(ourToken.balanceOf(addr1), addr1StartingBalance + amount);
    }

    /// @dev 测试批准操作以及对应的事件
    function testApproveAndApprovalEvent() public {
        uint256 allowanceAmount = 500;
        vm.expectEmit(true, true, false, true);
        emit Approval(address(this), addr1, allowanceAmount);
        ourToken.approve(addr1, allowanceAmount);
        assertEq(ourToken.allowance(address(this), addr1), allowanceAmount);
    }

    /// @dev 测试转账操作：从批准账户进行转账
    function testTransferFromSuccess() public {
        uint256 allowanceAmount = 500;
        uint256 transferAmount = 500;

        // 首先将一定数量代币转给 addr2，使其拥有足够余额
        vm.prank(msg.sender);
        ourToken.transfer(addr2, allowanceAmount);
        assertEq(ourToken.balanceOf(addr2), allowanceAmount);

        // addr2 批准 addr1 使用其代币
        vm.prank(addr2);
        ourToken.approve(addr1, allowanceAmount);
        assertEq(ourToken.allowance(addr2, addr1), allowanceAmount);

        // addr1 通过 transferFrom 将所有代币转走
        vm.prank(addr1);
        ourToken.transferFrom(addr2, addr1, transferAmount);

        assertEq(ourToken.balanceOf(addr2), 0);
        assertEq(ourToken.balanceOf(addr1), transferAmount);
    }

    /// @dev 测试 transferFrom 当批准额度不足时会 revert
    function testTransferFromInsufficientAllowance() public {
        uint256 allowanceAmount = 100;
        uint256 transferAmount = 200;

        vm.prank(msg.sender);
        ourToken.transfer(addr2, transferAmount);
        // addr2 批准 addr1 仅 100 个代币
        vm.prank(addr2);
        ourToken.approve(addr1, allowanceAmount);

        // addr1 尝试转走 200 个代币，应当 revert
        vm.prank(addr1);
        vm.expectRevert(
            abi.encodeWithSelector(
                ERC20InsufficientAllowance.selector,
                addr1,
                allowanceAmount,
                transferAmount
            )
        );
        ourToken.transferFrom(addr2, addr1, transferAmount);
    }

    /// @dev 测试没有批准情况下使用 transferFrom 会 revert
    function testTransferFromWithoutApproval() public {
        uint256 transferAmount = 10 ether;
        vm.prank(addr1);
        vm.expectRevert(
            abi.encodeWithSelector(
                ERC20InsufficientAllowance.selector,
                addr1,
                0,
                transferAmount
            )
        );
        ourToken.transferFrom(addr2, addr1, transferAmount);
    }

    /// @dev 测试当转账金额大于余额时会 revert
    function testTransferInsufficientBalance() public {
        uint256 senderBalance = ourToken.balanceOf(address(this));
        uint256 transferAmount = senderBalance + 1;
        vm.expectRevert(
            abi.encodeWithSelector(
                ERC20InsufficientBalance.selector,
                address(this),
                senderBalance,
                transferAmount
            )
        );
        ourToken.transfer(addr1, transferAmount);
    }
}

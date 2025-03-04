// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract ManualToken {
    mapping(address => uint256) private s_balances;
    function name() public pure returns (string memory) {
        return "Munual Token";
    }
    function totlySupply() public pure returns (uint256) {
        return 100 ether;
    }
    function decimals() public pure returns (uint8) {
        return 18;
    }
    function balanceOf(address _account) public view returns (uint256) {
        return s_balances[_account];
    }
    function transfer(address _to, uint256 _amount) public {
        uint256 previousBalance = s_balances[msg.sender] + s_balances[_to];
        s_balances[msg.sender] -= _amount;
        s_balances[_to] += _amount;
        require(
            s_balances[msg.sender] + s_balances[_to] == previousBalance,
            "Transfer failed"
        );
    }
}

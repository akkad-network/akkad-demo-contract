// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract ABTCVault {
    address public owner;

    event Deposit(address indexed user, uint256 amount);

    event Transfer(address indexed to, uint256 amount);

    event Withdraw(address indexed owner, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    function deposit() external payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        emit Deposit(msg.sender, msg.value);
    }

    function transfer(address payable _to, uint256 _amount) external onlyOwner {
        require(
            address(this).balance >= _amount,
            "Insufficient contract balance"
        );
        require(_to != address(0), "Invalid address");

        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Transfer failed");

        emit Transfer(_to, _amount);
    }

    function withdraw(uint256 _amount) external onlyOwner {
        require(
            address(this).balance >= _amount,
            "Insufficient contract balance"
        );

        (bool success, ) = payable(owner).call{value: _amount}("");
        require(success, "Withdraw failed");

        emit Withdraw(owner, _amount);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}

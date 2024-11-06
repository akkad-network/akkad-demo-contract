// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract ABTCVault {
    address public owner;

    event Deposit(address indexed user, uint256 amount);

    event Transfer(address indexed to, uint256 amount);

    event Redeem(address indexed user, uint256 amount, uint8 chainIndex);

    mapping(address => RedeemRequest[]) public redeemRequests;
    struct RedeemRequest {
        address user;
        uint256 amount;
        uint8 chainIndex;
    }

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

    function redeem(uint8 _chainIndex) external payable {
        require(msg.value > 0, "Redeem amount must be greater than zero");

        // Record the redeem request for the user
        redeemRequests[msg.sender].push(
            RedeemRequest({
                user: msg.sender,
                amount: msg.value,
                chainIndex: _chainIndex
            })
        );

        emit Redeem(msg.sender, msg.value, _chainIndex);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}

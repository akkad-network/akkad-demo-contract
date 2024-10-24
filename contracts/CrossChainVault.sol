// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CrossChainVault {
    address public owner;
    IERC20 public baseToken;

    mapping(address => uint256) public deposits;

    enum Chain {
        Sepolia,
        Holesky
    }

    event Deposit(address indexed user, uint256 amount);
    event RedeemRequest(address indexed user, address indexed to);
    event CrossChainTransfer(
        address indexed user,
        address indexed to,
        Chain targetChain,
        uint256 amount
    );

    constructor(address _baseToken) {
        require(_baseToken != address(0), "Invalid token address");
        owner = msg.sender;
        baseToken = IERC20(_baseToken);
    }

    function deposit(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than zero");

        require(
            baseToken.transferFrom(msg.sender, address(this), _amount),
            "Transfer failed"
        );

        deposits[msg.sender] += _amount;

        emit Deposit(msg.sender, _amount);
    }

    function redeem(address _to) external {
        require(_to != address(0), "Invalid target address");

        emit RedeemRequest(msg.sender, _to);
    }

    function crossChainTransfer(
        address _to,
        uint8 _targetChainIndex,
        uint256 _amount
    ) external {
        require(_to != address(0), "Invalid target address");
        require(_amount > 0, "Amount must be greater than zero");
        require(
            _targetChainIndex < uint8(type(Chain).max),
            "Invalid target chain"
        );
        require(deposits[msg.sender] >= _amount, "Insufficient balance");

        deposits[msg.sender] -= _amount;

        emit CrossChainTransfer(
            msg.sender,
            _to,
            Chain(_targetChainIndex),
            _amount
        );
    }

    function getDeposit(address _user) external view returns (uint256) {
        return deposits[_user];
    }
}

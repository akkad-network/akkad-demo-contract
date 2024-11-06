// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CrossChainVault {
    address public owner;

    // Mapping to store multiple ERC20 tokens
    mapping(address => IERC20) public tokens;

    // Mapping to store deposits for each user and token
    mapping(address => mapping(address => uint256)) public deposits;

    // Mapping to store cross-chain deposits for each user and token
    struct CrossChainDeposit {
        address user;
        Chain targetChain;
        address token;
        uint256 amount;
    }
    mapping(address => CrossChainDeposit[]) public crossChainDeposits;

    enum Chain {
        Sepolia,
        Holesky
    }

    event Deposit(address indexed user, address indexed token, uint256 amount);
    event CrossChainDepositEvent(
        address indexed user,
        Chain targetChain,
        address indexed token,
        uint256 amount
    );
    event NativeTokenTransfer(address indexed to, uint256 amount);

    constructor(address[] memory _tokens) {
        require(_tokens.length > 0, "At least one token required");
        owner = msg.sender;

        // Initialize supported tokens
        for (uint256 i = 0; i < _tokens.length; i++) {
            require(_tokens[i] != address(0), "Invalid token address");
            tokens[_tokens[i]] = IERC20(_tokens[i]);
        }
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    function deposit(address _token, uint256 _amount) external {
        require(tokens[_token] != IERC20(address(0)), "Unsupported token");
        require(_amount > 0, "Amount must be greater than zero");

        require(
            tokens[_token].transferFrom(msg.sender, address(this), _amount),
            "Transfer failed"
        );

        deposits[msg.sender][_token] += _amount;

        emit Deposit(msg.sender, _token, _amount);
    }

    function crossChainDeposit(
        uint8 _targetChainIndex,
        address _token,
        uint256 _amount
    ) external {
        require(tokens[_token] != IERC20(address(0)), "Unsupported token");
        require(_amount > 0, "Amount must be greater than zero");
        require(
            _targetChainIndex < uint8(type(Chain).max),
            "Invalid target chain"
        );

        // Transfer the token to this contract
        require(
            tokens[_token].transferFrom(msg.sender, address(this), _amount),
            "Transfer failed"
        );

        // Record the cross-chain deposit request
        crossChainDeposits[msg.sender].push(
            CrossChainDeposit({
                user: msg.sender,
                targetChain: Chain(_targetChainIndex),
                token: _token,
                amount: _amount
            })
        );

        emit CrossChainDepositEvent(
            msg.sender,
            Chain(_targetChainIndex),
            _token,
            _amount
        );
    }

    function getDeposit(
        address _user,
        address _token
    ) external view returns (uint256) {
        return deposits[_user][_token];
    }

    // Function to retrieve a user's cross-chain deposit requests
    function getCrossChainDeposits(
        address _user
    ) external view returns (CrossChainDeposit[] memory) {
        return crossChainDeposits[_user];
    }

    // Allow contract to receive native tokens
    receive() external payable {}
}

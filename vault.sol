pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract StakedETHVault {

    address public owner;

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed to, uint256 amount);

    mapping(address => uint256) public tokenDeposits;
    mapping(address => mapping(address => uint256)) public userDeposits;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function deposit(uint256 amount, address _assetToDeposit) external {
        IERC20 assetToDeposit = IERC20(_assetToDeposit);
        require(assetToDeposit.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        tokenDeposits[_assetToDeposit] += amount;
        userDeposits[msg.sender][_assetToDeposit] += amount;
        emit Deposited(msg.sender, amount);
    }

    function withdrawToOwner(uint256 amount, address _assetToWithdraw) external onlyOwner {
        IERC20 assetToWithdraw = IERC20(_assetToWithdraw);
        require(assetToWithdraw.transfer(owner, amount), "Transfer failed");
        tokenDeposits[_assetToWithdraw] -= amount;
        emit Withdrawn(owner, amount);
    }

    function changeOwner(address newOwner) external onlyOwner {
        owner = newOwner;
    }
}

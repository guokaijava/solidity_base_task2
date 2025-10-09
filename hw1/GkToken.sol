// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract GkToken {

    string public name; // 代币名
    string public symbol; // 代币标识
    uint8 public decimals; // 发行代币小数位 - 18
    uint256 public totalSupply; // 代币总量
    address public owner;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // 记录转账操作
    event Transfer(address indexed from, address indexed to, uint256 value);
    // 记录授权操作
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // 初始化合约 - 给合约所有者初始化代币量
    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _initialSupply){
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        owner = msg.sender;
        _mint(msg.sender, _initialSupply * (10 ** uint256(decimals)));  // 发行代币
    }

    // 查询余额
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    // 转账
    function transfer(address to, uint256 amount) public returns (bool) {
        require(to != address(0), "ERC20: transfer to the zero address");
        require(_balances[msg.sender] >= amount, "ERC20: transfer amount exceeds balance");

        _balances[msg.sender] -= amount;
        _balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    // 授权（A->B授权量）
    function approve(address spender, uint256 amount) public returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    // 查询授权信息
    function allowance(address _owner, address spender) public view returns (uint256) {
        return _allowances[_owner][spender];
    }
    // 代扣转账
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(_allowances[from][msg.sender] >= amount, "ERC20: transfer amount exceeds allowance");
        require(_balances[from] >= amount, "ERC20: transfer amount exceeds balance");
        require(to != address(0), "ERC20: transfer to the zero address");

        _balances[from] -= amount;
        _balances[to] += amount;
        _allowances[from][msg.sender] -= amount;
        emit Transfer(from, to, amount);
        return true;
    }

    // 合约所有者增发代币
    function mint(address to, uint256 amount) public {
        require(msg.sender == owner, "ERC20: only owner can mint");
        _mint(to, amount);
    }

    // 内部方法 - 增发代币
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BeggingContract {


    mapping(address=>uint256) public donations;
    address private _owner;
    address[] private  _accounts;
    uint256 public donationStartTime;
    uint256 public donationEndTime;

    event Donation(address indexed donor, uint256 amount);
    event DonationPeriodSet(uint256 start, uint256 end);

    constructor(){
        _owner = msg.sender;
    }
        
    modifier onlyOwner() {
        require(msg.sender == _owner, "Only owner can call this function");
        _;
    }

    modifier duringDonationPeriod() {
        require(block.timestamp >= donationStartTime && block.timestamp <= donationEndTime, 
                "Donations are only accepted during the specified period");
        _;
    }

    function setDonationPeriod(uint256 _startTime, uint256 _endTime) external onlyOwner {
        require(_startTime < _endTime, "Start time must be before end time");
        donationStartTime = _startTime;
        donationEndTime = _endTime;
        emit DonationPeriodSet(_startTime, _endTime);
    }

    function donate() public payable {
        require(msg.value > 0, "Donation amount must be greater than 0");
        if (donations[msg.sender] == 0) {
            _accounts.push(msg.sender);
        }
        donations[msg.sender] += msg.value;
        emit Donation(msg.sender, msg.value);
    }

    function withdraw() public onlyOwner {
        // payable(_owner).transfer(address(this).balance);
        (bool success, ) = _owner.call{value: address(this).balance}("");
        require(success, "Withdrawal failed");
    }

    function getDonation(address donor) public view returns (uint256) {
        return donations[donor];
    }

    function getTopDonors() public view returns (address[3] memory, uint256[3] memory) {
        address[3] memory topAddresses;
        uint256[3] memory topAmounts;
        
         for (uint i = 0; i < _accounts.length; i++) {
            address currentAddr = _accounts[i];
            uint256 currentBal = donations[currentAddr];
            
            // 检查是否能进入前三
            for (uint j = 0; j < 3; j++) {
                if (currentBal > topAmounts[j]) {
                    // 插入到当前位置，后面的元素后移
                    for (uint k = 2; k > j; k--) {
                        topAmounts[k] = topAmounts[k-1];
                        topAddresses[k] = topAddresses[k-1];
                    }
                    topAmounts[j] = currentBal;
                    topAddresses[j] = currentAddr;
                    break;
                }
            }
        }
        
        return (topAddresses, topAmounts);
    }
}
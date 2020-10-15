/// SPDX-License-Identifier: Mit
pragma solidity ^0.6.12;

contract SimpleBank {

    //
    // State variables
    //
    mapping (address => uint) private balances;
    mapping (address => bool) public enrolled;
    address public owner = msg.sender;

    event LogEnrolled(address accountAddress);
    event LogDepositMade(address accountAddress, uint amount);
    event LogWithdrawal(address accountAddress, uint withdrawAmount, uint newBalance);


    modifier isEnrolled() {
      require(enrolled[msg.sender], 'expected sender to bel enrolled');
      _;
    }

    modifier isNotEnrolled() {
      require(!enrolled[msg.sender], 'expect sender to not be enrolled');
      _;
    }

    modifier hasEnoughFunds(uint amt) {
      require(balances[msg.sender] >= amt, 'not enough funds');
      _;
    }

    fallback() external payable { revert(); }

    /// @notice Get balance
    /// @return The balance of the user
    /// TODO: why does removing view make the tests fail
    function getBalance() public view returns (uint) {
        return balances[msg.sender];
    }

    /// @notice Enroll a customer with the bank
    /// @return The users enrolled status
    function enroll() public isNotEnrolled() returns (bool){
      emit LogEnrolled(msg.sender);
      enrolled[msg.sender] = true;
      return enrolled[msg.sender];
    }

    /// @notice Deposit ether into bank
    /// @return The balance of the user after the deposit is made
    function deposit() public payable isEnrolled() returns (uint) {
      balances[msg.sender] += msg.value;
      emit LogDepositMade(msg.sender, msg.value);
      return balances[msg.sender];
    }

    /// @notice Withdraw ether from bank
    /// @dev This does not return any excess ether sent to it
    /// @param withdrawAmount amount you want to withdraw
    /// @return The balance remaining for the user
    function withdraw(uint withdrawAmount) public hasEnoughFunds(withdrawAmount) returns (uint) {
      balances[msg.sender] -= withdrawAmount;
      msg.sender.transfer(withdrawAmount);
      emit LogWithdrawal(msg.sender, withdrawAmount, balances[msg.sender]);
      return balances[msg.sender];
    }
}

/*

  Copyright 2017 Bitnan.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/
pragma solidity ^0.4.11;

import "./StandardToken.sol";


contract BitnanRewardToken is StandardToken {
    /* constants */
    string public constant NAME = "BitnanRewardToken";
    string public constant SYMBOL = "BRT";
    uint public constant DECIMALS = 18;
    uint256 public constant ETH_MIN_GOAL = 3000 ether;
    uint256 public constant ETH_MAX_GOAL = 6000 ether;
    uint256 public constant ORIGIN_ETH_BRT_RATIO = 3000;
    uint public constant UNSOLD_SOLD_RATIO = 50;
    uint public constant PHASE_NUMBER = 5;
    uint public constant BLOCKS_PER_PHASE = 30500;
    uint8[5] public bonusPercents = [
      20,
      15,
      10,
      5,
      0
    ];

    /* vars */
    address public owner;
    uint public totalEthAmount = 0;
    uint public tokenIssueIndex = 0;
    uint public deadline;
    uint public durationInDays;
    uint public startBlock = 0;
    bool public isLeftTokenIssued = false;


    /* events */
    event TokenSaleStart();
    event TokenSaleEnd();
    event FakeOwner(address fakeOwner);
    event CommonError(bytes error);
    event IssueToken(uint index, address addr, uint ethAmount, uint tokenAmount);
    event TokenSaleSucceed();
    event TokenSaleFail();
    event TokenSendFail(uint ethAmount);

    /* modifier */
    modifier onlyOwner {
      if(msg.sender != owner) {
        FakeOwner(msg.sender);
        revert();
      }
      _;        
    }
    modifier beforeSale {
      if(!saleInProgress()) {
        _;
      }
      else {
        CommonError('Sale has not started!');
        revert();
      }
    }
    modifier inSale {
      if(saleInProgress() && !saleOver()) {
        _;
      }
      else {
        CommonError('Token is not in sale!');
        revert();
      }
    }
    modifier afterSale {
      if(saleOver()) {
        _;
      }
      else {
        CommonError('Sale is not over!');
        revert();
      }
    }
    /* functions */
    function () payable {
      issueToken(msg.sender);
    }
    function issueToken(address recipient) payable inSale {
      assert(msg.value >= 0.01 ether);
      uint tokenAmount = generateTokenAmount(msg.value);
      totalEthAmount = totalEthAmount.add(msg.value);
      totalSupply = totalSupply.add(tokenAmount);
      balances[recipient] = balances[recipient].add(tokenAmount);
      IssueToken(tokenIssueIndex, recipient, msg.value, tokenAmount);
      if(!owner.send(msg.value)) {
        TokenSendFail(msg.value);
        revert();
      }
    }
    function issueLeftToken() internal {
      if(isLeftTokenIssued) {
        CommonError("Left tokens has been issued!");
      }
      else {
        require(totalEthAmount >= ETH_MIN_GOAL);
        uint leftTokenAmount = totalSupply.mul(UNSOLD_SOLD_RATIO).div(100);
        totalSupply = totalSupply.add(leftTokenAmount);
        balances[owner] = balances[owner].add(leftTokenAmount);
        IssueToken(tokenIssueIndex++, owner, 0, leftTokenAmount);
        isLeftTokenIssued = true;
      }
    }
    function BitnanRewardToken(address _owner) {
      owner = _owner;
    }
    function start(uint _startBlock) public onlyOwner beforeSale {
      startBlock = _startBlock;
      TokenSaleStart();
    }
    function close() public onlyOwner afterSale {
      if(totalEthAmount < ETH_MIN_GOAL) {
        TokenSaleFail();
      }
      else {
        issueLeftToken();
        TokenSaleSucceed();
      }
    }
    function generateTokenAmount(uint ethAmount) internal constant returns (uint tokenAmount) {
      uint phase = (block.number - startBlock).div(BLOCKS_PER_PHASE);
      if(phase >= bonusPercents.length) {
        phase = bonusPercents.length - 1;
      }
      uint originTokenAmount = ethAmount.mul(ORIGIN_ETH_BRT_RATIO);
      uint bonusTokenAmount = originTokenAmount.mul(bonusPercents[phase]).div(100);
      tokenAmount = originTokenAmount.add(bonusTokenAmount);
    }
    /* constant functions */
    function saleInProgress() constant returns (bool) {
      return (startBlock > 0 && block.number >= startBlock);
    }
    function saleOver() constant returns (bool) {
      return startBlock > 0 && (saleOverInTime() || saleOverReachMaxETH());
    }
    function saleOverInTime() constant returns (bool) {
      return block.number >= startBlock + BLOCKS_PER_PHASE * PHASE_NUMBER;
    }
    function saleOverReachMaxETH() constant returns (bool) {
      return totalEthAmount >= ETH_MAX_GOAL;
    }
}
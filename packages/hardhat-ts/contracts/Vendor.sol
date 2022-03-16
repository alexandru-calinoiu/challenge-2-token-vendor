pragma solidity >=0.8.0 <0.9.0;
// SPDX-License-Identifier: MIT

//import "@openzeppelin/contracts/access/Ownable.sol";
import './YourToken.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract Vendor is Ownable {
  uint256 public constant tokensPerEth = 100;

  YourToken yourToken;

  event BuyTokens(address buyer, uint256 amountOfEth, uint256 amountOfToken);

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  function buyTokens() external payable {
    uint256 tokensToTransfer = msg.value * tokensPerEth;
    bool tokensWhereTransfered = yourToken.transfer(msg.sender, tokensToTransfer);
    require(tokensWhereTransfered, 'Could not transfer tokens, because ETH sucks you will still be charged fees');
    emit BuyTokens(msg.sender, msg.value, tokensToTransfer);
  }

  function withdraw() external {
    (bool success, ) = owner().call{value: address(this).balance}('');
    require(success, 'Unable to withdraw');
  }

  function sellTokens(uint256 amount) external {
    bool success = yourToken.transferFrom(msg.sender, address(this), amount);
    require(success, 'Transfer failed, maybe not approved?');
    (bool payedSeller, ) = msg.sender.call{value: amount / tokensPerEth}('');
    require(payedSeller, 'Could not pay the seller');
  }
}

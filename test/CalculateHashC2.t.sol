// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "lib/forge-std/src/Test.sol";

import "src/Mooniswap.sol";

contract CalculateHash is Test {
  
  function testCalc() public {
    bytes memory PAIR_INIT_CODE_C2 = type(Mooniswap).creationCode;
    bytes32 PAIR_INIT_CODE_HASH_C2 = bytes32(keccak256(abi.encodePacked(PAIR_INIT_CODE_C2)));
    console.logString("PAIR_INIT_CODE_HASH_C2:");
    console.logBytes32(PAIR_INIT_CODE_HASH_C2);
  }
}
 

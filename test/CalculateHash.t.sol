// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "lib/forge-std/src/Test.sol";

import "src/MooniFactory.sol";
import "src/Mooniswap.sol";

import {TokenCustomDecimalsMock} from "src/mocks/TokenCustomDecimalsMock.sol";
import {ElasticMock} from "src/mocks/ElasticMock.sol";
import {MockSOHM} from "src/mocks/MockSOHM.sol";
import {WETH9} from "src/mocks/WETH9.sol";

contract CalculateHash is Test {
  
  TokenCustomDecimalsMock mockToken1;
  TokenCustomDecimalsMock mockToken0;
  MooniFactory factory;

    function setUp() public {

      mockToken1 = new TokenCustomDecimalsMock(
        "Token One",
        "TOK1",
        10**27,
        18
      );
      mockToken0 = new TokenCustomDecimalsMock(
        "Token Two",
        "TOK2",
        10**27,
        18
      );

      factory = new MooniFactory();
      factory.setFee(0.003e18);
      console.logAddress(factory.deploy(mockToken0,mockToken1));
  }

  bytes32 constant internal INIT_CODE_HASH = keccak256(type(Mooniswap).creationCode);
   
    /**
     * @dev Returns the address where a contract will be stored if deployed via {deploy}. Any change in the
     * `bytecodeHash` or `salt` will result in a new destination address.
     */
    function computeAddress(bytes32 salt, bytes32 bytecodeHash) internal view returns (address) {
        return computeAddress(salt, bytecodeHash, address(this));
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via {deploy} from a contract located at
     * `deployer`. If `deployer` is this contract's address, returns the same value as {computeAddress}.
     */
    function computeAddress(
        bytes32 salt,
        bytes32 bytecodeHash,
        address deployer
    ) internal pure returns (address addr) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40) // Get free memory pointer

            // |                   | ↓ ptr ...  ↓ ptr + 0x0B (start) ...  ↓ ptr + 0x20 ...  ↓ ptr + 0x40 ...   |
            // |-------------------|---------------------------------------------------------------------------|
            // | bytecodeHash      |                                                        CCCCCCCCCCCCC...CC |
            // | salt              |                                      BBBBBBBBBBBBB...BB                   |
            // | deployer          | 000000...0000AAAAAAAAAAAAAAAAAAA...AA                                     |
            // | 0xFF              |            FF                                                             |
            // |-------------------|---------------------------------------------------------------------------|
            // | memory            | 000000...00FFAAAAAAAAAAAAAAAAAAA...AABBBBBBBBBBBBB...BBCCCCCCCCCCCCC...CC |
            // | keccak(start, 85) |            ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑ |

            mstore(add(ptr, 0x40), bytecodeHash)
            mstore(add(ptr, 0x20), salt)
            mstore(ptr, deployer) // Right-aligned with 12 preceding garbage bytes
            let start := add(ptr, 0x0b) // The hashed data starts at the final garbage byte which we will set to 0xff
            mstore8(start, 0xff)
            addr := keccak256(start, 85)
        }
    }

    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
      require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
      (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
      require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

    function pairFor(address tokenA, address tokenB) public view returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        bytes memory bytecode = type(Mooniswap).creationCode;
 
        pair = computeAddress(
        keccak256(abi.encodePacked(token0, token1)),
        keccak256(bytecode),
        address(factory)
        );  
      }  
        // pair = address(uint160(bytes20(keccak256(abi.encodePacked(
        //         bytes1(0xff),///// or hex'ff'
        //         address(factory),
        //         keccak256(abi.encodePacked(IERC20(token0), IERC20(token1))),
        //         keccak256(bytecode)
        //          
        //     )))));
       
    // }

    // function pairFor2(address tokenA, address tokenB) public view returns (address pair) {
    //     (address token0, address token1) = sortTokens(tokenA, tokenB);
    //     bytes memory bytecode = type(Mooniswap).creationCode;
    //     pair = address(uint160(bytes32(keccak256(abi.encodePacked(
    //             bytes1(0xff),///// or hex'ff'
    //             address(this),
    //             keccak256(abi.encodePacked(token0, token1)),
    //             keccak256(bytecode)
    //              
    //         )))));
    //    
    // }
    function pairFor3(address tokenA, address tokenB) public view returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint160(bytes20(keccak256(abi.encodePacked(
                bytes1(0xff),///// or hex'ff'
                address(this),
                keccak256(abi.encodePacked(token0, token1)),
                hex'9815fa719f08878271726c22bcd00805d42e65ef1a123e0b0dedd07b81293e52' // init code hash
            )))));
       
    }
    // function pairFor4(address tokenA, address tokenB) public view returns (address pair) {
    //     (address token0, address token1) = sortTokens(tokenA, tokenB);
    //     pair = address(uint160(bytes32(keccak256(abi.encodePacked(
    //             bytes1(0xff),///// or hex'ff'
    //             address(this),
    //             keccak256(abi.encodePacked(token0, token1)),
    //             hex'61b42b8c3ac6ba57e9392fd523a18204ad0a03dfae16d03d113ed6b021765165' // init code hash
    //         )))));
    //    
    // }

  function testHash() public {

    // console.logString("INIT_CODE_HASH: ");
    // console.logBytes32(INIT_CODE_HASH);
    bytes memory PAIR_INIT_CODE = type(Mooniswap).creationCode;
    bytes32 PAIR_INIT_CODE_HASH = bytes32(keccak256(abi.encode(PAIR_INIT_CODE)));
    bytes32 PAIR_INIT_CODE_HASH2 = bytes32(keccak256(abi.encodePacked(PAIR_INIT_CODE)));

    (address token0, address token1) = sortTokens(address(mockToken0), address(mockToken1));
    // 
    // address computed = computeAddress(
    //   keccak256(abi.encodePacked(token0, token1)),
    //   INIT_CODE_HASH,
    //   address(factory)
    // );  
    // console.logString("computeAddress:");
    // console.logAddress(computed);

    console.logString("pairFor:");
    console.logAddress(pairFor(address(mockToken0),address(mockToken1)));
    console.logString("pairFor3:");
    console.logAddress(pairFor3(address(mockToken0),address(mockToken1)));
    console.logString("PAIR_INIT_CODE_HASH:");
    console.logBytes32(PAIR_INIT_CODE_HASH);
    console.logString("PAIR_INIT_CODE_HASH2:");
    console.logBytes32(PAIR_INIT_CODE_HASH2);

  }
} 

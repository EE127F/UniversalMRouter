// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "lib/forge-std/src/Test.sol";

// import {MooniFactory} from "src/MooniFactory.sol";
import "src/MooniFactory.sol";
// import {Mooniswap} from "src/Mooniswap.sol";
import "src/Mooniswap.sol";

import {TokenCustomDecimalsMock} from "src/mocks/TokenCustomDecimalsMock.sol";
import {TokenWithBytes32SymbolMock} from "src/mocks/TokenWithBytes32SymbolMock.sol";
import {TokenWithStringSymbolMock} from "src/mocks/TokenWithStringSymbolMock.sol";
import {TokenWithNoSymbolMock} from "src/mocks/TokenWithNoSymbolMock.sol";
import {TokenWithBytes32CAPSSymbolMock} from "src/mocks/TokenWithBytes32CAPSSymbolMock.sol";
import {WETH9} from "src/mocks/WETH9.sol";
// import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract MooniFactoryTest is Test {
    TokenCustomDecimalsMock token1;
    TokenCustomDecimalsMock token2;
    MooniFactory factory;

    function setUp() public {
        factory = new MooniFactory();
        factory.setFee(0.003e18);
        token1 = new TokenCustomDecimalsMock(
          "Token One",
          "TOK1",
          10**21,
          18
        );
        token2 = new TokenCustomDecimalsMock(
          "Token Two",
          "TOK2",
          10**21,
          18
        );
        WETH9 weth = new WETH9();
        assertEq(token1.balanceOf(address(this)),10**21);
        assertEq(token2.balanceOf(address(this)),10**21);
        assertEq(weth.balanceOf(address(this)),0);
        assertEq(factory.MAX_FEE(),factory.fee());

    }
    function testBasicDeploy() public {

        Mooniswap pool1 = Mooniswap(factory.deploy(IERC20(token1),IERC20(token2)));
        assertEq((pool1.getTokens()).length,2);
    }

    function testFailDuplicateDeploy() public {

        Mooniswap pool1 = Mooniswap(factory.deploy(token1,token2));
        assertEq((pool1.getTokens()).length,2);
        factory.deploy(token1,token2);
    }

    function testFailDuplicateDeploySwitched() public {

        Mooniswap pool1 = Mooniswap(factory.deploy(token1,token2));
        assertEq((pool1.getTokens()).length,2);
        factory.deploy(token2,token1);
    }

    //Reproducing MooniFactory tests
    //Some of these can be collapsed into a single test with fuzzing

  //   function test32BytesSymbol() public {

  //     //Mooniswap constructor checks for empty values.
  //     bytes32 _symbol1 = bytes32('ABCDEFGH');
  //     string memory _symbol2 = "Token Name ZYXW";

  //     TokenWithBytes32SymbolMock tokenBytes32 = new TokenWithBytes32SymbolMock(_symbol1);
  //     TokenWithStringSymbolMock tokenStringSymbol = new TokenWithStringSymbolMock(_symbol2);
  //     Mooniswap pool = Mooniswap(factory.deploy(IERC20(address(tokenBytes32)),IERC20(address(tokenStringSymbol))));
  //     assertEq((pool.getTokens()).length,2);
  //     
  //     //A bit overcomplicated but it will help adapt these tests to create2 later, as well as add fuzzing

  //     string memory expectedPoolName = string(abi.encodePacked("Mooniswap V1 (", _symbol1, "-", _symbol2, ")"));
  //     string memory expectedPoolNameReversed = string(abi.encodePacked("Mooniswap V1 (", _symbol2, "-", _symbol1, ")"));
  //     string memory poolName = pool.name();

  //     (IERC20(address(tokenBytes32)) < IERC20(address(tokenStringSymbol))) ? assertEq32(bytes32(bytes(poolName)),bytes32(bytes(expectedPoolName))) : assertEq32(bytes32(bytes(poolName)),bytes32(bytes(expectedPoolNameReversed)));
  // 
  //     string memory expectedPoolSymbol = string(abi.encodePacked("MOON-V1-", _symbol1, "-", _symbol2));
  //     string memory expectedPoolSymbolReversed = string(abi.encodePacked("MOON-V1-", _symbol2, "-", _symbol1));
  //     string memory poolSymbol = pool.symbol();

  //     (IERC20(address(tokenBytes32)) < IERC20(address(tokenStringSymbol))) ? assertEq32(bytes32(bytes(poolSymbol)),bytes32(bytes(expectedPoolSymbol))) : assertEq32(bytes32(bytes(poolSymbol)),bytes32(bytes(expectedPoolSymbolReversed)));
  // 
  //   }

  //   function test33CharSymbol() public {

  //     string memory _symbol1 = "012345678901234567890123456789123";
  //     string memory _symbol2 = "XYZ";

  //     TokenWithStringSymbolMock tokenStringSymbol1 = new TokenWithStringSymbolMock(_symbol1);
  //     TokenWithStringSymbolMock tokenStringSymbol2 = new TokenWithStringSymbolMock(_symbol2);
  //     Mooniswap pool = Mooniswap(factory.deploy(IERC20(address(tokenStringSymbol1)),IERC20(address(tokenStringSymbol2))));
  //     assertEq((pool.getTokens()).length,2);
  //     
  //     //A bit overcomplicated but it will help adapt these tests to create2 later, as well as add fuzzing

  //     string memory expectedPoolName = string(abi.encodePacked("Mooniswap V1 (", _symbol1, "-", _symbol2, ")"));
  //     string memory expectedPoolNameReversed = string(abi.encodePacked("Mooniswap V1 (", _symbol2, "-", _symbol1, ")"));
  //     string memory poolName = pool.name();

  //     (IERC20(address(tokenStringSymbol2)) < IERC20(address(tokenStringSymbol2))) ? assertEq32(bytes32(bytes(poolName)),bytes32(bytes(expectedPoolName))) : assertEq32(bytes32(bytes(poolName)),bytes32(bytes(expectedPoolNameReversed)));
  // 
  //     string memory expectedPoolSymbol = string(abi.encodePacked("MOON-V1-", _symbol1, "-", _symbol2));
  //     string memory expectedPoolSymbolReversed = string(abi.encodePacked("MOON-V1-", _symbol2, "-", _symbol1));
  //     string memory poolSymbol = pool.symbol();

  //     (IERC20(address(tokenStringSymbol1)) < IERC20(address(tokenStringSymbol2))) ? assertEq32(bytes32(bytes(poolSymbol)),bytes32(bytes(expectedPoolSymbol))) : assertEq32(bytes32(bytes(poolSymbol)),bytes32(bytes(expectedPoolSymbolReversed)));
  // 
  //   }  

    function testTokenEmptyString() public {

      string memory _symbol1 = "";
      string memory _symbol2 = " ";

      TokenCustomDecimalsMock tokenEmptyString = new TokenCustomDecimalsMock("Mytoken",_symbol1,10**18,18);
      TokenCustomDecimalsMock tokenSpaceString = new TokenCustomDecimalsMock("MyToken2",_symbol2,10**18,18);

      Mooniswap pool = Mooniswap(factory.deploy(IERC20(address(tokenEmptyString)),IERC20(address(tokenSpaceString))));
      assertEq((pool.getTokens()).length,2);
      console.logString(pool.name());
      console.logString(pool.symbol());
    } 

    function testTokenNoSymbolMock() public {

      string memory _symbol1 = "";

      TokenCustomDecimalsMock tokenEmptyString = new TokenCustomDecimalsMock("Mytoken",_symbol1,10**18,18);
      TokenWithNoSymbolMock tokenNoSymbol = new TokenWithNoSymbolMock();

      Mooniswap pool = Mooniswap(factory.deploy(IERC20(address(tokenEmptyString)),IERC20(address(tokenNoSymbol))));
      assertEq((pool.getTokens()).length,2);
      console.logString(pool.name());
      console.logString(pool.symbol());
    } 
    function testBytes32CAPS() public {

      TokenWithBytes32CAPSSymbolMock tokenCAPS1 = new TokenWithBytes32CAPSSymbolMock('caps1');
      TokenWithBytes32CAPSSymbolMock tokenCAPS2 = new TokenWithBytes32CAPSSymbolMock('caps2');

      Mooniswap pool = Mooniswap(factory.deploy(IERC20(address(tokenCAPS1)),IERC20(address(tokenCAPS2))));
      assertEq((pool.getTokens()).length,2);
      console.logString(pool.name());
      console.logString(pool.symbol());
    } 



  //The rest of these cases will be rewritten with fuzzing once the Factory has been adapted to use CREATE2, as the logic will change.

  //   function testTokenWithNoSymbol() public {

  //     string memory _symbol1 = "XYZ";

  //     TokenWithNoSymbolMock tokenNoSymbol = new TokenWithNoSymbolMock();
  //     TokenWithStringSymbolMock tokenStringSymbol = new TokenWithStringSymbolMock(_symbol1);

  //     Mooniswap pool = factory.deploy(IERC20(address(tokenNoSymbol)),IERC20(address(tokenStringSymbol)));
  //     assertEq((pool.getTokens()).length,2);
  //     
  //     // string memory _symbol2 = string(abi.encodePacked(address(tokenNoSymbol)));

  //     string memory uniSymbol1 = UniERC20.uniSymbol(IERC20(address(tokenNoSymbol)));
  //     string memory uniSymbol2 = UniERC20.uniSymbol(IERC20(address(tokenStringSymbol)));

  //     //A bit overcomplicated but it will help adapt these tests to create2 later, as well as add fuzzing

  //     string memory expectedPoolName = string(abi.encodePacked("Mooniswap V1 (", uniSymbol1, "-", uniSymbol2, ")"));
  //     string memory expectedPoolNameReversed = string(abi.encodePacked("Mooniswap V1 (", uniSymbol2, "-", uniSymbol1, ")"));
  //     string memory poolName = pool.name();

  //     (IERC20(address(tokenStringSymbol)) < IERC20(address(tokenNoSymbol))) ? assertEq0(bytes(poolName),bytes(expectedPoolName)) : assertEq0(bytes(poolName),bytes(expectedPoolNameReversed));
  // 
  //     string memory expectedPoolSymbol = string(abi.encodePacked("MOON-V1-", uniSymbol1, "-", uniSymbol2));
  //     string memory expectedPoolSymbolReversed = string(abi.encodePacked("MOON-V1-", uniSymbol2, "-", uniSymbol1));
  //     string memory poolSymbol = pool.symbol();

  // 
  //     (IERC20(address(tokenStringSymbol)) < IERC20(address(tokenNoSymbol))) ? assertEq0(bytes(poolSymbol),bytes(expectedPoolSymbol)) : assertEq0(bytes(poolSymbol),bytes(expectedPoolSymbolReversed));
  //   }  
}

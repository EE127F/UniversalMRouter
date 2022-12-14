// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "lib/forge-std/src/Test.sol";

import "src/MooniFactory.sol";
import "src/Mooniswap.sol";

import {TokenCustomDecimalsMock} from "src/mocks/TokenCustomDecimalsMock.sol";
import {ElasticMock} from "src/mocks/ElasticMock.sol";
import {MockSOHM} from "src/mocks/MockSOHM.sol";
import {WETH9} from "src/mocks/WETH9.sol";

contract MooniswapTest is Test {
    TokenCustomDecimalsMock token1;
    TokenCustomDecimalsMock token2;
    MockSOHM RebasingTokenOHM;
    ElasticMock RebasingTokenElastic;

    MooniFactory factory;

    function setUp() public {

        factory = new MooniFactory();
        factory.setFee(0.003e18);

        assertEq(factory.MAX_FEE(),factory.fee());

        token1 = new TokenCustomDecimalsMock(
          "Token One",
          "TOK1",
          10**27,
          18
        );
        token2 = new TokenCustomDecimalsMock(
          "Token Two",
          "TOK2",
          10**27,
          18
        );
        RebasingTokenOHM = new MockSOHM(
          10**21,
          10*10**9 //rebase %
        );
        RebasingTokenElastic = new ElasticMock(
          "Rebasing Token 2",
          "RT2",
          10**27,
          address(this) 
        );
        WETH9 weth = new WETH9();

        assertEq(token1.balanceOf(address(this)),10**27);
        assertEq(token2.balanceOf(address(this)),10**27);
        console.logUint(RebasingTokenOHM.balanceOf(address(this)));
        console.logUint(RebasingTokenOHM.index());
        assertEq(RebasingTokenElastic.balanceOf(address(this)),10**27);
        assertEq(weth.balanceOf(address(this)),0);

    }

    function testStandardPool() public {

      uint[] memory amounts = new uint[](2);
      amounts[0] = 10**25;
      amounts[1] = 10**25;

      uint[] memory amountsMin = new uint[](2);
      amountsMin[0] = 8*10**24;
      amountsMin[1] = 8*10**24;

      Mooniswap pool = Mooniswap(factory.deploy(token1,token2));
      assertEq((pool.getTokens()).length,2);

      token1.approve(address(pool),10**30);
      token2.approve(address(pool),10**30);

      pool.deposit(amounts,amountsMin);

      uint return1 = pool.swap(IERC20(token1),IERC20(token2),10**22,0,address(0));
      uint return2 = pool.swap(IERC20(token1),IERC20(token2),10**22,0,address(0));

      console.logUint(return1); 
      console.logUint(return2); 
    }

    function testRebasingPool() public {

      uint[] memory amounts = new uint[](2);
      amounts[0] = 10**25;
      amounts[1] = 10**25;

      uint[] memory amountsMin = new uint[](2);
      amountsMin[0] = 8*10**24;
      amountsMin[1] = 8*10**24;
      
      RebasingTokenOHM.mint(address(this),10**27);

      Mooniswap pool = Mooniswap(factory.deploy(RebasingTokenOHM,RebasingTokenElastic));
      assertEq((pool.getTokens()).length,2);
      
      RebasingTokenOHM.approve(address(pool),10**30);
      RebasingTokenElastic.approve(address(pool),10**30);

      pool.deposit(amounts,amountsMin);

      uint return1 = pool.swap(IERC20(RebasingTokenOHM),IERC20(RebasingTokenElastic),10**22,0,address(0));
      RebasingTokenElastic.simulateRebaseDown(address(this),5*10**26);

      uint return2 = pool.swap(IERC20(RebasingTokenOHM),IERC20(RebasingTokenElastic),10**22,0,address(0));
      RebasingTokenOHM.rebase();

      uint return3 = pool.swap(IERC20(RebasingTokenOHM),IERC20(RebasingTokenElastic),10**22,0,address(0));

      for(uint i=0;i<8;i++) {
        RebasingTokenOHM.rebase();
      }

      uint return4 = pool.swap(IERC20(RebasingTokenOHM),IERC20(RebasingTokenElastic),10**22,0,address(0));

      RebasingTokenElastic.simulateRebaseDown(address(this),5*10**25);

      uint return5 = pool.swap(IERC20(RebasingTokenElastic),IERC20(RebasingTokenOHM),10**22,0,address(0));
      for(uint i=0;i<16;i++){
        RebasingTokenElastic.simulateRebaseDown(address(this),uint(RebasingTokenElastic.balanceOf(address(this)))/2);
      }
      uint return6 = pool.swap(IERC20(RebasingTokenElastic),IERC20(RebasingTokenOHM),10**10,0,address(0));

      console.logUint(return1); 
      console.logUint(return2); 
      console.logUint(return3); 
      console.logUint(return4); 
      console.logUint(return5); 
      console.logUint(return6); 

    //Add asserts here with more exact values. For now this helps vizualize the rebasing causing the return amount to drift down to 0
    //This is just an intuitive way to vizualize balances moving exponentially towards zero, fuzz testings should be added later that properly calculate a predicted output.
      uint withdrawAmount = pool.balanceOf(address(this));

      uint[] memory withdrawAmountsMin = new uint[](2);
      withdrawAmountsMin[0] = 8*10**4;
      withdrawAmountsMin[1] = 8*10**4;
      
    pool.withdraw(withdrawAmount,withdrawAmountsMin);
    console.logUint(pool.totalSupply()); //Base supply

    }
}


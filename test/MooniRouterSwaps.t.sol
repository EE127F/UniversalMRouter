// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DSTest} from "lib/forge-std/lib/ds-test/src/test.sol";
import {Vm} from "lib/forge-std/src/Vm.sol";
import {TokenCustomDecimalsMock} from "src/mocks/TokenCustomDecimalsMock.sol";
import "lib/forge-std/src/Test.sol";
import "src/MooniFactory.sol";
import "src/Mooniswap.sol";
import "src/MooniRouter.sol";
import {WETH9} from "src/mocks/WETH9.sol";
import {MyToken} from "src/mocks/ERC20Mock.sol";
import {MockSOHM} from "src/mocks/MockSOHM.sol";

contract TestMooniRouterSwap is DSTest {

    MooniFactory public factory;
    MooniRouter public router;

    MyToken public token0;
    MyToken public token1;
    MyToken public token2;
    WETH9 public weth;

    MockSOHM public rebaseToken0;
    MockSOHM public rebaseToken1;
    MockSOHM public rebaseToken2;

    receive() external payable {}
    fallback() external payable{}

    function setUp() public {
      factory = new MooniFactory();
      weth = new WETH9();
      router = new MooniRouter(address(factory),address(weth));
      token0 = new MyToken();
      token1 = new MyToken();
      token2 = new MyToken();
      token0.approve(address(router), 9999999999*10**18);
      token1.approve(address(router), 9999999999*10**18);
      token2.approve(address(router), 9999999999*10**18);
      weth.approve(address(router), 9999999999*10**18);

      rebaseToken0 = new MockSOHM(10**9,10**8); //10% rebase
      rebaseToken1 = new MockSOHM(10**9,5*10**8); //50% rebase
      rebaseToken2 = new MockSOHM(10**9,10**9); //100% rebase

      console.logUint(rebaseToken0.balanceOf(address(this)));
      rebaseToken0.approve(address(router),10**40);
      rebaseToken1.approve(address(router),10**40);
      rebaseToken2.approve(address(router),10**40);

      rebaseToken0.mint(address(this),75**10*18);
      rebaseToken1.mint(address(this),75**10*18);
      rebaseToken2.mint(address(this),75**10*18);

      console.logUint(rebaseToken0.balanceOf(address(this)));
    }

    function testSwapExactTokensForTokens() public {
        (uint256 liquidity01) = router.addLiquidity(
            address(token0),
            address(token1),
            75 ether,
            75 ether,
            75 ether,
            75 ether,
            address(this)
        );
        assertTrue(liquidity01>0);
        (uint256 liquidity12) = router.addLiquidity(
            address(token1),
            address(token2),
            75 ether,
            75 ether,
            75 ether,
            75 ether,
            address(this)
        );
        assertTrue(liquidity12>0);

        uint amountToken0Before = token0.balanceOf(address(this));
        uint amountToken2Before = token2.balanceOf(address(this));

        address[] memory path = new address[](3);
        path[0] = address(token0);
        path[1] = address(token1);
        path[2] = address(token2);
       
        router.swapExactTokensForTokens(10**24, 10**11, path, address(this), address(this));
  

         uint amountToken0After = token0.balanceOf(address(this));
         uint amountToken2After = token2.balanceOf(address(this));

         assertTrue(amountToken0After < amountToken0Before);
         assertTrue(amountToken2After > amountToken2Before);
    }
    function testSwapExactTokensForTokensRebase() public {

         console.logUint(rebaseToken0.balanceOf(address(this)));
        (uint256 liquidity01) = router.addLiquidity(
            address(rebaseToken0),
            address(token0),
            75 ether,
            75 ether,
            75 ether,
            75 ether,
            address(this)
        );
        assertTrue(liquidity01>0);

        (uint256 liquidity12) = router.addLiquidity(
            address(token0),
            address(token2),
            75 ether,
            75 ether,
            75 ether,
            75 ether,
            address(this)
        );
        assertTrue(liquidity12>0);

         uint amountToken0Before = token0.balanceOf(address(this));
         uint amountToken2Before = token2.balanceOf(address(this));
         uint amountrebaseToken0Before = rebaseToken0.balanceOf(address(this));

        address[] memory path = new address[](3);
        path[0] = address(rebaseToken0);
        path[1] = address(token0);
        path[2] = address(token2);
        

        router.swapExactTokensForTokens(25*10**18, 10**11, path, address(this), address(this));

         uint amountrebaseToken0After = rebaseToken0.balanceOf(address(this));
         uint amountToken2After = token2.balanceOf(address(this));

         console.logUint(amountrebaseToken0Before);
         console.logUint(amountToken2Before);
         console.logString("after: ");
         console.logUint(amountrebaseToken0After);
         console.logUint(amountToken2After);


         assertTrue(amountrebaseToken0After < amountrebaseToken0Before);
         assertTrue(amountToken2After > amountToken2Before);
    }
   function testSwapExactETHForTokens() public {
        (uint256 liquidity01) = router.addLiquidity(
            address(token0),
            address(token1),
            75 ether,
            75 ether,
            75 ether,
            75 ether,
            address(this)
        );
        
        (uint256 liquidity12) = router.addLiquidityETH{value: 75 ether}(
            address(token0),
            75 ether,
            75 ether,
            75 ether,
            address(this)
        );

        assertTrue(liquidity01>0);
        assertTrue(liquidity12>0);
        assertTrue(weth.totalSupply()>0);

        uint amountToken1Before = token1.balanceOf(address(this));

        address[] memory path = new address[](3);
        path[1] = address(token0);
        path[2] = address(token1);
        path[0] = address(weth);

       router.swapExactETHForTokens{value: 10 ether}(10**11, path, address(this), address(this));

        uint amountToken1After = token1.balanceOf(address(this));

       assertTrue(amountToken1After > amountToken1Before);
    }

       function testSwapExactTokensForETH() public {
        (uint256 liquidity01) = router.addLiquidity(
            address(token0),
            address(token1),
            75 ether,
            75 ether,
            75 ether,
            75 ether,
            address(this)
        );
        
        (uint256 liquidity12) = router.addLiquidityETH{value: 75 ether}(
            address(token0),
            75 ether,
            75 ether,
            75 ether,
            address(this)
        );

        assertTrue(liquidity01>0);
        assertTrue(liquidity12>0);
        assertTrue(weth.totalSupply()>0);

        uint amountToken1Before = token1.balanceOf(address(this));
        uint amountETHBefore = address(this).balance;

        address[] memory path = new address[](3);
        path[1] = address(token0);
        path[0] = address(token1);
        path[2] = address(weth);

       router.swapExactTokensForETH(10**19,10**11, path, address(this), address(this));

        uint amountToken1After = token1.balanceOf(address(this));
        uint amountETHAfter = address(this).balance;

       assertTrue(amountToken1After < amountToken1Before);
       assertTrue(amountETHBefore < amountETHAfter );
    }
    // function testSwapExactTokensForTokensRebase() public {
    //    
    //     rebaseToken0.mint(address(this),10**28);
    //     rebaseToken0.approve(address(router),10**33);
    //     token0.mint(address(this),10**29);
    //     token1.mint(address(this),10**29);
    //     token0.approve(address(router),10**29);
    //     token1.approve(address(router),10**29);

    //     uint amountrebaseToken0Before = rebaseToken0.balanceOf(address(this));
    //     uint amountToken0Before= token0.balanceOf(address(this));
    //     uint amountToken1Before= token1.balanceOf(address(this));
    //     // uint amountrebaseToken1Before = rebaseToken1.balanceOf(address(this));
    //     // uint amountrebaseToken2Before = rebaseToken2.balanceOf(address(this));

    //     // uint amountrebaseToken0Before = 75*10**18;
    //     // uint amountrebaseToken1Before = 75*10**18;
    //     // uint amountrebaseToken2Before = 75*10**18;


    //     (uint256 liquidity01) = router.addLiquidity(
    //         address(rebaseToken0),
    //         address(token0),
    //         10**18, 
    //         10**18, 
    //         10**18, 
    //         10**18, 
    //         address(this)
    //     );


    //     assertTrue(liquidity01>0);
    //     (uint256 liquidity12) = router.addLiquidity(
    //         address(token0),
    //         address(token1),
    //         10**18, 
    //         10**18, 
    //         10**18, 
    //         10**18, 
    //         address(this)
    //     );
    //     assertTrue(liquidity12>0);

    //     address[] memory path = new address[](3);
    //     path[0] = address(rebaseToken0);
    //     path[1] = address(token0);
    //     path[2] = address(token1);
    //    
    //     // rebaseToken0.mint(address(this),5*10**29);
    //     router.swapExactTokensForTokens(10**12, 10**3, path, address(this), address(this));

    //      uint amountrebaseToken0After = rebaseToken0.balanceOf(address(this));
    //      uint amountToken1After = token1.balanceOf(address(this));

    //      console.logUint(amountrebaseToken0Before);
    //      console.logUint(amountToken1Before);
    //      console.logString("after: ");
    //      console.logUint(amountrebaseToken0After);
    //      console.logUint(amountToken1After);

    //      // assertTrue(amountrebaseToken0After < amountrebaseToken0Before);
    //      // assertTrue(amountToken1After > amountToken1Before);

    // }
}

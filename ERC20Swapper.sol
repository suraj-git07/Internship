// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// Interface of ERC20 Token for using the transferFrom and balaceOf functionality
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
}

// interface of an uniswap contract
interface IUniswapV2Pair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

contract ERC20Swapper{

    using SafeMath for uint256;
    
    function swapEtherToToken(address _token, uint _minAmount, address _uniswapPairAddress) public payable returns (uint){
        
        require(msg.value > 0, "No ether sent");
        require(_token != address(0), "Invalid token address");
        require(_uniswapPairAddress != address(0), "Invalid pair address");

        // To intreact with the token creating its instance 
        IERC20 exchangeToken = IERC20(_token);
        IUniswapV2Pair uniswapPair = IUniswapV2Pair(_uniswapPairAddress);

        (uint112 reserve0, uint112 reserve1, ) = uniswapPair.getReserves();

        uint256 tokenReserve;
        uint256 ethReserve;
        if (_token <_uniswapPairAddress) {
            tokenReserve = uint256(reserve0);
            ethReserve = uint256(reserve1);
    }   else {
            tokenReserve = uint256(reserve1);
            ethReserve = uint256(reserve0);
    }

        uint256 price = ((ethReserve) * 10**18) / uint256(tokenReserve);

        uint256 initialTokenBalance = exchangeToken.balanceOf(address(this));

        require(msg.value >= price.mul(_minAmount), "The payable amount is more for buying required tokens");

        require(exchangeToken.transfer(msg.sender, msg.value.div(price)), "Token transfer failed");

        uint256 finalTokenBalance = exchangeToken.balanceOf(address(this));

        require(finalTokenBalance.sub(initialTokenBalance) >= _minAmount, "Received token amount is above minimum");

        return finalTokenBalance.sub(initialTokenBalance);
    

    }
}



// Contract address : 0xbBa3aa4aA95c95c2715C7592114d34dD58a57a3b

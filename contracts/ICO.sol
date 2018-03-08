pragma solidity ^0.4.19;

interface ICO
{
    /* ICO event: register this ICO in connection with Token watcher */
    event RegisterICO(address token);

    /* TokenBuy event: tell buyer how many tokens they got, and what the change (refund) was */
    event TokenBuy(address account, uint256 tokensBought, uint256 refund);

    /* TokenSell event: tell the seller how many tokens they returned and what their refund was */
    event TokenSell(address account, uint256 tokensReturned, uint256 refund);
    
    /* tokenPrice: price, in wei (10^-18 ether), of a Token */
    function tokenPrice() public constant returns (uint256 weiPerToken);
    
    /* buyTokens: buy floor(msg.value / tokenPrice()) Tokens */
    function buyTokens() public payable;
    
    /* sellTokens: get a refund for X amount of Tokens */
    function sellTokens(uint256 amount) public;
}

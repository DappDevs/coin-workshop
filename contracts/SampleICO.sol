pragma solidity ^0.4.19;

import "./ERC20Token.sol";
import "./ICO.sol";

contract SampleICO is ICO
{
    // ICO Information
    uint256 _tokenPrice = 1000; // wei per token

    /* Token Contract pointer */
    ERC20Token token;

    function SampleICO(address token_address)
        public
    {
        // Sets state variable 'token'
        // (which is an external contract interface)
        token = ERC20Token(token_address);

        // emit event so that ICO_Watcher script knows what to look for
        RegisterICO(token_address); // Register with Token ICO watcher
    }

    function tokenPrice()
        public
        constant
        returns (uint256)
    {
        // This had to happen because public doesn't jive with an interface
        return _tokenPrice;
    }

    /* buyTokens: buy floor(msg.value / tokenPrice()) Tokens */
    function buyTokens()
        public
        payable
    {
        // We can only sell our buyer whole tokens
        // (integer division floors automatically)
        uint256 tokensBought = (msg.value / tokenPrice());

        // Be nice, give them the tokens
        // (could throw if allowance/balance doesn't allow)
        token.transfer(msg.sender, tokensBought);

        // If you're extra nice, offer a refund of the remainder
        uint256 refund = msg.value - tokensBought * tokenPrice();

        // This is how you send ether
        // (could throw if 'msg.sender' denies this, e.g. anon function)
        msg.sender.transfer(refund);

        // Log an event, so our buyer knows what happened
        TokenBuy(msg.sender, tokensBought, refund);
    }

    /* sellTokens: get a refund for X amount of Tokens */
    function sellTokens(uint256 amount)
        public
    {
        // Get your tokens first (throws if amount doesn't send)
        assert(token.transferFrom(msg.sender, this, amount));

        // Then be nice and give them their money back
        uint256 refund = tokenPrice() * amount;
        msg.sender.transfer(refund);

        // Log the event so they know what happened
        TokenSell(msg.sender, amount, refund);
    }
}

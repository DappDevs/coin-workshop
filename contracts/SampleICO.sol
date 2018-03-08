pragma solidity ^0.4.19;

import "./ShillToken.sol";
import "./ICO.sol";

contract SampleICO is ICO
{
    // ICO Information
    uint256 _tokenPrice = 1000; // wei per token

    address public owner;

    // Manage how many buys/sells can happen here
    uint public OWNERSHIP_MAX;
    mapping (address => uint) numPurchased;

    /* Token Contract pointer */
    ShillToken token;

    function SampleICO(address token_address)
        public
    {
        // So we know who to transferFrom
        owner = msg.sender;

        // Sets state variable 'token'
        // (which is an external contract interface)
        token = ShillToken(token_address);

        // Deterimine the maximum ownership limit to maintain fairness
        OWNERSHIP_MAX = 10**uint256(token.decimals()); // (totalSupply / numParticipants)

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

    // These functions are needed because Solidity doesn't have min/max (Copied from OpenZeppelin)
    function max(uint a, uint b) internal pure returns (uint) { return a >= b ? a : b; }
    function min(uint a, uint b) internal pure returns (uint) { return a <  b ? a : b; }

    /* buyTokens: buy floor(msg.value / tokenPrice()) Tokens */
    function buyTokens()
        public
        payable
    {
        // We can only sell our buyer whole tokens
        // (integer division floors automatically)
        uint256 tokensBought = (msg.value / tokenPrice());

        // Ensure they aren't purchasing more than they can legally have
        require(numPurchased[msg.sender] < OWNERSHIP_MAX);

        // Limit them to that quantity (no underflow due to require ^)
        tokensBought = min(OWNERSHIP_MAX-numPurchased[msg.sender], tokensBought);

        // Keep track of how many they've bought
        numPurchased[msg.sender] += tokensBought;

        // Be nice, give them the tokens
        // (could throw if allowance/balance doesn't allow)
        token.transferFrom(owner, msg.sender, tokensBought);

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
        // Overflow protection
        require(numPurchased[msg.sender] - amount >= 0);
        // Keep track of how many they've sold back
        numPurchased[msg.sender] -= amount;

        // Get your tokens first (throws if amount doesn't send)
        assert(token.transferFrom(msg.sender, owner, amount));

        // Then be nice and give them their money back
        uint256 refund = tokenPrice() * amount;
        msg.sender.transfer(refund);

        // Log the event so they know what happened
        TokenSell(msg.sender, amount, refund);
    }
}

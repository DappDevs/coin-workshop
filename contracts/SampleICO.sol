pragma solidity ^0.4.19;

// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/issues/20
interface ERC20Token
{
    // Get the total token supply
    function totalSupply() public constant returns (uint256 _totalSupply);

    // Get the account balance of another account with address _owner
    function balanceOf(address _owner) public constant returns (uint256 balance);

    // Send _value amount of tokens to address _to
    function transfer(address _to, uint256 _value) public returns (bool success);

    // Send _value amount of tokens from address _from to address _to
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    // this function is required for some DEX functionality
    function approve(address _spender, uint256 _value) public returns (bool success);

    // Returns the amount which _spender is still allowed to withdraw from _owner
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

    // Triggered when tokens are transferred.
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    // Triggered whenever approve(address _spender, uint256 _value) is called.
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

interface ICO
{
    /* ICO event: register this ICO in connection with Token watcher */
    event RegisterICO(address token);

    /* TokenBuy event: tell buyer how many tokens they got, and what the change (refund) was */
    event TokenBuy(address account, uint256 tokensBought, uint256 refund);

    /* TokenSell event: tell the seller how many tokens they returned and what their refund was */
    event TokenSell(address account, uint256 tokensReturned, uint256 refund);

    /* Who owns this contract */
    function owner() public constant returns (address);

    /* tokenPrice: price, in wei (10^-18 ether), of a Token */
    function tokenPrice() public constant returns (uint256 weiPerToken);

    /* buyTokens: buy floor(msg.value / tokenPrice()) Tokens */
    function buyTokens() public payable;

    /* sellTokens: get a refund for X amount of Tokens */
    function sellTokens(uint256 amount) public;
}

contract SampleICO is ICO
{
    // ICO Information
    uint256 _tokenPrice = 1000; // wei per token

    /* Token Contract pointer */
    ERC20Token token;

    /* ICO Owner */
    address _owner;

    function SampleICO(address token_address)
        public
    {
        // Whoever created this has extra superpowers!
        _owner = msg.sender;

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

    // Get owner
    function owner() public constant returns (address) { return _owner; }

    // Enforce access control to owner only
    modifier onlyOwner()
    {
        require(msg.sender == owner());
        _; // This means "...then do everything else"
    }

    // Owner can get all of the tokens stored here at any time
    function getTokens()
        public
        onlyOwner
    {
        assert(token.transfer(_owner, token.balanceOf(this)));
    }

    // Owner can put more money in
    function () public payable onlyOwner { }
}

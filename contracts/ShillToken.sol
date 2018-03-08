pragma solidity ^0.4.19;

import "./ERC20Token.sol";

contract ShillToken is ERC20Token
{
    string public name = "DappDevs Shill-a-Coin Workshop token";
    string public symbol = "SHILL";
    uint8 public decimals = 2;

    mapping(address => uint256) balances;
    uint256 totalSupply_;

    address public minter;

    function ShillToken() public
    {
        totalSupply_ = 0;

        minter = msg.sender;
    }
    
	/*
	 * @dev total number of tokens in existence
	 */
	function totalSupply() public view returns (uint256) {
		return totalSupply_;
	}

	/*
	 * @dev transfer token for a specified address
	 * @param _to The address to transfer to.
	 * @param _value The amount to be transferred.
	 */
	function transfer(address _to, uint256 _value) public returns (bool) {
		require(_to != address(0)); // Protect against zero-address send
		require(_value <= balances[msg.sender]); // Protect against underflow/insufficent balance

		// SafeMath.sub will throw if there is not enough balance.
		balances[msg.sender] -= _value; // Won't underflow because of above check
		balances[_to] += _value; // Won't overflow because totalSupply_ is constant
		Transfer(msg.sender, _to, _value);
		return true;
	}

	/*
	 * @dev Gets the balance of the specified address.
	 * @param _owner The address to query the the balance of.
	 * @return An uint256 representing the amount owned by the passed address.
	 */
	function balanceOf(address _owner) public view returns (uint256 balance) {
		return balances[_owner];
	}

	mapping (address => mapping (address => uint256)) internal allowed;


	/*
	 * @dev Transfer tokens from one address to another
	 * @param _from address The address which you want to send tokens from
	 * @param _to address The address which you want to transfer to
	 * @param _value uint256 the amount of tokens to be transferred
	 */
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
		require(_to != address(0)); // Protect against zero-address send
		require(_value <= balances[_from]); // Protect against underflow/insufficent balance
		require(_value <= allowed[_from][msg.sender]); // Protect against underflow/insufficent allowance

		balances[_from] -= _value; // Won't underflow because of above check
		balances[_to] += _value; // Won't overflow because totalSupply_ is constant
		allowed[_from][msg.sender] -= _value; // Won't underflow because of above check
		Transfer(_from, _to, _value);
		return true;
	}

	/**
	 * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
	 *
	 * Beware that changing an allowance with this method brings the risk that someone may use both the old
	 * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
	 * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
	 * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
	 * @param _spender The address which will spend the funds.
	 * @param _value The amount of tokens to be spent.
	 */
	function approve(address _spender, uint256 _value) public returns (bool) {
        // Any number for _value >= totalSupply_ means 'authorize all'
		allowed[msg.sender][_spender] = _value; // No underflow/overflow can happen
		Approval(msg.sender, _spender, _value);
		return true;
	}

	/**
	 * @dev Function to check the amount of tokens that an owner allowed to a spender.
	 * @param _owner address The address which owns the funds.
	 * @param _spender address The address which will spend the funds.
	 * @return A uint256 specifying the amount of tokens still available for the spender.
	 */
	function allowance(address _owner, address _spender) public view returns (uint256) {
		return allowed[_owner][_spender];
	}

	/**
	 * @dev Function that allows the minter to mint more tokens
	 * @param _to address The address which receives the newly minted funds
	 * @param _amount uint256 The amount of tokens to mint
	 */
    function mint(address _to, uint256 _amount) public {
        require(minter != 0x0);
        require(totalSupply_ + _amount > totalSupply_);
        totalSupply_ += _amount; // Won't overflow because we checked above
		balances[_to] += _amount; // Won't overflow because balances <= totalSupply_
        Transfer(0x0, _to, _amount);
    }
}

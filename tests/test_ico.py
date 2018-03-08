import pytest

PARTICIPANTS=10
@pytest.fixture
def Token(tester):
    return tester.contracts('contracts/ShillToken.sol').deploy(PARTICIPANTS)

def test_token(tester, Token):
    # Deployer address has all the tokens, and there is 1 token for each participant
    assert Token.balanceOf(tester.accounts[0]) == \
            Token.totalSupply() == \
            PARTICIPANTS*10**Token.decimals()

@pytest.fixture
def ICO(tester, Token):
    return tester.contracts('contracts/SampleICO.sol').deploy(Token.address)

def test_ico(tester, Token, ICO):
    # Test registration
    assert ICO.all_logs[-1]['token'] == Token.address

    # Deployer has all the tokens
    assert Token.balanceOf(tester.accounts[0]) == Token.totalSupply()
    
    # Allow the ICO to move tokens on your behalf
    Token.approve(ICO.address, Token.totalSupply())
    assert Token.allowance(tester.accounts[0], ICO.address) == Token.totalSupply()
    
    # Buy alloted tokens
    amount = Token.totalSupply() // PARTICIPANTS
    price = ICO.tokenPrice()
    starting_balance = tester.accounts[1].balance
    # Even if we send way more than what we can purchase, we get that much
    ICO.buyTokens(transact={'from': tester.accounts[1], 'value': 10 * amount * price})
    assert Token.balanceOf(tester.accounts[1]) == amount
    assert tester.accounts[1].balance <= starting_balance - amount * price
    
    # Sell all the tokens and get your Ether back
    Token.approve(ICO.address, amount, transact={'from': tester.accounts[1]})
    ICO.sellTokens(amount, transact={'from': tester.accounts[1]})
    assert Token.balanceOf(tester.accounts[1]) == 0
    assert tester.accounts[1].balance > starting_balance - amount * price

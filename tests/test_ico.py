import pytest

PARTICIPANTS=10
@pytest.fixture
def token(Contract):
    return Contract('contracts/ShillCoin.sol:ShillCoin').deploy(PARTICIPANTS)

def test_token(a, token):
    # Deployer address has all the tokens, and there is 1 token for each participant
    assert token.balanceOf(a[0]) == token.totalSupply() == PARTICIPANTS*token.decimals()

@pytest.fixture
def ico(Contract, token):
    return Contract('contracts/SampleICO.sol:SampleICO').deploy(token.address)

def test_ico(a, logs, token, ico):
    # Test registration
    assert logs('RegisterICO')[-1]['token'] == token.address
    # Deployer has all the tokens
    amount = token.totalSupply()
    assert token.balanceOf(a[0]) == amount
    # Give all the tokens to the ICO
    token.transfer(ico.address, amount)
    assert token.balanceOf(a[0]) == 0
    # Buy all the tokens
    price = ico.tokenPrice()
    starting_balance = a[0].balance
    ico.buyTokens(transact={'value': amount * price})
    assert token.balanceOf(a[0]) == amount
    assert a[0].balance <= starting_balance - amount * price
    # Sell all the tokens and get your Ether back
    ico.sellTokens(amount)
    assert token.balanceOf(a[0]) == 0
    assert a[0].balance > starting_balance - amount * price

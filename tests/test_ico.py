import pytest


@pytest.fixture
def Token(tester):
    return tester.contracts('contracts/ShillToken.sol').\
            deploy(transact={'from': tester.accounts[1]})


def test_token(tester, Token):
    # No one has any tokens
    assert Token.totalSupply() == 0
    # So mint some!
    amount = 10**Token.decimals()
    Token.mint(tester.accounts[1], amount)
    assert Token.balanceOf(tester.accounts[1]) == amount


PARTICIPANTS=10
@pytest.fixture
def ICO(tester, Token):
    return tester.contracts('contracts/SampleICO.sol').deploy(Token.address)


def test_ico(tester, Token, ICO):
    # Test registration
    assert ICO.all_logs[-1]['token'] == Token.address

    # ICO contract can only work if it has something to sell
    Token.mint(ICO.address, PARTICIPANTS*10**Token.decimals())
    
    # Anyone can buy tokens
    amount = Token.totalSupply()
    price = ICO.tokenPrice()
    starting_balance = tester.accounts[1].balance
    ICO.buyTokens(transact={'from': tester.accounts[1], 'value': amount * price})
    assert Token.balanceOf(tester.accounts[1]) == amount
    assert tester.accounts[1].balance <= starting_balance - amount * price
    
    # Sell all the tokens and get your Ether back
    Token.approve(ICO.address, amount, transact={'from': tester.accounts[1]})
    ICO.sellTokens(amount, transact={'from': tester.accounts[1]})
    assert Token.balanceOf(tester.accounts[1]) == 0
    assert tester.accounts[1].balance > starting_balance - amount * price

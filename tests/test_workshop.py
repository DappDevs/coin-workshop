from random import randint, sample

import pytest
from test_ico import Token
from eth_tester.exceptions import TransactionFailed


@pytest.fixture
def ICO_Factory(tester, Token):
    return lambda a: tester.\
            contracts('contracts/SampleICO.sol').\
            deploy(Token.address, transact={'from': a})


def test_workshop(tester, Token, ICO_Factory):
    teacher = tester.accounts[0]
    students = tester.accounts[1:]

    # Give students tokens
    amt = 10**Token.decimals()
    [Token.mint(s, amt) for s in students]
    assert all([Token.balanceOf(s) == amt for s in students])

    # Students create ICOs
    ICOs = [ICO_Factory(s) for s in students]

    # Helpful tools
    tkn_bal = lambda s: Token.balanceOf(s)
    rnd_tkn = lambda s: randint(1, tkn_bal(s)) if tkn_bal(s) > 1 else 1
    tkn_prc = lambda ICO: ICO.tokenPrice()
    def rnd_eth(ICO, s):
        if tkn_bal(ICO.address) > 0:
            return min(randint(1, tkn_bal(ICO.address))*tkn_prc(ICO), s.balance)
        return 0
    buy = lambda ICO, s, v: ICO.buyTokens(transact={'from' : s, 'value': v})
    sell = lambda ICO, s: ICO.sellTokens(rnd_tkn(s), transact={'from' : s})
    
    # Students sends some of their coins to their own ICOs
    [Token.transfer(ICO.address, tkn_bal(s)//3, transact={'from': s}) \
            for ICO, s in zip(ICOs, students)]
    # As well as enough money to buy more
    [s.send(ICO.address, tkn_prc(ICO)*tkn_bal(ICO.address)) \
            for ICO, s in zip(ICOs, students)]

    # Students start trying to trade with other ICOs
    for _ in range(30): # 30 minute excercise
        buyer, seller = sample(students, 2)
        bICO, sICO = sample(ICOs, 2)
        try:
            sell(bICO, seller)
            buy(sICO, buyer, rnd_eth(sICO, s))
        except TransactionFailed as e:
            pass

    # Students buyback all their tokens
    [buy(ICO, s, tkn_bal(ICO.address)*tkn_prc(ICO)) for ICO, s in zip(ICOs, students)]
    # Check for the winner
    winner = teacher
    for s in students:
        print("Student", s, "has", tkn_bal(s), "Tokens")
        if tkn_bal(winner) < tkn_bal(s):
            winner = s

    assert winner is not teacher

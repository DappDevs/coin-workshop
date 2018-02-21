import pytest

from web3 import Web3
from web3.providers.eth_tester import EthereumTesterProvider
from web3.contract import ImplicitContract
import json
import os

w3 = Web3(EthereumTesterProvider())

@pytest.fixture
def a():
    return w3.personal.listAccounts

@pytest.fixture
def contracts():
    contracts_file = os.path.join(os.path.dirname(__file__), '../contracts.json')
    with open(contracts_file, 'r') as f:
        contracts = json.loads(f.read())
    return contracts['contracts']

@pytest.fixture
def Contract(contracts):

    class Contract:
        def __init__(self, contract_name):
            interface = contracts[contract_name]
            self.abi = interface['abi']
            self.bin = interface['bin']
            self.runtime = interface['bin-runtime']
            self.factory = w3.eth.contract(abi=self.abi, bytecode=self.bin)

        def deploy(self, *args, **kwargs):
            tx_hash = self.factory.deploy(args=args, **kwargs)
            tx_receipt = w3.eth.getTransactionReceipt(tx_hash)
            address = tx_receipt['contractAddress']
            return w3.eth.contract(self.abi, address,
                    ContractFactoryClass=ImplicitContract)


    return Contract

@pytest.fixture
def logs():
    def logs(*topics):
        for event in w3.eth.filter(topics):
            if topics and event in topics:
                yield event
            else:
                yield event

import React, { Component } from 'react';
import getWeb3 from './utils/getWeb3'

import assetsFile from './contracts.json'
import logo from './logo.svg';
import './App.css';

class App extends Component {
  constructor(props) {
    super(props)

    this.state = {
      user: null,
      web3: null,
      contracts: null,
      tokenInstance: null,
      icoFactory: null,
      icoInstances: [],
    }
  }

  componentWillMount() {
    // Get network provider and web3 instance.
    // See utils/getWeb3 for more info.
    getWeb3
    .then(results => {
      this.setState({
        web3: results.web3,
        user: results.web3.eth.coinbase
      })
      .then(
        this.loadContractAssets()
      )
    })
    .catch(() => {
      console.log('Error finding web3.')
    })
  }

  loadContractAssets() {
    console.log(assetsFile.contracts)
  }

  render() {
    return (
      <div className="App">
        <header className="App-header">
          <img src={logo} className="App-logo" alt="logo" />
          <h1 className="App-title">Coin Workshop</h1>
        </header>
        <p className="App-intro">
          Welcome <code>{this.state.user}</code>!
        </p>
      </div>
    );
  }
}

export default App;

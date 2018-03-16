# Smart contracts

Smart contracts are...
* compiled bytecode for the EVM
* able to accept calls
* contains access rules and controls logic

There are a few smart contract langauges,
but Solidity is the most widely used

???

+++

First, what is a Smart Contract?

Well, a smart contract is basically a small computer program.
It is compiled into Bytecode and interpretted by the Ethereum VM
for use by the network of Ethereum users it is developed to target.

A smart contract is able to accept calls from Ethereum's users,
who provide external data in the form of arguments in order
to perform the logic specified within the smart contract
and modify the underlying state of the smart contract moving forward.

Smart contracts typically contain access restrictions in order to
ensure only the right parties, under the right conditions, are
able to modify this state. Otherwise, anyone could say whatever they
want and the smart contract wouldn't be useful.

There are a few smart contract languages in existance that target the EVM,
but Solidity is by far and away the most widely used

---

# Solidity

* JavaScript-like syntax, but...
    * Statically-typed
    * Object-oriented
    * Compiled
* Powerful, allows:
    * assembly
    * variable gas usage
    * inheritance
* Power ==> Vulnerability
    * gas attacks
    * re-entrancy
    * opaque logic

???

+++

A little background on Solidity. It was developed to be the language of
choice for web application developers getting into decentralized application
development for the first time. It's syntax borrows heavily from JavaScript,
with major modifications to support an Object-oriented design approach.
It is statically typed, due to the needs of the EVM, as well as compiled.

Solidity programs are typically very high level in design,
but they compile quickly to low-level EVM bytecode, which is an interesting
matchup of concerns. It is also very powerful, giving the user control
over many low-level abilities such as assembly and gas usage.
This means that while it may be easy to design a Solidity smart contract for
a specific task, it is decidedly difficult to write a Smart Contract that
securely performs it's given task without having too many vulnerabilities
that can be exploited by hackers.

The vulnerability to attack is of prime concern to a dapp developer writing
smart contracts, because the liklihood of attack is extremely high.
A hacker's barrier to entry is as low as possible (anyone can join Ethereum),
and Smart Contract's typically hold valuable assets for long periods of time.
To cap it all off, you can't fix bugs! That's right, once a Smart Contract is
deployed to the Ethereum network, it is impossible to change by the design of
Ethereum. This means you have exactly one chance to get it right, sort of like
when SpaceX is launching a satellite into orbit.

---

# Contracts in Solidity

Basic contract:
```solidity
pragma solidity ^0.4.19; // won't compile without this
contract A {
  uint stateVariable; // Stored in contract's state on-chain

  function someMethod(uint argA, bool argB) public {
    require(argA > 0); // Check incoming arguments
    if (argB) { // Logic statements
      stateVariable = argA; // Assignment of state variable
    } else {
      stateVariable -= 1; // Decrement state variable
    }
    assert(stateVariable > 0); // Post-execution checks
    // NOTE: If assert fails, transaction reverts stateVariable
  }
}
```

???

+++

Anyways, let's look at a Smart Contract and how we write one.
Here's a basic example. We have a smart contract, called `A`,
that contains one State Variable (here a `uint`, which is shorthand
for an unsigned, 256-bit integer, or `uint256`) and one method,
`someMethod` that takes 2 arguments, and modifies the state variable.

Looking into the method, we can break it down into 3 stages:
1. Pre-condition checks of the input arguments
2. State variable logic changes and external calls
3. Post-execution logical checks of state variables

Now, this isn't a required structure to your methods,
but it certainly helps to adopt this structure to make it easier
for *other* developers to review your code.

This is Lesson number 1: other people need to read your code, make it easy. 

Any error that occurs during execution of these stages fails the
transaction and reverts the state. That means no changes happen,
no assets are swapped, etc. This is actually preferred execution model,
it makes it easy to tell if a pending transaction will be successful or not.

P.S. you need that weird `pragma` thing at the top for Solidity to know what
compiler you're using. Here it says you need version 0.4.19 or greater

---

# Inheritance in Solidity

B inherits from A:
```solidity
pragma solidity ^0.4.19;

import "A.sol"; // Imports contract A

contract B is A {
  // B now has `stateVariable`
  function anotherMethod(uint arg) public {
    super.someMethod(arg, true);
  }
}
```

???

+++

Solidity allows Inheritance as an abstraction mechanism.

For those that don't know, inheritance is a way to define some functionality
in one class (or contract here), and have another inherit all the parameters
and methods defined in that class in order to reduce the amount of code
in different classes.

Parameters in parent classes come along for free. This means you need to keep
track of all the paraemters in your parent classes and make sure you don't
overwrite that functionality in your subclass.

You can override the parent class's methods through the use of the `super`
keyword. You should use this mechanism for modifying your parent class's
parameters, as it is more obvious that trying to modify the underlying
classes parameters.

The biggest use of this paradigm is to import classes from outside your
current file, in order to reduce the amount of code present in any one file
in your codebase.

---

# Multiple inheritance

Solidity uses 
```
pragma solidity ^0.4.19;

/* We can load specific contracts from files */
import A from "A.sol";
import B from "B.sol"; // Doesn't load contract A

contract C is A
contract D is B
// resolves according to C3 superclass linearization rules
contract E is A, B, C, D
// `contract E is D, C, B, A` would fail to compile

// p.s. you can do multiple contracts in one .sol file
```

???

+++

You can do multiple inheritance with Solidity. This means you can define
multiple abstractions into different contract classes (in different files even)
and use those to build increasingly more complex programs.

Multiple inheritance is resolved through the common C3 linearization rules
that Python and other languages use to resolve class inheritance.
This means that your contracts may not compile unless the inheritance is
specified in a certain order, and it may occasionally not be possible for
you to define a correct order for it to work.

Another note, you *can* define multiple contracts in a single file.
Try not to go overboard with too many contracts in one file
(unless you're posting in Etherscan) as this can create visual clutter in
your codebase.

To import from a single contract from one of your files, you can use
the `import from` mechanism to only grab certain files and reduce the pollution
you may have from different imports.

---

# Constructors

```solidity
contract hasConstructor {
  address owner;

  // Constructors must have the same name as the contract
  function hasConstructor() {
    // You can set initial state variables in the constructor
    // This gets run on contract deployment, and does not stay
    // in the deployed contract as an executable method
    owner = msg.sender; // The account that deploys this contract
  }
}
```

Commonly used Ethereum environment variables:
* `msg.sender` - caller of this method call
* `msg.value` - value of ether forwarded with this call
* `block.timestamp` - current timestamp (`now` is an alias)
    * Can be manipulated by miners to a certain degree
* `block.number` - current block number txn is in
* Many others, not listed due to subtle considerations

???

+++

Smart Contracts, by default, initialize all their state variables to whatever
their zero value is. You may not want this to be the case, so the most common
way to initialize these values is through the use of a constructor.

Constructors must have the same name as their contract.
It is called during the deployment event, and can do anything a normal method can do.
Commons used of the constructor is to set up access control restrictions,
such as ownership, or timing restructions, such as initializing a block timestamp or number.
It can also be used to set external contract variables such as token references.

If you notice in this example, we are using the `msg.sender` environment variable.
This is the sender of the message in the calling context of this smart contract.
This varibale is *not* the same as the originator of the transaction, only the
last account in the call chain that made the call here. Typically however, this is
what you want to track. There are other environment variables you may wish to use.

---

# Ethereum Addresses

Addresses have special methods and parameters

* `<address>.balance (uint256)`
    * balance of the Address in Wei
* `<address>.transfer(uint256 amount)`
    * send given amount of Wei to Address, throws on failure
* Others... again not listed due to subtle considerations

```solidity
contract Charity {
  // Adding `public` to a state variable adds a "getter"
  address public beneficiary;
  uint public budget;

  function Charity(uint _budget) public payable {
    // `payable` means `require(msg.value > 0);`
    // This means you have to send value to create this smart cotnract
    beneficiary = msg.sender;
    budget = _budget;
  }

  function getFunds() public {
    // Common access restriction pattern
    require(msg.sender == beneficiary);
    // Send all funds in this contract to beneficiary
    beneficary.transfer(this.balance); // reverts if `transfer` fails
  }

  // The fallback function, called when eth is sent to contract
  function () payable {
    // at this point, `this.balance` increases by `msg.value`
    require(this.balance < budget); // `this` means this contract's address
  }
}
```

???

+++

Addresses (aka accounts) in Ethereum have some special properties available for use.
Addresses can stored an ether balance, can send and receive ether, as well as
send and receive calls (this is advanced).

The `transfer` method of an address specifies a recipient and an amount of wei to send.
If the contract doing the sending doesn't have enough wei available to complete the txn,
it will fail and revert from that point.

You may choose to let your smart contract accept ether `send`/`transfer` calls by specifying
a "fallback" function. This is a special function in solidity that executes if no other method
signature matches in the call. Typically the `payable` modifier is added ensuring that the
call is sending value, since the fallback function is only alotted a small amount of gas to
execute the function call, and that's usually just enough for a few simple checks for eth transfer.

If the fallback function is omitted from your contract (which is enouraged due to it's
subtle considerations), then any unmatched method call will fail.

One last thing to note, `this` is a special variable that refers to the contract itself.
This usually is used in the context of figuring out the contract's balance of ether.

---

# Types

Types in solidity:
* Addresses
    * Just talked about it
* Integers (signed/unsigned, numbers of bits)
    * uint256
    * int128
    * etc...
* Arrays
    * has a `<array>.length` member
* Mappings
    * Hashtable / Python `dict`
* Strings
    * Basically an array of bytes

---

# Modifiers

```solidity
contract Owned {
  address public owner;
  
  modifier onlyOwner() {
    require(msg.sender == owner);
    _; // This means "now do everything else"
  }
  
  function changeOwner(address _owner) onlyOwner() public {
    // `require(msg.sender == owner);` inserted here
    owner = _owner;
  }
}
```

Built-in modifiers
* `constant`/`view` - no state changes
* `pure` - no state accesses either
* `payable` - must have `msg.value` > 0
* `public` - any account can call method
* `private` - only contract can call method
* `external` - contract cannot call method
* `internal` - method is copied directly into contract

---

# Returning and Events

Solidity methods can return values
```solidity
function myMethod() view public returns (uint) {
  return block.number;
}
```
*Note*: transactions don't return values in Web3, they return txn hash.
*Best Practice*: Only non-state changing functions should return

Events are special logs stored in the Ethereum blockchain

* Easy lookup in light clients
* Great for async state feedback
* Stored in ABI for Web3 use

---

# Interfaces

```solidity
interface myInterface {
  function myMethod() public returns (uint);
}
```

Useful to help separate concerns between different files,
as well as for interoperability and external calls.

---

# External calls

```solidity
contract A {
  myInterface public externAddr;

  function A(address _externAddr) public {
    // The given address should have the specified interface for calling
    externAddr = myInterface(_externAddr); // Cast to the given interface
  }

  function callExtern() public returns (uint) {
    return externAddr.myMethod(); // We can make an external call this way
  }
}

// We can also use this to specify what methods our contracts must implement
contract B is myInterface {
  function myMethod() public returns (uint) {
    return msg.value;
  }
}
```

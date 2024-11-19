## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

To start you need to use "forge build" command.
Create .env file for your self and add "ETHERSCAN_API_KEY, SEPHOLIA_RPC_URL, RPC_URL, PRIVATE_KEY, LOCAL_PRIVATE_KEY".
To use LOCAL_PRIVATE_KEY you need to use "anvil" command and copy one of the private keys.
If you don't want to use anvil as local wallet you should change LOCAL_PRIVATE_KEY from "Makefile" to PRIVATE_KEY.
To deploy the contract use "make deploy-sepholia" command.

## Errors

If you encounter "Error: Not all (0 / 1) contracts were verified!" error, just delete out file and compile the project again.
If you encounter ""

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

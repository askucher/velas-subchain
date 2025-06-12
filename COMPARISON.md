Here's a comparison list of **private Ethereum-compatible network solutions**, based on the three links you provided:

---

### 1. **Geth Private Network**

📄 Docs: [Geth Private Network Guide](https://geth.ethereum.org/docs/fundamentals/private-network)

**Overview:**
Geth allows setting up a private Ethereum network using a custom `genesis.json`.

**Key Features:**

* Standard PoW or Clique PoA (Proof-of-Authority)
* Easy to spin up multiple nodes for testing
* Fully Ethereum-compatible (EVM, RPC)
* Good for internal development and testing

**Limitations:**

* Clique doesn't support BFT, only crash fault tolerance
* Requires manual configuration for multiple nodes

---

### 2. **GoQuorum IBFT Network**

📄 Docs: [GoQuorum IBFT Tutorial](https://docs.goquorum.consensys.io/tutorials/private-network/create-ibft-network)

**Overview:**
GoQuorum is a permissioned fork of Geth designed for enterprise use, using IBFT2 consensus.

**Key Features:**

* IBFT2 (Byzantine Fault Tolerant)
* Privacy features via Tessera
* Permissioned networks
* Ethereum-compatible (solidity, JSON-RPC)
* Used by enterprises for private blockchain applications

**Limitations:**

* More complex setup compared to plain Geth
* Focused on permissioned enterprise use cases

---

### 3. ** Velas Subchain (askucher/velas-subchain)**

📦 Repo: [Velas Subchain GitHub](https://github.com/askucher/velas-subchain)

**Overview:**
A light-weight subchain solution using Velas and ERC20 token-based genesis. Allows rapid smart contract consensus network creation without full Go or Rust stack.

**Key Features:**

* Smart contract–driven consensus
* ERC20 token in genesis with mint/burn, can be extended with any solidity complexity
* Genesis allocation like Geth (`alloc`)
* Gateway stateless node
* Auto pruning
* Lightweight compared to traditional L1s

**Limitations:**
* Dependant on state data availablity in velas network
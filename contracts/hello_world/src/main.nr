// A simple "Hello World" Aztec smart contract.
//
// Demonstrates core Aztec concepts:
//   - Public state (visible to everyone, like Ethereum)
//   - Reading and writing on-chain storage
//   - View functions (read-only, no transaction needed)

use aztec::macros::aztec;

#[aztec]
pub contract HelloWorld {
    use aztec::{
        macros::{functions::external, storage::storage},
        protocol::address::AztecAddress,
        state_vars::{Map, PublicMutable},
    };

    // Storage: a simple public map from address to a greeting count.
    // Public state is visible to everyone, like a regular Ethereum mapping.
    #[storage]
    struct Storage<Context> {
        greeting_counts: Map<AztecAddress, PublicMutable<Field, Context>, Context>,
    }

    // A public function: executed by the network, state changes are visible.
    // Anyone can call this to say hello and increment their counter.
    #[external("public")]
    fn say_hello() {
        let sender = self.msg_sender();
        let current = self.storage.greeting_counts.at(sender).read();
        self.storage.greeting_counts.at(sender).write(current + 1);
    }

    // A view function: reads state without a transaction (free, no gas).
    // Returns how many times an address has said hello.
    #[external("utility")]
    unconstrained fn get_greeting_count(who: AztecAddress) -> pub Field {
        self.storage.greeting_counts.at(who).read()
    }
}

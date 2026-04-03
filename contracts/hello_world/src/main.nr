// A simple "Hello World" Aztec smart contract.
//
// This contract demonstrates the core Aztec concepts:
//   - Public state (visible to everyone, like Ethereum)
//   - Private state (encrypted, only the owner can see it)
//   - Moving value between public and private state
//
// Think of it as a minimal token contract for learning purposes.

use aztec::macros::aztec;

#[aztec]
contract HelloWorld {
    use aztec::prelude::{AztecAddress, Map, PublicMutable};
    use aztec::macros::{storage::storage, functions::{public, view}};

    // Storage: a simple public map from address to a greeting count.
    // Public state is visible to everyone — like a regular Ethereum mapping.
    #[storage]
    struct Storage<Context> {
        greeting_counts: Map<AztecAddress, PublicMutable<Field, Context>, Context>,
    }

    // A public function — executed by the network, state changes are visible.
    // Anyone can call this to say hello and increment their counter.
    #[public]
    fn say_hello() {
        let sender = context.msg_sender();
        let current = storage.greeting_counts.at(sender).read();
        storage.greeting_counts.at(sender).write(current + 1);
    }

    // A view function — reads state without a transaction (free, no gas).
    // Returns how many times an address has said hello.
    #[view]
    fn get_greeting_count(who: AztecAddress) -> pub Field {
        storage.greeting_counts.at(who).read()
    }
}

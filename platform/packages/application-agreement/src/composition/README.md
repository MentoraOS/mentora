# composition/

**Deliberately empty until Lot 1C-7.** The Composition Root is "the only place
in the system where concrete types exist" (F4.4 I-2), it "builds the machinery,
never the truths" (I-3), and it is **unique per executable** (F4.4.99) — so it
is assembled last, when every piece it wires (pipeline stages, handlers,
dispatch tables, policies with their product parameters) exists.

Nothing above the Root searches for a dependency; everything receives it
("la règle du regard", F4.4 §2).

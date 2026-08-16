# @mentora/runtime-serialization

Deterministic runtime serialization: `canonicalJson` (recursive key sort —
"Canonicalisation lorsque pertinente", F1), plain/deterministic serializers,
UTF-8 binary, `VersionedPayload` (carries the declared generation; the OWNER
judges it — V-1/V-2), FNV-1a checksums (a fingerprint demonstrates, never
decides — T-24 spirit), `CompressionStrategy` (abstract; codecs are adapter
resources). The published-language serializers of the contracts packages
remain the owners of their contracts (V-1); dialects die at the adapter
(S-2). Reserved words honored: nothing here is named Snapshot, Journal or
Export (F5.2 §12).

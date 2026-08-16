# @mentora/runtime-security

The security surfaces of the runtime. `SecretReference` IS the F4.4 §9
discipline, verbatim: "Un secret n'a qu'un lieu, et tous les autres lieux
n'en connaissent que le nom … Le domaine ne les voit JAMAIS (il n'a même pas
de type pour les contenir). Jamais dans un log, jamais dans un Domain Event,
jamais mis en cache" (I-8). `SecretResolver` (vestibule surface; in-memory
double; real resolvers are vault adapters), `CryptoRandomGenerator` (CSPRNG;
Nonce/Salt are crypto mechanisms, never truth vocabulary — F5.4 §10), and
crypto SURFACES as interfaces only (Encryptor/Decryptor/Hasher/
PasswordHasher/KeyProvider): primitives come from vetted providers behind
adapters — never hand-rolled (T-21/T-24). PasswordHasher serves the
vestibule only: Credential/Session are frozen I&A property (F5.4 §2).

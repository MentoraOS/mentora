# @mentora/runtime-bootstrap

The nine-state returnless lifecycle (F5.1 §4: Construction → Configuration →
Validation → Warmup → Ready → Active → Draining → Shutdown → Destroyed;
"aucun retour" — R-4), the I-11 resource hooks (construire → démarrer →
drainer → libérer; birth in dependency order, DEATH IN REVERSE), and the
fail-closed boot: "le Boot démontre et ne sert jamais ; une seule preuve
manquante et il meurt" (R-5) — all violations reported, then the instance
dies once; a died instance never re-boots (a new one is born).
`RuntimeBuilder` → `RuntimeContainer` (NOT a service locator: no resolve(),
no get() — Pure DI stays at the Root, I-2), `RuntimeRegistry`,
`BootValidator`, `RuntimeAssembly` (readable tables).

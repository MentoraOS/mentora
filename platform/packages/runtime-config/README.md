# @mentora/runtime-config

Technical configuration loading and FAIL-CLOSED validation. I-5: three
species — produit (Policy params), technique (runtime), secret (vault); the
boot proves "chaque configuration est du bon type et dans ses bornes … Une
seule erreur = pas de démarrage" (F4.4 §7) and dies on "configuration
invalide" (F4.4 §6). **The only package of the workspace that reads
`process.env`** (`environmentSource`). Every declared field is required
unless it declares a default; the loader reports the COMPLETE violation
list, once. Secrets never ride a schema — only their NAMES (I-8).

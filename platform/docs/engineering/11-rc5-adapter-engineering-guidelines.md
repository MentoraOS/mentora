# RC-5 — Adapter Engineering Guidelines (Phase 2A.5)

> **Statut : documentaire.** Le guide du développeur d'adapters — quatorze
> règles, chacune cousue à sa loi. Rien d'inventé : quand le Corpus parle,
> il est cité ; quand il se tait, la règle n'existe pas ici.

**La définition avant les règles** (F4.4/I-4, verbatim) : un Adapter « *sert
une seule frontière et ne crée ni fait, ni Decision, ni vérité* » ; il a deux
interlocuteurs (le fournisseur et le port/Dispatch) ; entrant → Dispatch seul,
sortant → ports seuls (I-12) ; référencé par le seul Root (A-9).

| # | Règle | Loi | Pourquoi | Erreur classique | Bonne pratique |
|---|---|---|---|---|---|
| 1 | **Aucun métier** | I-4 ; F4.1 §7 (« un `if` métier dans un service est ingrammatical » — a fortiori sous lui) | l'adapter exécute une capacité, le domaine décide | « petit » if de validation dans le repository | tout jugement remonte en Décision du domaine ; l'adapter classe seulement ses canaux (A-7) |
| 2 | **Aucun `Date.now()`** | A-6 (« injectés, jamais ambiants ») ; interdiction « horloge lue » (F4.1) | un instant ambiant rend le rejeu indéterministe | horodater une ligne dans le mapper | l'instant vient du fait/de la Séquence ; le SEUL Date.now licite est `SystemClock` (runtime-clock), injecté par le Root |
| 3 | **Aucun `Math.random()`** | A-6 (identité injectée, jamais ambiante) ; F5.4 §10 (Nonce/Salt = mécanismes crypto) | l'aléa non-crypto fabrique des identités faibles et des tests flous | générer un id « temporaire » | `IdGenerator` injecté (runtime-identity, CSPRNG) ; en spec, les doubles de testing-id |
| 4 | **Aucun `process.env`** | I-5 (trois espèces de configuration) ; F4.4 §7 (type + bornes, fail closed) | une config ambiante échappe à la validation du boot | lire une URL de base « vite fait » | tout passe par runtime-config (l'unique lecteur), validé, injecté par le Root |
| 5 | **Aucun SDK dans le domaine** | A-9/I-7 verbatim : « aucun import de framework dans le domaine (scanné) » | le domaine survit à tous les fournisseurs | importer un type Prisma dans un mapper de domaine | les types du dehors « meurent aux Adapters » ; MENTORA0016 scanne |
| 6 | **Aucune transaction hors `retain()`** | S-3 (« la transaction appartient à la Séquence ; le registre fournit l'atomicité ») ; A-3 ; interdit absolu « port dans la transaction » | les transactions longues et les ports dedans tuent l'atomicité | ouvrir une TX dans un service ou entre deux ports | UNE transaction, dans l'adapter de rétention, qui ne parle à personne |
| 7 | **Aucun mapping dans les handlers** | F4.1 §7 (« services sans talent ») ; couture possédée (1C-1) | le service délègue, il ne traduit pas | convertir des ms en VO dans un ApplicationService | wire→domaine dans la Definition/factory de couture ; domaine→lignes dans le mapper d'adapter |
| 8 | **Aucune Policy dans un adapter** | F3.1 (Policy = règle produit publiée) ; F4.1 §4 (« jamais instanciées en chemin ») | un réglage produit caché sous un port est une règle sans propriétaire | « retryPolicy » maison dans le repository | les Policies naissent au Root avec leurs paramètres produit ; l'adapter n'en connaît aucune |
| 9 | **Aucun Aggregate modifié** | I-3 (« le Root construit la machinerie, jamais les vérités ») ; I-4 | l'unité n'entre/sort que par ses portes | « corriger » un champ à la persistance | portes seules : `snapshot()`/`fromSnapshot`/`retained()` ; toute mutation est un acte de Séquence |
| 10 | **Aucune logique métier** (redite volontaire de 1 côté données) | S-2 (« l'ORM est un outil, jamais un modèle ») | le schéma n'est pas un modèle métier | contrainte SQL « intelligente » non déclarée | seules les clés DÉCLARÉES existent (R-A, version, unicité d'identité) — chacune citée dans la Fiche |
| 11 | **Aucun cache de validité** | loi 15 (« la validité se vérifie à la source ») ; Titre VI (« cache de validité opposable » à jamais interdit) ; S-5 (jamais un réplica en retard) | un NON périmé qui autorise est le pire mensonge | mettre l'état d'un accord en cache « pour la latence » | les caches licites = copies périssables DATÉES de projections (P17), jamais une validité |
| 12 | **Aucun Secret exposé** | I-8 (« un secret n'a qu'un lieu ; ailleurs, seulement son nom ») ; F4.4 §9 (jamais log, jamais fait, jamais cache) | la valeur qui circule finit dans un log | logguer une chaîne de connexion | `SecretReference` partout ; résolution au vestibule (Root), valeur oubliée après usage ; dumps au régime du coffre |
| 13 | **Aucun framework dans les ports** | F4.4 §3 (« un Port ne connaît jamais un framework — types du dictionnaire + valeurs pures ») | sinon l'implémenteur impose son interface : « l'inversion de dépendance inversée » | retourner une entité Prisma par le port | le port parle le dictionnaire ; l'adapter traduit, des deux côtés |
| 14 | **Aucune publication inline** | A-4 (« la publication lit la rétention — jamais l'inverse ») ; M-4 ; interdit absolu « publication hors relais » | la publication fantôme et le double-envoi naissent là | `bus.publish()` après le commit « pour aller vite » | la rétention écrit l'Outbox de faits ; le RELAIS (exécutable) porte, at-least-once |

## Anti-patterns nommés par le Corpus (à connaître par cœur)

« la rétention qui parle » · « la publication fantôme » · « l'identité
ambiante »/« l'Ambiant » · « le Repository métier » · « le Read Model de
validité » · « projection persistée comme vérité » · « le flag caché qui
gouverne du métier » · « le quatrième chemin » (un cron qui écrit, un script
qui répare) · « le secret codé en dur » · « le lease-gardien » (F5.1 §19).

## Le rituel du développeur d'adapter

1. Lire le PORT (chez son consommateur) — il est la loi ; ne jamais le modifier.
2. Écrire l'adapter sous lui : `<Provider><Capability>Adapter`, deux interlocuteurs.
3. Classer chaque échec dans SON canal (RC-2) ; journaliser sans matière (O-2).
4. Rejouer la suite de contrat 0C (I-10) contre l'adapter ET le double mémoire.
5. Déclarer ses ressources au cycle de vie (I-11) — un composant non enregistré n'existe pas.
6. Inscrire la Fiche de Registre (S-10) ; la CI la vérifie.

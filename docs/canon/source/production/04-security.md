---
doc: f5-04-security
title: F5.4 — Security Architecture & Trust (état final ratifié)
type: source
titre: production
statut: "Ratifié et GELÉ — reconstruction canonique fidèle (R2-Corpus Lot 6B)"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
materialise_par: "R2-Corpus Lot 6B"
sources_session:
  - "F5.4 Partie 1 — Trust Foundation & Identity (T-1→T-8 ; deux vestibules ; cinq chaînes de preuve)"
  - "F5.4 Partie 2 — Authorization, Delegation & Access (T-9→T-16 ; PDP=PEP ; autorisation distribuée)"
  - "F5.4 Partie 3 — Defense, Cryptography & Secret Management (T-17→T-24 ; Secret Zero ; Supply Chain ; Relevé d'accès) + revue de conformité du Conseil (Nonce/Salt, Attestation Build/Boot, CA, Relevé à Fiche)"
  - "F5.4 Partie 4 — Security Governance, Privacy, Compliance & Incident Response (T-25→T-32) + revue de conformité (Gouvernance qualifiée, Privacy↔Consent, BC/DR)"
  - "F5.4.99 — Security Constitutional Audit (Chaîne de Révocation = 6e chaîne ; sept identités de gouvernance ; Secret Zero = Cérémonie de Fondation ; politique signée ; réservation Matière/Fait/Personne personnelle)"
note: >-
  Reconstruction fidèle de l'état final ratifié de F5.4 (quatre parties T-1→T-32,
  amendées par les revues de conformité du Conseil et par F5.4.99). Parties 1-2
  rédigées par le Conseil, Parties 3-4 rédigées par le CTO puis revues et
  ratifiées — toutes sont sources de session ratifiées. Ce chapitre possède la
  Constitution de la Sécurité et les lois T-1→T-32. Principe : la Sécurité
  protège les propriétaires, elle ne devient jamais propriétaire ; la Confiance
  est un théorème, jamais un climat. Règle N°18 : le Grand Audit F5.99 (Lot 6E)
  vérifie sans modifier. Scaffolding de session exclu. Titre VII pour toute
  évolution.
---

# F5.4 — Security Architecture & Trust

> État **final ratifié** : quatre parties (T-1→T-32), amendées par les revues de
> conformité et par F5.4.99. **Principes** : *la Sécurité protège les
> propriétaires, elle ne devient jamais propriétaire ; la Confiance est une
> propriété démontrée, jamais supposée.*

## Nature

**La sécurité est la garde des frontières de propriété** : elle n'en crée aucune (elle garde celles de F2/F3/F4 — chaque frontière de propriété EST une frontière de confiance) et **ne décide jamais du métier** (ses instruments n'ont aucun chemin vers une Command ni vers un refus — elle peut *fermer une porte*, jamais *juger un acte*). **La confiance est un théorème** : « X est digne de confiance pour Y » se démontre par une chaîne de preuves vérifiable, à chaque traversée — jamais par la position, l'habitude ou l'ancienneté.

---

# Partie 1 — Trust Foundation & Identity (T-1 → T-8)

**Les deux vestibules, jamais mêlés** : le **vestibule des personnes** (I&A, `Credential`, `Session` — gelés) et le **vestibule des machines** (constitué ici — outillage de sécurité d'infrastructure qui émet/renouvelle/révoque les **Preuves de machine**, adossées à la chaîne d'artefact : *source → artefact → boot prouvé → preuve de machine*). **Une machine n'est jamais une personne** (les deux vestibules ne partagent ni registre, ni preuve, ni format ; « Credential » réservé aux personnes).

**Les cinq chaînes de preuve** : (1) **personnes** — Credential → Session → `ActorRef` injecté ; (2) **artefacts** — source → fabrication → `ArtifactId` signé → Boot prouvé ; (3) **machines** — artefact prouvé → Preuve de machine → traversées mTLS ; (4) **faits** — provenances, constatants, polices (F3) ; (5) **exécution** — Correlation/Causation dans les Enveloppes (F4). Le **Trust Model** est leur table de jonction, déclarée et boot-vérifiée.

**Zero Trust et Least Privilege ne sont pas des produits** : ce sont les lois déjà possédées (validité à la source loi 15, fail closed, identité injectée A-6, R-C, souveraineté F5.1.99) — étendues aux machines.

- **T-1** La sécurité garde les frontières de propriété ; elle n'en crée aucune et ne décide jamais du métier.
- **T-2** La confiance est démontrée à chaque traversée, jamais héritée, jamais déduite d'une position.
- **T-3** Identité, preuve, authentification et autorisation sont quatre concepts distincts : l'identité est stable, la preuve rotative, l'authentification établit, l'autorisation refuse — chez le propriétaire.
- **T-4** Deux vestibules jamais mêlés (personnes / machines) ; une machine n'est jamais une personne.
- **T-5** Cinq chaînes de preuve, cinq gardiens ; le Trust Model est leur table close, déclarée et boot-vérifiée.
- **T-6** Zero Trust et Least Privilege sont des lois déjà possédées, étendues aux machines.
- **T-7** La Confiance de sécurité et le Signal de confiance de la Réputation ne dérivent jamais l'un de l'autre.
- **T-8** Aucune identité implicite, aucune identité de session, aucun certificat-identité, aucun IdP-juge : les instruments prouvent *qui*, les propriétaires décident *quoi*.

---

# Partie 2 — Authorization, Delegation & Access (T-9 → T-16)

**Thèse** : *l'autorisation de Mentora est distribuée chez les propriétaires — toute autorisation centralisée est un vol de NON.* Mentora possède déjà sa théorie de l'autorisation : **le refus** (pas 6/7), R-C, la liste close M-10, la souveraineté d'exploitation. **PDP = PEP** : le propriétaire calcule et applique dans le même acte (le modèle « serveur de décision distant + points d'application » est mort — cache de décision = cache de validité, interdit). **Les tokens portent des Claims prouvés, jamais des droits** (les droits se calculent à la source). **Un rôle est un nom de gestion** (projection de la Gouvernance), jamais une vérité. **La délégation** (agir-pour) est un Claim tracé ; **l'impersonation** (agir-comme) une exception gouvernée, distinguée dans le journal ; **le break glass** élargit des droits sans jamais suspendre une loi.

- **T-9** L'autorisation est distribuée chez les propriétaires des actes ; aucun service central d'autorisation.
- **T-10** PDP et PEP ne se séparent jamais : le propriétaire calcule et applique dans le même acte, fail closed ; aucun cache de décision.
- **T-11** Une permission a un propriétaire (l'acte), une portée, une expiration, une révocation ; l'absence de permission est l'état par défaut — le moindre privilège en découle.
- **T-12** Un rôle est un nom de gestion, jamais une vérité ; supprimer les rôles ne perd aucune permission.
- **T-13** Les tokens portent des claims prouvés, jamais des droits ; les droits se calculent à la source.
- **T-14** La délégation est un claim tracé, l'impersonation une exception gouvernée distinguée au journal ; ni l'une ni l'autre ne substitue l'`ActorRef`.
- **T-15** Break glass et élévation JIT élargissent des droits pour une fenêtre bornée, tracés en Main courante, suivis d'une revue ; ils ne suspendent jamais une loi.
- **T-16** Separation of Duties et Access Review sont des invariants et rituels de gouvernance ; aucune décision d'autorisation n'est implicite ou ambiante.

---

# Partie 3 — Defense, Cryptography & Secret Management (T-17 → T-24)

**La Défense garde les chemins qui traversent les frontières** — elle ne possède ni vérité, ni permission, ni décision, ni identité ; elle protège les preuves. **Le coffre garde** (stockage, rotation, révocation, distribution) — **il ne décide jamais**. **La clé est la preuve, jamais l'identité** (une identité survit à mille rotations). **Le Secret Zero** (constitué **Cérémonie de Fondation** par F5.4.99) : la première confiance ne se calcule jamais — injectée, gouvernée, auditée (présence, double contrôle, journal, Main courante) — *rien ne naît sans témoins.* **La chaîne d'approvisionnement, continue, sans trou** : *Source → Build → Artifact → Signature → SBOM → Attestation → Boot → Preuve de machine → Runtime* (ferme le trou supply-chain de F5.1.99). **WAF/IDS/IPS/Rate Limiting/Anti-DDoS** protègent des **paquets, des capacités, la disponibilité** — jamais des actes, des permissions, des vérités. **Le Relevé d'accès** (hérité de F5.3.99) est la **preuve de consultation**, probante.

**Corrections de conformité du Conseil** (revue de la Partie 3) : *(1)* `Nonce`/`Salt` sont des **mécanismes cryptographiques**, jamais nommables dans une vérité (réservation F2.5.2 intacte) ; *(2)* l'**Attestation** est **produite au Build, vérifiée au Boot** (propriétaire = Build) ; *(3)* la **Certificate Authority** est le mécanisme derrière le vestibule des machines, jamais un propriétaire second ; *(4)* le **Relevé d'accès est un Registre probant à Fiche** (deux parties : vérité au propriétaire de la donnée protégée, exploitation à la sécurité) — jamais un silo « de la sécurité ».

- **T-17** Les secrets servent les preuves, jamais les décisions.
- **T-18** Toute preuve cryptographique est rotative ; l'identité demeure.
- **T-19** Le chiffrement protège la matière, jamais la vérité.
- **T-20** Toute confiance cryptographique remonte au Secret Zero (Cérémonie de Fondation).
- **T-21** Toute chaîne de fabrication est signée, attestée (au Build), vérifiée et bootée (au Boot).
- **T-22** Les mécanismes de défense protègent uniquement les traversées, jamais les décisions métier.
- **T-23** Le Relevé d'accès est probant (Registre à Fiche) ; le Log demeure perdable.
- **T-24** La cryptographie démontre ; elle ne décide jamais.

---

# Partie 4 — Security Governance, Privacy, Compliance & Incident Response (T-25 → T-32)

**La Gouvernance gouverne ceux qui protègent** — trois niveaux, trois propriétaires : la **Politique** déclare (Gouvernance), le **Standard/Control** exécute (Exploitation), le **code** implémente. **Le Threat Model éclaire, ne gouverne jamais** ; **le Risk Register** conserve probabilité/impact/propriétaire/traitement/statut. **La Compliance démontre** (ISO/SOC/GDPR/PCI/HIPAA/NIS2 sont des **preuves externes que la Constitution est respectée, jamais des autorités**). **La réponse aux incidents** (détection→qualification→confinement→éradication→restauration→revue) prolonge l'Incident de F5.3.99 sans le redéfinir. **DR applique les lois gelées** (RPO/RTO/Perte Déclarée/Inventaire/Réadmission — F5.2) ; **BC protège le service**. **L'audit démontre seulement** (l'audit constitutionnel est la forme suprême de cette règle).

**Précisions de conformité du Conseil** (revue de la Partie 4) : *(1)* **« Gouvernance » nu banni** — qualifié : la **Gouvernance constitutionnelle** (Titre VII : amende les lois) vs la **Gouvernance d'exploitation** (approuve Fiches, politiques, changements) ; les politiques de sécurité relèvent de la seconde ; *(2)* **Privacy↔Consent re-scellé** : la Privacy *opérationnelle* garde (contrôles, Relevés d'accès), mais les **consentements, portées, effacement et droits de la personne restent les vérités gelées du domaine Consent et du Compte** ; *(3)* **BC = promesse constitutionnelle** (le produit continue d'obéir à sa Constitution pendant la catastrophe — dégradation gracieuse, jamais un fail-open) ; **DR = procédure d'exploitation** (bornée par les Fiches).

- **T-25** La Gouvernance gouverne ; elle ne protège pas directement.
- **T-26** Toute politique est publiée avant d'être appliquée — et **signée** (auteur, approbateur, version, justification, provenance ; aucun artefact gouverné n'est anonyme — F5.4.99).
- **T-27** La conformité démontre ; jamais elle ne décide ; aucune norme externe n'est une autorité constitutionnelle.
- **T-28** Le Threat Model éclaire ; il ne gouverne jamais.
- **T-29** Le DR applique les lois déjà gelées (F5.2).
- **T-30** Le Business Continuity protège le service (promesse constitutionnelle) ; le DR protège les mécanismes (procédure d'exploitation).
- **T-31** Toute réponse à incident est gouvernée, jamais improvisée.
- **T-32** Toute norme externe est un mécanisme de démonstration, jamais une autorité constitutionnelle.

---

# Amendements de F5.4.99 (ratifiés)

1. **La Chaîne de Révocation** — **sixième chaîne** transversale (latente dans tout le corpus : révocation immédiate d'I&A, `Struck`/`Invalidated`/`Readmitted`, `AccordAnnulé`, `Withdrawn`) : *toute preuve morte se démontre* ; gardien = le propriétaire de l'objet révoqué. Elle est la moitié « une preuve meurt » dont la chaîne de preuve est la moitié « une preuve naît ».
2. **Sept identités de gouvernance** : `SecurityPolicyId`, `ThreatModelId`, `RiskId`, `ControlId`, `VulnerabilityId`, `SecurityReviewId`, `DisclosureId` — *tout objet gouverné porte une identité opaque et stable*.
3. **Le Secret Zero = Cérémonie de Fondation** (présence, double contrôle, journal, Main courante — *rien ne naît sans témoins*).
4. **La politique signée** (auteur, approbateur, version, justification, provenance) — *aucun artefact gouverné n'est anonyme* (aligné sur ADR/RFC et Fiches).
5. **Réservation de vocabulaire** : **Matière personnelle** (va au Storage, destructible) / **Fait personnel** (aux registres, immuable, crypto-shreddable) / **Personne concernée** (au Compte/Consent, vérités gelées) — « donnée personnelle » nu **banni** ; les trois mots rendent infranchissable la frontière Privacy↔Consent.

**Résultat** : **trente-deux lois (T-1→T-32)**, **six chaînes de preuve** (personnes, artefacts, machines, faits, exécution, **révocation**), **deux vestibules** (personnes, machines).

## Anti-Patterns (Titre Sécurité)

Partie 1 : la muraille · l'identité-permission · le certificat-identité · la confiance ambiante · l'IdP-juge · la machine-personne. Partie 2 : le service central d'autorisation · le PDP distant · le rôle-vérité · le token-porteur-de-droits · l'identité-autorise · l'impersonation silencieuse · le break glass qui casse les murs · le privilège permanent. Partie 3 : le certificat-identité · le secret codé en dur · le coffre-juge · la signature-permission · le WAF-législateur · le chiffrement-vérité · le rate-limit-autorisation · le secret éternel. Partie 4 : la norme-législatrice · le pentest-décideur · le patch-politique · le DR-constitution · le risque-vérité · la compliance-propriétaire · la privacy-sécurité · la gouvernance-technique.

---

## Provenance de matérialisation (non normatif)

Reconstruction fidèle de l'état final ratifié à partir des sources de session **F5.4 Parties 1→4** (T-1→T-32) et **F5.4.99**. Les Parties 1-2 furent rédigées par le Conseil, les Parties 3-4 par le CTO puis **revues et ratifiées** par le Conseil — les quatre parties et les revues sont des sources de session ratifiées ; les **corrections de conformité** des revues (Nonce/Salt mécanismes, Attestation Build/Boot, CA mécanisme, Relevé d'accès à Fiche ; Gouvernance qualifiée constitutionnelle/exploitation, Privacy↔Consent, BC/DR) sont intégrées. **F5.4.99** ajoute la **Chaîne de Révocation** (6e chaîne), les **sept identités de gouvernance**, le **Secret Zero Cérémonie**, la **politique signée**, et la **réservation Matière/Fait/Personne personnelle**. **Règle N°18** : le Grand Audit F5.99 (Lot 6E) vérifie sans modifier ce chapitre. Le Relevé d'accès (hérité de F5.3.99) est ici sa première pièce. Les nombreuses entrées de glossaire dues (le vestibule des machines, la Preuve de machine, le Trust Model, la Permission, la Capability, le Secret Zero, le SBOM, le Relevé d'accès, Matière/Fait/Personne personnelle…) relèvent du Titre VII. Le scaffolding de session (Phase 0, scores, décision, État Git, STOP) n'est pas reproduit.

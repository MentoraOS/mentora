---
doc: f2-05-rules-invariants-failure-modes
title: F2.6 + F2.7 + F2.8 — Domain Rules • Invariants • Failure Modes (état final ratifié)
type: source
titre: constitution
statut: "Ratifié et GELÉ — reconstruction canonique fidèle (R2-Corpus Lot 3e)"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
materialise_par: "R2-Corpus Lot 3e"
sources_session:
  - "F2.6 + F2.7 + F2.8 — Domain Rules • Invariants • Failure Modes (règles par domaine, invariants attaqués, modes de défaillance, sémantiques ; lois 14-18 ; police des Conversations ajoutée)"
  - "F2.9 — Architecture Constitution (ratifie F2.6/7/8 « tenus pour gelés, les 18 lois » ; n'amende aucun contenu)"
note: >-
  Reconstruction fidèle de l'état final ratifié. F2.9 ratifie ce chapitre sans
  l'amender. Les articles formels des 18 lois (P1-P18, format démonstration/
  conséquence/violation/sanction) appartiennent à F2.9 Titre I (chapitre 06) :
  ce chapitre possède les RÈGLES par domaine, les INVARIANTS et leurs attaques,
  et les MODES DE DÉFAILLANCE + sémantiques — il référence les articles sans les
  dupliquer. Les noms d'événements suivent le Dictionnaire (chapitre 04). Une
  variante d'un nom d'événement est réconciliée au propriétaire. Scaffolding de
  session exclu. Titre VII pour toute évolution.
---

# F2.6 + F2.7 + F2.8 — Domain Rules • Invariants • Failure Modes

> État **final ratifié**. Les lois nouvelles 14→18 nées ici complètent les
> **18 lois permanentes**, consolidées en articles P1-P18 par F2.9 Titre I
> (chapitre [06-architecture-constitution.md](06-architecture-constitution.md)).

---

# Partie A — F2.6 Domain Rules

Classes : **[S]** structurelle · **[T]** temporelle · **[J]** juridique · **[É]** économique · **[Éth]** éthique · **[Séc]** sécurité · **[C]** confidentialité · **[UX]** expérience. Pour chaque règle : elle appartient à ce domaine parce que lui seul détient le NON correspondant ; elle est opposable par le refus du propriétaire (fail closed) et par la police de registre quand elle existe ; elle survit dix ans parce qu'elle est indépendante des écrans, des canaux et des fournisseurs.

| Règles de… | Règles permanentes |
|---|---|
| **Engagement** | Une Demande vise un Créneau du Cadre publié [S] · L'Acceptation précède toute Confirmation [T] · Nulle Confirmation sans conditions accomplies, encaissement compris [É] · Le silence a une échéance : la Caducité [T] · Toute Annulation porte son Auteur et subit les règles publiées [S][UX] · Un Accord confirmé ne fut jamais présenté autrement [UX] |
| **Consultation** | Nulle Ouverture sans Accord échu [T] · Nul enregistrement sans Consentements actifs de **tous** (combinaison possédée ici) [J][C] · Le Brief précède le Live ; le Résumé n'y entre que par Adoption [S][Éth] · Une Interruption n'est jamais requalifiée en Clôture [S] · Toute Suite ouverte sera traitée ou assumée ouverte — jamais silencieusement perdue [UX] |
| **Professional Identity** | Seul le Titulaire écrit sa Déclaration [S] · Toute Spécialité déclarée vient du Référentiel [S] · L'Offre publiée est complète ou n'est pas [S] · Nulle preuve déguisée en déclaration [Éth] |
| **Reputation** | Un Avis exige une Rencontre clôturée de son Auteur [S][Éth] · Le Sujet n'écrit jamais la Preuve ; sa Réponse est annexée, jamais substituée [Éth] · Ni masquage sélectif, ni réordonnancement flatteur (RN-02) [Éth] · Tout retrait de preuve passe par un Verdict motivé [J] · Tout Signal de confiance se déplie vers ses preuves (RT-03) [UX] |
| **Expert Economy** | Nul Revenu sans fait générateur (Rencontre servie) [É] · L'acquis, l'en-attente et le prévisionnel jamais confondus (BV-04) [É][UX] · Nul Retrait au-delà du Disponible [É] · Tout Ajustement est motivé par un fait [É] · L'Objectif n'engage que son déclarant [S] |
| **Augmentation** | Nulle Production sans Consentement actif [J][Éth] · Toute Production est marquée, citée, incertitude dite (AE-01/04/05) [Éth] · Jamais d'acte, toujours une Proposition (AE-02/03) [Éth] · L'écart d'une Proposition est aussi simple que son accueil [UX] · Capacité indisponible = silence, jamais une remontée simulée [Éth] |
| **Account** | Seul le Titulaire modifie ses choix et ferme [S] · Le Cadre n'est jamais un engagement [S] · L'Abonnement n'est jamais un revenu d'expert [É] · L'exercice des droits (accès, export, effacement) est toujours conduit, jamais entravé [J] |
| **Discovery** | Un Écart est mémorisé et opposable — jamais re-proposé sans acte nouveau [UX][S] · L'Intérêt n'est jamais un engagement [S] · La pertinence est reflétée, citée, jamais possédée [Éth] |
| **Enterprise** | Nulle Appartenance sans Acceptation du Membre (double NON) [S][J] · Toute Révocation porte son Auteur [S] · Le Parrainage dit qui prend en charge quoi, d'avance [É][UX] |
| **Consent** | L'absence vaut non [J][C] · Un Refus définitif ferme la porte à la re-sollicitation [J][Éth] · Les faits ne se réécrivent jamais ; l'Invalidation est motivée et historisée [J] · Le Gardien ignore le contenu des actes [C] |
| **Messaging** | Seule une personne ouvre [S] · Le contenu ne quitte jamais le lien [C] · La parole de rencontre et la conversation ne se mélangent jamais (NAV-04) [S][C] |
| **Identity & Access** | Nulle Entrée sans Preuve [Séc] · Toute Révocation est immédiate [Séc][T] · « Connecté » ne devient jamais un fait métier [S] |
| **Settlement** | Nul Ordre sans Commanditaire identifié [S] · Le Compte rendu au seul Commanditaire [C] · Le dialecte d'opérateur meurt à la frontière [S] |
| **Notification** | Livrer selon la Joignabilité, jamais contre elle [C][UX] · Ne jamais décider de signaler [S] · Le contenu d'un Signal n'est jamais lu [C] |
| **Storage** | Restitution au seul Déposant [C][Séc] · Nulle Destruction avant Rétention échue ; nulle Garde au-delà [J][T] · Le sens des Dépôts n'est jamais interprété [S] |

**Balayages ratifiés :**
- **Règles oubliées, trouvées** : *la police des Conversations* — un Interlocuteur peut signaler ; l'extrait incriminé traverse par **son** acte (la personne, seul pont) ; les faits `ConversationReported` / `ConversationVerdictRendered` (Dictionnaire) complètent Messaging, car « chaque gardien de registre possède sa police » et Messaging y échappait. *L'éligibilité des personnes* (âge, capacité juridique) — règle [J] du Compte, à instruire au premier marché qui l'exige.
- **Dupliquées** : « fail closed » et « nul n'écrit chez autrui » — invariants transversaux, dédupliqués vers F2.7.
- **Règles-projections démasquées** : « expert actif/inactif », « profil complet », « à renouveler » — des lectures, pas des règles.
- **Promues invariants** : le privé ne traverse jamais ; l'absence vaut non ; toute Annulation porte son Auteur.
- **Promues politiques publiées** : règles d'annulation, délais de caducité, définitivité par type, rétentions, « écarté = plus jamais ».

---

# Partie B — F2.7 Domain Invariants

**Méthode d'attaque** : chaque invariant a été testé contre six contournements — commande, événement, migration, IA, administrateur métier, et rejeu. Un invariant ne survit que s'il est gardé par **le refus du propriétaire à la source** (jamais par la bonne volonté des appelants), par **la police du registre** (pour les faits déjà nés), et par **l'ACL** (pour ce qui vient d'ailleurs, legacy compris). L'administrateur métier ne modifie jamais un fait : il *commande une police motivée* — la seule porte, et elle laisse une trace.

**Invariants par domaine (classés)** — *Hard* : nulle Ouverture sans Accord échu [T] ; nul enregistrement sans accords actifs de tous [Legal] ; nul Revenu sans fait générateur [Business] ; l'histoire du Consent immuable [Legal] ; le contenu (messages, rencontres, dépôts, signaux) jamais exposé [Legal/C] ; Restitution au seul Déposant [Hard] ; compte rendu au seul Commanditaire [Consistency]. *Ethical* : AE-01→06 entières ; le Sujet n'écrit jamais sa Preuve ; la pertinence citée. *Temporal* : Acceptation < Confirmation < Échéance ; Rétention borne la Garde ; Révocation immédiate. *Consistency* : toute Annulation/Révocation porte son Auteur ; un fait a exactement un constatant ; une Projection n'entre jamais dans un registre. *Soft* (dégradables en le disant) : fraîcheur des projections ; délais de livraison des Signaux.

**Invariants transversaux — attaqués un à un, tous devenus permanents :**

| Invariant | Attaque la plus forte tentée | Verdict |
|---|---|---|
| Une vérité possède toujours un propriétaire | la taxonomie (tuée en F2.2.99 §1) était la dernière orpheline | **Permanent** |
| Aucun domaine n'écrit chez un autre | l'Adoption (résumé→artefact) — mais c'est l'acte d'une personne, constaté par l'adoptant | **Permanent** |
| Toute commande est refusable | la fermeture de compte ? — refusable aussi (obligations en cours), puis conduite | **Permanent** |
| Toute projection reste une projection | Signal de confiance (exécuté en F2.2.99) — la loi s'est prouvée sur nous | **Permanent** |
| Le contenu privé ne traverse jamais | le signalement d'abus — l'extrait traverse par l'acte du signaleur : le pont, pas une brèche | **Permanent** |
| Le consentement implicite n'existe jamais | migration legacy (« consentements » cochés d'office) — l'ACL les traduit en *absence*, à re-solliciter | **Permanent** |
| L'IA ne décide jamais | « auto-acceptation » d'une Demande par agenda intelligent — c'est une **règle déclarée par l'expert** (son acte, d'avance), jamais l'IA | **Permanent** |
| La confiance ne provient jamais de l'argent (ni l'inverse) | « expert Premium mis en avant » — la mise en avant est de la présentation payée, **jamais un Signal de confiance** ; la frontière tient si la surface l'affiche comme telle | **Permanent** (avec vigie UX) |
| La personne est le seul pont | rappel automatique de Suite en conversation — non : Signal, pas Message | **Permanent** |
| La connaissance descendante vit dans l'ACL | multi-PSP, multi-IdP — N dialectes, un langage | **Permanent** |
| La validité se vérifie à la source | cache d'accords Consent « pour la latence » — une copie est une vue ; l'acte exige la source | **Permanent** (nouveau, № 15) |

> Les énoncés constitutionnels formels de ces invariants sont les articles **P1-P18** de F2.9 Titre I (chapitre [06-architecture-constitution.md](06-architecture-constitution.md)).

---

# Partie C — F2.8 Failure Modes

**Catastrophes par famille — qui détecte / refuse / répare / publie / est informé :**

| Catastrophe | Détecte & refuse | Répare | Publié | Informé / jamais informé |
|---|---|---|---|---|
| Commande invalide, incomplète, prématurée, tardive | le propriétaire, fail closed, à la source | l'appelant corrige | une **Décision motivée** (jamais silence) | l'appelant / personne d'autre |
| Double commande, rejeu | l'identité de l'acte (idempotence) | rien — le second est sans effet | rien de neuf | — |
| Ordres contradictoires, hors séquence | l'ordre des faits du registre (le propriétaire séquence sa vérité) | dernier acte valide gagne, le reste refusé | Décisions motivées | les auteurs |
| Événement manquant / tardif / dupliqué | le consommateur (consommation idempotente, tolérante au retard) | rattrapage par relecture du langage publié | — | le commanditaire de l'outillage |
| Projection utilisée comme fait | les contrats (aucune projection n'est exposée comme fait) + revue | requalification | — | l'architecture |
| Consentement absent / retiré en cours d'acte | l'acteur, à la source, **avant et pendant** (l'enregistrement s'arrête au Retrait) | l'acte cesse ; ce qui est né reste borné par l'accord d'alors | le fait d'arrêt chez l'acteur | les participants / jamais des tiers |
| Preuve falsifiée, avis frauduleux | la Police du registre | Verdict, Invalidation | `ReviewReported` → Verdict ; `Invalidated` | le Sujet et l'Auteur / le public ne voit que le résultat |
| PSP indisponible | l'ACL de Settlement le rend « indisponible » | retry d'Ordre (idempotent) ; l'Accord **reste Accepté**, jamais affiché confirmé | `SettlementOrderFailed` au Commanditaire | la personne (Signal) / aucun autre domaine |
| IdP indisponible | I&A — nulle Entrée sans Preuve | attente ; jamais de contournement | — | la personne |
| IA indisponible | l'Augmentation — silence, **jamais une remontée simulée** | reprise | rien (le silence est le contrat) | personne — c'est le point |
| Storage indisponible | l'acteur dont l'acte promet une garde : **l'acte ne commence pas** (un enregistrement sans garde promise trahirait le consentement) | reprise, nouveau départ | Décision motivée | les participants |
| Notification perdue | la Notification (`SignalUndeliverable`) — un fait métier **ne dépend jamais** d'une livraison | re-livraison | `SignalUndeliverable` à l'Émetteur | l'Émetteur seul |
| ACL défaillant | le domaine voit « indisponible » — le dialecte brut ne passe jamais | réparation d'outillage | — | l'outillage |
| Migration interrompue | l'ACL anti-legacy — l'ancien monde continue de servir | reprise par étapes réversibles | — | l'outillage |

**Sémantiques — autorisées et interdites :**

| Sémantique | Statut |
|---|---|
| **Fail Closed** | obligatoire pour tout acte, partout |
| **Fail Open** | **interdit** — unique exception : l'affichage de projections datées, *dites périmées* (l'esprit AE-05) |
| **Exactly Once** | **mythe interdit** — nul n'a le droit de le promettre |
| **At Least Once + consommation idempotente** | la loi, pour tous les faits et tous les ordres |
| At Most Once | toléré pour les Signaux uniquement (best effort assumé) |
| **Cohérence forte** | dans le registre de chaque propriétaire, sur sa propre vérité |
| **Cohérence à terme** | entre domaines, pour les faits ; **jamais** pour la validité (loi 15 : la validité à la source) |
| Retry | ordres et livraisons, par identité d'acte |
| Compensation / Forward Recovery | la voie normale : l'histoire ne se corrige que par de nouveaux faits (Ajustement, Verdict, Invalidation) |
| **Rollback / Backward Recovery** | **interdits sur les faits publiés** — tolérés seulement à l'intérieur d'un acte jamais né |
| Timeout / Cancellation | l'échéance est un fait (Caducité) ; l'annulation un acte de personne, jusqu'à la naissance du fait |

---

# Lois ajoutées par ce chapitre (14 → 18)

Nées des destructions de l'audit, elles portent le corpus à **18 lois permanentes** (consolidées P1-P18 par F2.9) :

14. **Exactly-once est un mythe interdit** — nul n'a le droit de le promettre.
15. **At-least-once + consommation idempotente partout** ; **la validité se vérifie à la source, les faits se consomment à terme**.
16. **Fail open interdit** hors projections datées dites telles.
17. **L'histoire ne se rollback jamais — on compense vers l'avant.**
18. **Un acte dont la promesse exige un gardien indisponible ne commence pas.**

---

## Provenance de matérialisation (non normatif)

Reconstruction fidèle de l'état final ratifié à partir des sources de session :

- **Chapitre combiné F2.6 + F2.7 + F2.8** — règles par domaine (8 classes), invariants (par domaine classés + table transversale attaquée), modes de défaillance (catastrophes + sémantiques), lois 14-18. **Corrections ratifiées** : police des Conversations ajoutée à Messaging (`ConversationReported`/`ConversationVerdictRendered`) ; déduplication des règles transversales vers les invariants ; promotions règles→invariants et règles→politiques publiées.
- **F2.9** — ratifie ce chapitre sans l'amender (« F2.1→F2.8 tenus pour gelés, les 18 lois ») et en consolide les invariants en articles **P1-P18** (Titre I, chapitre 06).

**Divergence résolue par propriété** : la source écrivait, pour la police des Conversations, « `VerditTranché` ». Le nom d'événement appartient au Dictionnaire (chapitre 04) et à F2.2, qui l'ont gelé sous **`ConversationVerdictRendered`** ; le nom a été réconcilié au propriétaire, la variante de la source signalée. Non dupliqués ici : les **articles formels des 18 lois** (F2.9 Titre I) et les **noms canoniques** (Dictionnaire). Le scaffolding de session (Phase 0, audit contradictoire, notation, décision, État Git, STOP) n'est pas reproduit.

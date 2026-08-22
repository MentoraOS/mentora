# RFC-003 — Dossier d'instruction du domaine Account (sept points que le Corpus laisse ouverts)

**Dossier d'instruction Titre VII** · Statut : **EN INSTRUCTION — aucune ratification, AUCUN CODE Account avant décision CTO** · Epic : EPIC-002 (#140) · Blueprint : [`docs/architecture/account-domain-blueprint.md`](../../../architecture/account-domain-blueprint.md)

## Cadre

Le domaine Account est **entièrement catalogué** (F3.2-B / F3.2-B.99 ; commandes 36-46, faits 40-46, machines 5-7, lectures 4 et 10, policies `ReachabilityPolicy`/`SubscriptionPolicy`, specifications `ClosableAccount`/`CoherentFrame`/`SubscriptionChange`, VOs, Entity `Device`, Factory `SubscriptionFactory`, OHS unique métier, ACL vers I&A et Settlement). L'analyse d'architecture (Phase 0) ne trouve **aucune contradiction** ; elle trouve sept points où le texte ratifié **ne dit pas** ce que le code devrait faire. Chacun est instruit ci-dessous avec options et recommandation ; aucun n'est tranché par le code.

## P1 — L'identité du Compte (`AccountId` vs `PersonId`)

**Texte** : « `Person` n'est pas un Aggregate (la Personne est un acteur) ; la vérité “qui est la personne dans Mentora” EST le compte » ; « règle d'identité singleton-par-acteur : une unité singleton-par-acteur peut porter l'identifiant de son acteur comme identité (… bornée à un par acteur) » ; le catalogue des identités cite `FundsLedger`/`ConsentLedger` comme cas, pas `Account`. L'ACL du Compte tend à I&A un « `PersonId` opaque ».
**Options** : (A) `Account` est singleton-par-acteur : son identité EST `PersonId` (référence-comme-identité) — un `AccountId` distinct n'existe pas ; (B) `AccountId` propre + `PersonId` frappé à l'enregistrement et porté comme attribut.
**Recommandation : A.** Elle rend l'ACL triviale (I&A reçoit l'identité même du Compte, opaque pour lui), respecte « un par acteur » (R-B : revenir = nouvelle personne = nouvelle identité) et n'invente aucune seconde clé.

## P2 — La naissance de l'`AvailabilityFrame`

**Texte** : unité propre « vivante » (aucun état terminal), commande `ChangeAvailabilityFrame` seule — **aucune commande de naissance**, fait `AvailabilityFrameChanged`.
**Options** : (A) naît au premier `ChangeAvailabilityFrame` (la factory est implicite dans le porteur : absent ⇒ naissance, présent ⇒ changement) ; (B) naît avec le Compte (chorégraphie `PersonRegistered` → cadre vide) ; (C) commande nouvelle `OpenAvailabilityFrame` (**interdit** : complète le catalogue).
**Recommandation : A**, identité singleton-par-Compte (`AvailabilityFrameId` = identité du Compte, même exception écrite que P1) — « le Cadre au Compte ».

## P3 — La chorégraphie interne de `AccountClosed`

**Texte** : « la fermeture se propage aux unités sœurs par le fait `AccountClosed` — chorégraphie interne ». Le catalogue des réactions ne nomme pas les transitions émises.
**Options** : (A) une Réaction interne `AccountClosed → EndSubscription` (la souscription active s'éteint ; le cadre reste — il ne se lit plus sans Compte actif ; la demande d'aide ouverte reste traitable par la plateforme) ; (B) aucune réaction — la fermeture n'est qu'un fait, les sœurs restent telles quelles ; (C) réaction vers toutes les sœurs.
**Recommandation : A** (la seule sœur à cycle de vie commercial est `Subscription` ; l'éteindre évite un ordre de Règlement orphelin) ; la table de réactions d'Account en déclare UNE, boot-validée.

## P4 — Le couplage `Subscription` ↔ Settlement

**Texte** : « `Subscription` — Commissioner du Règlement via l'ACL du Compte ; cycle `Active → Ended` ; règle du contrat commercial ». Non dit : la souscription est-elle `Active` dès `StartSubscription` ou après `SettlementOrderExecuted` ?
**Options** : (A) `Active` à `StartSubscription` ; l'ordre de Règlement est commandé via l'ACL ; `SettlementOrderFailed` (compte rendu au seul Commissioner) déclenche `EndSubscription` motivé — une Réaction interne de plus ; (B) état intermédiaire `Pending` (**interdit** : la machine ratifiée est `Active → Ended`) ; (C) `Active` seulement après exécution, la commande `StartSubscription` restant refusée tant que l'ordre n'est pas exécuté (la Séquence ne peut attendre — A-2).
**Recommandation : A.** Settlement n'existant pas encore, l'ACL Account→Settlement est **déclarée comme port** (commanditaire), son adapter arrive avec Settlement ; d'ici là, la composition refuse de booter un Root qui ne fournit pas l'adapter (fail closed), ou accepte un adapter « aucun Règlement » explicitement déclaré pour le dev.

## P5 — Les paramètres de `ReachabilityPolicy` et `SubscriptionPolicy`

**Texte** : deux policies nommées ; « paramètres = configuration produit » ; `ReachabilityPolicy` consommée par la Notification. Aucun paramètre nommé.
**Recommandation** : les paramètres sont **produit** (I-5) et se déclarent au Root comme `ProofRequirementPolicyParams` : `ReachabilityPolicyParams` = canaux admis (allowlist de `ReachabilityChannel`) ; `SubscriptionPolicyParams` = offres de souscription admises (allowlist de références). **Aucune sémantique au-delà d'une allowlist** sans décision produit écrite.

## P6 — `VerificationState` sans commande

**Texte** : VO `VerificationState` ; Account « NON : Titulaire + plateforme (vérification) » ; aucune commande du catalogue ne change l'état de vérification.
**Options** : (A) `VerificationState` reste à sa valeur d'enregistrement jusqu'à une révision Titre VII qui nommera la commande ; (B) inventer `VerifyAccount` (**interdit**).
**Recommandation : A**, trou **enregistré** dans le code.

## P7 — Le `Device`

**Texte** : Entity `Device` (« même acteur, aucune référence externe : I&A référence SES `Credential`, jamais le Device »), commandes `RegisterDevice`/`RemoveDevice` **sans fait**. Attributs non nommés.
**Recommandation** : `Device` = { `DeviceId` (identité intérieure, opaque, fournie par l'acte), `registeredAt` } et rien d'autre ; tout libellé, empreinte ou plateforme est une donnée de surface, jamais une vérité du domaine tant que le dictionnaire ne la nomme pas.

## Décision demandée au CTO

Ratifier P1-P7 tels que recommandés (ou trancher autrement). Jusqu'à ratification : **aucun code Account**. Après ratification : le blueprint devient l'architecture validée, le plan d'ingénierie (#144-#148 et leurs stories) s'exécute dans l'ordre du chemin critique.

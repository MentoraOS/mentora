# RFC-001 — Transport de la corrélation à travers le port de rétention

**Dossier d'instruction Titre VII** · Statut : **RATIFIÉE — Option A retenue (décision CTO du 2026-08-18)** · Story débloquée : #88 (FEATURE-005, Sprint 3)

> **Ratification (Titre VII)** — Le CTO ratifie l'**Option A** : `RetentionContext` devient un **paramètre optionnel** du port de rétention (`retain(unit, context?)`), valeurs d'enveloppe seules (`correlationId?`, `causationId?`, `traceparent?`). Migration **additive** : aucun contrat public cassé ; les implémentations existantes restent valides ; les ports nés après cette date naissent avec le paramètre. Le Sprint 3 (story #88) est officiellement débloqué.

## Problème

La loi F5.3/M-3 veut que la corrélation (`CorrelationId`, `CausationId`) voyage de bout en bout : commande entrante → rétention → Outbox de faits → relais → consommateurs. Or le port de rétention gelé (`AgreementRepository.retain(unit)` — 2B-1, architecture IMMUTABLE depuis R4) ne transporte **pas** la corrélation : l'`AgreementOutboxStore` écrit `correlationId/causationId = NULL` (signalé au rapport 2B-1). L'enveloppe du relais (2B-2) sait la porter ; la rétention ne la lui donne pas. La surface d'entrée (FEATURE-005) rendra ce manque visible de bout en bout.

## Contraintes constitutionnelles citées

- F4.1/A-9 : l'enveloppe porte la corrélation — **les faits restent purs** (jamais de corrélation DANS le fait).
- A-3 : l'Outbox de faits naît DANS l'unique transaction de rétention — la corrélation doit donc être disponible **au moment du retain**.
- R4 : le port est gelé — le modifier exige ce dossier.
- F5.3 §2 : la trace se transmet intacte, « aucune perte ».

## Options instruites

**Option A — Élargir la signature du port** : `retain(unit, context: RetentionContext)` où `RetentionContext = { correlationId?, causationId?, traceparent? }` (valeurs d'enveloppe, jamais du domaine). Le pas 8 de la Séquence transmet le contexte de l'enveloppe entrante. + : de bout en bout exact, aligné A-3 ; − : amendement du port gelé (tous les adapters + doubles + suites contractuelles évoluent — expansion additive, paramètre optionnel).

**Option B — Corrélation reconstituée au relais** : le relais enrichit l'enveloppe depuis un registre séparé (écrit hors transaction). − : viole A-3 (la vérité de corrélation naîtrait HORS de la rétention — fenêtre d'incohérence), complexité d'un second write. **Rejetée par l'instruction.**

**Option C — Statu quo documenté** : corrélation NULL en Outbox, trace portée par la télémétrie seule. − : « aucune perte » (F5.3) violée pour les consommateurs de faits ; la promesse M-3 de l'enveloppe reste vide à jamais.

## Recommandation de l'instruction

**Option A**, comme **amendement additif** du contrat de port (paramètre optionnel `context` ; défaut = comportement actuel) : les implémentations existantes restent valides pendant la migration ; la contract suite gagne les promesses de transport ; aucune matière métier ne traverse (identifiants opaques seuls, conforme A-9/M-3). Périmètre d'impact : `domain-agreement` (signature du port), `application-kernel` (pas 8 transmet), `adapters-persistence-agreement` (OutboxStore écrit les colonnes déjà présentes en base), suites contractuelles. Aucun changement de schéma (colonnes créées dès 0001).

**Décision CTO (2026-08-18)** : **Option A ratifiée.** Le blocage de la story #88 est levé. Ordre de mise en œuvre : les ports I&A naissants (Sprint 2) portent le paramètre dès leur amendement ; le port Agreement et le pas 8 de la Séquence migrent avec la story #88 (Sprint 3) — expansion additive, jamais un big-bang.

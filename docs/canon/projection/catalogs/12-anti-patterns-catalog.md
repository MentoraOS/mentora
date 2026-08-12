---
doc: canon-catalog-12-anti-patterns
title: Catalogue des anti-patterns (classés par couche)
type: projection
titre: canon
statut: "Projeté — R2-Projections Lot 4 (Catalogues)"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
projete_par: "R2-Projections Lot 4"
source_autorite:
  - "F3.1 §17 + F3.3 §12 — 18 anti-patterns tactiques — source/domain/01,06"
  - "F4.1→F4.4 — anti-patterns applicatifs, circulation, process, infrastructure — source/application/01..04"
  - "F5.1→F5.8 — anti-patterns de la Production — source/production/01..08"
note: >-
  INDEX des anti-patterns, classés par couche. Projection déterministe de la
  Source. Chaque couche : anti-patterns nommés · chapitre propriétaire. Aucun
  anti-pattern inventé — tous rassemblés de la Source. Tous meurent au même test :
  qui protège l'invariant, qui détient le NON, qui a constaté ? Évolution : Titre VII.
---

# Catalogue des anti-patterns

**But.** Retrouver tout anti-pattern et sa couche. **Portée.** Les anti-patterns
de F3, F4, F5. **Index seul** — les fiches complètes vivent dans la Source. *Aucun
anti-pattern n'est inventé ici* (règle N°33) ; ils sont **rassemblés**.

## Tactique — les 18 (F3.1 §17 + F3.3 §12)

Aggregate anémique · God Aggregate · Entity intelligente · VO mutable · Obsession
primitive · Repository métier · Factory universelle · Specification géante ·
Service fourre-tout · Application Service omniscient · Projection persistée comme
vérité · Read Model mutable · Process omniscient · Événement-commande · Cache de
validité · **le service de réservation** · **la copie de matière par domaine** ·
**l'Entity au NON clandestin**.
*Source : [F3.1 §17](../../source/domain/01-tactical-building-blocks.md), [F3.3 §12](../../source/domain/06-tactical-documentation-freeze.md).*

## Application (F4)

| Couche | Anti-patterns | Chapitre |
|--------|---------------|----------|
| Séquence (8) | l'endpoint intelligent · le behavior-cerveau · le service bavard (App→App) · la rétention qui parle · la publication fantôme · l'identité ambiante · le gestionnaire d'erreurs qui avale les refus · la Séquence permutée | [F4.1](../../source/application/01-application-core-sequence.md) |
| Process Managers (8) | (huit fiches) | [F4.2](../../source/application/02-process-managers.md) |
| Circulation (9) | (neuf fiches) | [F4.3](../../source/application/03-circulation.md) |
| Infrastructure (10) | (dix fiches) | [F4.4](../../source/application/04-infrastructure-composition-runtime.md) |

## Production (F5)

| Chapitre | Anti-patterns nommés | Source |
|----------|----------------------|--------|
| Runtime (7) | le Runtime intelligent · le Hot Reload métier · le Shared Runtime · le Self-Healing métier · la résurrection d'instance · le drainage sacrifié · le manifeste législateur | [F5.1 §22](../../source/production/01-runtime.md) |
| Persistence (8) | la base-intégration · le schéma-modèle · le cache-vérité · la recherche-vérité · la migration-qui-corrige · le réplica-menteur · l'UPDATE-effaceur · l'event-store-propriétaire | [F5.2 §12](../../source/production/02-persistence.md) |
| Observability (8) | le dashboard-décideur · l'alerte-législatrice · le log-base-de-données · la trace-preuve · l'AIOps-propriétaire · la métrique-dans-la-Command · l'alerte-bruit · le vendor-télémétrie | [F5.3 §12](../../source/production/03-observability.md) |
| Security | la muraille · l'identité-permission · le certificat-identité · la confiance ambiante · l'IdP-juge · la machine-personne · le service central d'autorisation · le PDP distant · le rôle-vérité · le token-porteur-de-droits · le break glass qui casse les murs · le secret codé en dur · le coffre-juge · le WAF-législateur · le chiffrement-vérité · la norme-législatrice · la privacy-sécurité · la gouvernance-technique … | [F5.4 §Anti-Patterns](../../source/production/04-security.md) |
| Reliability (8) | Availability First · Retry infini · Timeout métier · Circuit Breaker législateur · Brownout des invariants · Consensus propriétaire · Self Healing autonome · Split Brain accepté | [F5.5 §12](../../source/production/05-reliability.md) |
| Scalability (9+) | le tenant-propriétaire · l'active-active de vérité · le fairness-métier · l'autoscaling-métier · le quota-offre · l'Edge-vérité · le consensus-global-de-croissance · le noisy-neighbor-toléré · la cellule-propriétaire (+ fraude au fairness, projection mondiale sans date) | [F5.6 §7](../../source/production/06-scalability.md) |
| Operations | (fiches d'exploitation) | [F5.7](../../source/production/07-operations.md) |
| Governance | le Wiki-Vérité · le PDF-Source · la Documentation autonome · le Diagramme-législateur · le Corpus qui corrige · le Diff qui décide · le Glossaire créateur · le Board souverain · la Publication incomplète · la Dette cachée · la publication-ratification · le lien cassé ignoré · le chapitre fermé trop tôt … | [F5.8 §Anti-Patterns](../../source/production/08-governance.md) |

## Références

[F3.1 §17](../../source/domain/01-tactical-building-blocks.md) · [F3.3 §12](../../source/domain/06-tactical-documentation-freeze.md) · [F4.1](../../source/application/01-application-core-sequence.md)→[F4.4](../../source/application/04-infrastructure-composition-runtime.md) · [F5.1](../../source/production/01-runtime.md)→[F5.8](../../source/production/08-governance.md) · [Handbook §I](../handbook/01-official-handbook.md).

## Notes

- Les fiches complètes (symptôme, cause, solution) vivent dans la Source ; ce catalogue **pointe**. Le Handbook (chapitre I) explique **pourquoi** ils existent. Tous meurent au même test : *un NON gardé par personne, ou une vérité écrite par tous.*

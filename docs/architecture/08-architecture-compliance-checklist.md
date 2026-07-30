# Mentora Architecture Compliance Checklist

**Version:** 1.0  
**Status:** APPROVED  
**Owner:** CTO Office  
**Program:** Mentora Product Completion

## 1. Purpose

Checklist obligatoire pour toute évolution significative, PR et release.

- `BLOCKER` : fusion interdite
- `WARNING` : justification requise
- `INFO` : recommandation

## 2. Ownership — BLOCKER

- [ ] Domaine propriétaire identifié.
- [ ] Une règle métier n'a qu'un propriétaire.
- [ ] `03-domain-boundaries.md` respecté.
- [ ] Tout nouveau chevauchement est enregistré.

## 3. Dependencies — BLOCKER

- [ ] `05-dependency-map.md` respecté.
- [ ] Aucun cycle.
- [ ] APIs publiques utilisées.
- [ ] Aucun import des internals d'un autre module.

## 4. Forbidden Imports — BLOCKER

- [ ] Aucun Firestore dans Domain.
- [ ] Aucun FirebaseAuth dans Domain.
- [ ] Aucun Agora SDK dans Consultation Domain/Application.
- [ ] Aucun SDK PSP dans Domain/Application produit.
- [ ] Aucun Ledger/Settlement internal dans Booking.
- [ ] Aucun nouvel accès Firestore direct depuis Presentation.

## 5. Product Boundaries — BLOCKER

- [ ] Scheduling reste autorité des disponibilités.
- [ ] Booking reste propriétaire de la réservation.
- [ ] Payment reste frontière produit.
- [ ] Consultation reste propriétaire du service.
- [ ] Meeting reste technique.
- [ ] Financial est utilisé via sa frontière publique.

## 6. Financial Freeze — BLOCKER

La modification Financial est limitée à correction, sécurité, tests, documentation, intégration PSP requise ou refactoring local nécessaire.

Tout nouveau moteur/pipeline/orchestrateur/sous-domaine exige un ADR/décision CTO.

## 7. Infrastructure — BLOCKER

- [ ] SDKs externes confinés en Infrastructure.
- [ ] Infrastructure implémente des ports/contrats.
- [ ] Firestore/PSP/Agora ne décident aucune règle métier.
- [ ] DTOs fournisseur ne traversent pas les frontières produit.

## 8. Events — BLOCKER

- [ ] Événement canonique unique.
- [ ] Fait déjà survenu.
- [ ] Immutable.
- [ ] Consommateur idempotent si nécessaire.

## 9. Automation / Notification — WARNING

- [ ] Automation n'invente aucune politique métier.
- [ ] Notification ne décide pas pourquoi un message doit être envoyé.
- [ ] Les transports restent séparés des intentions métier.

## 10. Shared — BLOCKER

- [ ] Aucun statut/policy métier spécifique.
- [ ] Aucun aggregate métier.
- [ ] Aucun repository spécifique à un domaine.

## 11. Presentation — BLOCKER

- [ ] UI → controller/use case.
- [ ] Aucun nouvel accès Firestore direct.
- [ ] Aucun PSP direct.
- [ ] Aucun internal Financial.
- [ ] Aucune règle critique uniquement dans un widget.

## 12. Tests — BLOCKER

- [ ] `dart format` exécuté sur les fichiers touchés.
- [ ] `flutter analyze` exécuté ; aucune nouvelle violation imputable au changement.
- [ ] Tests unitaires verts.
- [ ] Tests d'intégration concernés verts.
- [ ] Aucun test supprimé pour masquer un échec.
- [ ] Nouvelle règle critique couverte.

## 13. Security — BLOCKER

- [ ] Entrées validées.
- [ ] Permissions vérifiées.
- [ ] Secrets hors du code.
- [ ] Aucun secret/donnée sensible dans les logs.
- [ ] Webhooks PSP authentifiés et idempotents si concernés.

## 14. Documentation — WARNING

- [ ] Contrats publics documentés.
- [ ] Événements documentés.
- [ ] Decision Log/ADR mis à jour si nécessaire.
- [ ] Overlap/Dependency registers mis à jour si la frontière change.

## 15. Legacy — WARNING

- [ ] Aucun nouveau legacy inutile.
- [ ] Pas de Big Bang Refactor.
- [ ] Toute exception temporaire a un owner, un risque et un trigger de migration.

## 16. Merge Gate

```text
1 BLOCKER en échec → MERGE REFUSED
0 BLOCKER + WARNING justifiés → MERGE POSSIBLE
Tous contrôles applicables validés → MERGE APPROVED
```

**Status:** APPROVED

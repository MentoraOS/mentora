# Branch Protections & Repository Rulesets — Plan de gouvernance officiel

**MentoraOS — GitHub Governance v1.0, Lot 3 (MODE GENESIS)**

| | |
|---|---|
| **Version** | 1.0 |
| **Statut** | PLAN PRÊT À EXÉCUTER — aucun Ruleset n'a été créé (§1 : `gh` non authentifié ; rien n'est prétendu) |
| **Autorité** | Constitution > documents gelés (Organization, Career Ladder, Handbook, Freeze) > CODEOWNERS > ce plan |
| **Exécution** | CTO, après `gh auth login`, **après le script Teams du Lot 2** (les reviews CODEOWNERS n'ont d'effet que si les équipes existent) |

---

## 1. Audit GitHub (état des lieux, plafond sans authentification)

| Vérification | Méthode | Résultat |
|---|---|---|
| **Branche par défaut** | `git ls-remote --symref origin HEAD` | ✅ **`main`** — la bascule ordonnée est EFFECTIVE (constatée, pas supposée) |
| Branches | `ls-remote --heads` | 4 : `main`, `develop`, `release`, `arch-008-candidate` — toutes à `383a6a1` |
| Tags | `ls-remote --tags` | 1 : `foundation-v1.0.0` (objet `7eb604b9…` → commit `8d095ee…`) |
| CODEOWNERS | dépôt | ✅ présent (Lot 1, 56 règles, 0 chemin invalide) |
| Workflows GitHub Actions | dépôt (`.github/`) | **AUCUN** — seul CODEOWNERS existe ⇒ **tout status check est « Future R5 »** (§6) |
| Rulesets existants | API authentifiée requise | INAUDITABLE (`gh` non authentifié) — le script §8 commence par cet audit et s'arrête si un Ruleset inattendu existe |
| Classic Branch Protections | API authentifiée requise | INAUDITABLE — même règle |
| GitHub Teams | API authentifiée requise (401 constaté au Lot 2) | INAUDITABLES — le script Teams (Lot 2) doit être exécuté AVANT ce lot |
| Environments / Repository Settings | API authentifiée requise | INAUDITABLES — Environments = Lot 4 |

## 2. Réconciliation — Règle documentaire → Règle GitHub → Ruleset

Chaque règle GitHub ci-dessous est justifiée par une règle des documents gelés ; aucune règle orpheline :

| Règle documentaire (source gelée) | Règle GitHub | Ruleset | Validation |
|---|---|---|---|
| « On n'y pousse JAMAIS directement » (Handbook §4, main/develop) | `pull_request` obligatoire | Main, Develop, Release | PR seule voie d'entrée |
| Review du niveau requis + propriétaire du chemin (Career Ladder §5) | `require_code_owner_review` + 1 approbation min | Main, Develop, Release | CODEOWNERS route, GitHub exige |
| « L'auteur ne s'auto-approuve jamais » (Career Ladder §5) | approbation d'un NON-auteur (mécanique PR GitHub) + `dismiss_stale_reviews` | Main, Develop, Release | ré-approbation après nouveau push |
| « Chaque fil résolu ou tranché » (Handbook §5/§6) | `required_review_thread_resolution` | Main, Develop, Release | conversation résolue exigée |
| « L'histoire publiée ne se réécrit pas » (Handbook §4 ; anti-pattern #2) | `non_fast_forward` (force-push bloqué) | TOUS + Tag | aucune réécriture possible |
| Branches gouvernées, Genesis « préservée à vie » (Handbook §4) | `deletion` bloquée | TOUS + Tag | suppression impossible |
| `main` = vérité de production, histoire linéaire (Handbook §4) | `required_linear_history` | Main, Release | merge commits interdits sur main/release |
| Le train de release : develop reçoit les merges de features (Handbook §4/§14) | PAS de linéarité exigée sur develop (merges `--no-ff` licites) | Develop | souplesse JUSTIFIÉE par le workflow gelé |
| La gate décide du merge (Handbook §3/§11) | `required_status_checks` — **ACTIVATION DIFFÉRÉE R5** (§6 : exiger un check inexistant bloquerait toute PR pour toujours) | Main, Develop, Release (phase 2) | activés le jour où la CI publie les checks |
| Baseline immuable `foundation-v1.0.0` = `8d095ee` (Freeze, PCR-001) | Ruleset TAG : update+deletion bloqués | Tag Protection | le tag ne peut ni bouger ni mourir |
| Le canon n'évolue que par Titre VII (Constitution) | CODEOWNERS route `docs/canon/` vers `architecture` + review obligatoire sur toutes les branches protégées | Main, Develop, Release | toute PR touchant le canon exige l'approbation architecture — la procédure Titre VII reste l'autorité |
| Exceptions tracées (Handbook ; Bypass §7) | bypass = org admin SEUL, trace écrite obligatoire | TOUS | §7 |

## 3. Les 5 Rulesets (paramètres exacts)

### 3.1 — `Protect Main`

| Paramètre | Valeur |
|---|---|
| Description | La vérité de production : PR + review CODEOWNERS + linéarité ; ni force-push ni suppression |
| Cible | `refs/heads/main` |
| Enforcement | `active` |
| Pull Request | requise ; 1 approbation minimum ; `require_code_owner_review: true` ; `dismiss_stale_reviews_on_push: true` ; `required_review_thread_resolution: true` |
| Merge strategy (PR) | `rebase` et `squash` autorisés, `merge` (commit de merge) interdit — c'est ce qui rend la linéarité praticable ; le train release→main passe en rebase-merge (commits conservés, histoire linéaire) |
| Linear history | ✅ requis |
| Force push | ❌ interdit (`non_fast_forward`) |
| Deletion | ❌ interdite |
| Creation/renommage | restreints (la branche existe, personne ne la recrée) |
| Status checks | **différés — voir §6** (activés au premier workflow R5) |
| Signature des commits | **NON exigée à la genèse** — les 53 commits existants ne sont pas signés ; l'exiger aujourd'hui interdirait tout rebase-merge de l'existant. Durcissement planifié quand les clés de signature seront gouvernées (avec le vault, R8) — documenté, jamais improvisé |
| Bypass | org admin uniquement (§7) |

### 3.2 — `Protect Develop`

Identique à Main **sauf** : `required_linear_history` ABSENT (les merges `--no-ff` de features sont le workflow gelé du Handbook — souplesse justifiée, la seule) ; merge methods : `merge` + `squash` + `rebase` autorisés.

### 3.3 — `Protect Release`

**Protection maximale** = paramètres de Main, plus : `creation` restreinte aux porteurs du bypass (une branche `release/*` se coupe par un acte de release engineering, pas par accident). Cible : `refs/heads/release` ET `refs/heads/release/*` (le modèle du Handbook §14 coupe des `release/x.y`).

### 3.4 — `Protect Genesis`

| Paramètre | Valeur |
|---|---|
| Description | `arch-008-candidate` — la branche historique Genesis, préservée à vie, consultable à jamais |
| Cible | `refs/heads/arch-008-candidate` |
| Force push | ❌ interdit |
| Deletion | ❌ interdite |
| Pull Request | requise pour toute mise à jour ordinaire — le « merge accidentel » devient impossible |
| Update direct | réservé au bypass org admin (le mode GENESIS actuel : lots commités localement puis poussés SUR ORDRE du CTO — ce canal reste ouvert pour lui seul, tracé) |
| Status checks / linéarité | non exigés (la branche est historique, sa discipline est la convention genèse) |

### 3.5 — `Tag Protection`

| Paramètre | Valeur |
|---|---|
| Description | `foundation-v1.0.0` = LA BASELINE HISTORIQUE (commit `8d095ee`, Constitution gelée, PCR-001) — ni suppression, ni réécriture, ni déplacement, à perpétuité |
| Cible | `refs/tags/foundation-v1.0.0` **et** `refs/tags/v*` (les futurs tags de release naissent protégés) |
| Update (déplacement) | ❌ interdit (`non_fast_forward`) |
| Deletion | ❌ interdite |
| Creation | libre pour les nouveaux tags `v*` via le train de release ; un tag né ne bouge plus |

## 4. Vérification de couverture

Aucune branche oubliée : les 4 branches existantes sont chacune sous un Ruleset nominal ; le motif `release/*` couvre les futures branches de train ; les branches `feature/*`/`fix/*`/`hotfix/*` restent volontairement libres (courtes vies, la protection s'exerce à leur POINT D'ENTRÉE — la PR vers les branches protégées). Aucune contradiction : Develop est le seul assouplissement et il est justifié par le workflow gelé ; aucune règle ne contredit CODEOWNERS (elles l'activent) ni la Constitution (elles la matérialisent).

## 5. Matrice Status Checks (canonique — AUCUN n'existe encore)

**Constat d'audit : le dépôt n'a AUCUN workflow GitHub Actions.** La gate vit aujourd'hui en local (`pnpm verify`, gate froide 112/112 au Freeze). Exiger maintenant un check inexistant bloquerait toutes les PR : les checks sont donc **déclarés ici, exigés plus tard** (activation = premier lot CI de R5, qui mettra à jour les Rulesets en une commande).

| Check requis (nom canonique) | Contenu | Statut |
|---|---|---|
| `typecheck` | `turbo run typecheck` workspace | **Future R5** |
| `lint` | `turbo run lint` (0 warning) | **Future R5** |
| `test` | `turbo run test` (suites + intégration PG service) | **Future R5** |
| `build` | `turbo run build` (graphe complet) | **Future R5** |
| `architecture` | suite `testing-architecture` (DAG, familles, feuilles) | **Future R5** (déjà incluse dans `test` ; check séparé si signal dédié voulu) |
| `contracts` | contract suites rejouées (mémoire + réel) | **Future R5** (incluses dans `test` aujourd'hui) |
| `coverage` | seuils ≥95/95/95 par paquet | **Future R5** |
| `security` | audit dépendances + scan secrets | **Future R6** (outillage à choisir par ADR) |

## 6. Bypass Policy

| Question | Réponse |
|---|---|
| Qui | **Org admin uniquement** (le CTO). Aucune équipe, aucun rôle repo, aucune app |
| Pourquoi | Deux cas seulement : (1) le canal GENESIS (poussée ordonnée de lots sur `arch-008-candidate`) ; (2) urgence de production où le processus PR est matériellement impossible |
| Quand | Jamais pour la convenance ; jamais pour « gagner du temps » (anti-patterns #1/#4 du Handbook) |
| Trace | **Toute utilisation du bypass est consignée** : une note écrite dans le dépôt (issue ou note de release) citant la raison, le commit, la date — « une exception non tracée est une infraction, pas une exception » |
| Revue | Chaque bypass est revu au rituel hebdo suivant (Handbook §16) |

## 7. Séquencement d'exécution (ordre STRICT)

1. `gh auth login` (CTO) ; 2. Script Teams du Lot 2 (les équipes DOIVENT précéder les reviews CODEOWNERS) ; 3. Audit authentifié §8-0 ; 4. Création des 5 Rulesets §8 ; 5. Vérification §8-fin ; 6. Poussée des commits de gouvernance en attente — désormais VIA le canal gouverné.

## 8. Commandes prêtes à exécuter

```bash
# ---------- 0. AUDIT AUTHENTIFIÉ (obligatoire ; s'arrêter si l'existant surprend)
gh api repos/MentoraOS/mentora --jq '.default_branch'          # attendu: main
gh api repos/MentoraOS/mentora/rulesets --jq '.[].name'        # attendu: vide
gh api repos/MentoraOS/mentora/branches --jq '.[].name'
gh api "repos/MentoraOS/mentora/branches/main/protection" 2>&1 | head -3   # classic: attendu 404

# ---------- 1. Protect Main
gh api repos/MentoraOS/mentora/rulesets -X POST --input - <<'JSON'
{ "name": "Protect Main", "target": "branch", "enforcement": "active",
  "conditions": { "ref_name": { "include": ["refs/heads/main"], "exclude": [] } },
  "bypass_actors": [ { "actor_id": 5, "actor_type": "RepositoryRole", "bypass_mode": "always" } ],
  "rules": [
    { "type": "deletion" },
    { "type": "non_fast_forward" },
    { "type": "required_linear_history" },
    { "type": "pull_request", "parameters": {
        "required_approving_review_count": 1,
        "require_code_owner_review": true,
        "dismiss_stale_reviews_on_push": true,
        "require_last_push_approval": true,
        "required_review_thread_resolution": true,
        "allowed_merge_methods": ["squash", "rebase"] } }
  ] }
JSON

# ---------- 2. Protect Develop (linéarité absente = la seule souplesse, justifiée)
gh api repos/MentoraOS/mentora/rulesets -X POST --input - <<'JSON'
{ "name": "Protect Develop", "target": "branch", "enforcement": "active",
  "conditions": { "ref_name": { "include": ["refs/heads/develop"], "exclude": [] } },
  "bypass_actors": [ { "actor_id": 5, "actor_type": "RepositoryRole", "bypass_mode": "always" } ],
  "rules": [
    { "type": "deletion" },
    { "type": "non_fast_forward" },
    { "type": "pull_request", "parameters": {
        "required_approving_review_count": 1,
        "require_code_owner_review": true,
        "dismiss_stale_reviews_on_push": true,
        "require_last_push_approval": true,
        "required_review_thread_resolution": true,
        "allowed_merge_methods": ["merge", "squash", "rebase"] } }
  ] }
JSON

# ---------- 3. Protect Release (maximale + création restreinte)
gh api repos/MentoraOS/mentora/rulesets -X POST --input - <<'JSON'
{ "name": "Protect Release", "target": "branch", "enforcement": "active",
  "conditions": { "ref_name": { "include": ["refs/heads/release", "refs/heads/release/*"], "exclude": [] } },
  "bypass_actors": [ { "actor_id": 5, "actor_type": "RepositoryRole", "bypass_mode": "always" } ],
  "rules": [
    { "type": "creation" },
    { "type": "deletion" },
    { "type": "non_fast_forward" },
    { "type": "required_linear_history" },
    { "type": "pull_request", "parameters": {
        "required_approving_review_count": 1,
        "require_code_owner_review": true,
        "dismiss_stale_reviews_on_push": true,
        "require_last_push_approval": true,
        "required_review_thread_resolution": true,
        "allowed_merge_methods": ["squash", "rebase"] } }
  ] }
JSON

# ---------- 4. Protect Genesis (historique, consultable à jamais)
gh api repos/MentoraOS/mentora/rulesets -X POST --input - <<'JSON'
{ "name": "Protect Genesis", "target": "branch", "enforcement": "active",
  "conditions": { "ref_name": { "include": ["refs/heads/arch-008-candidate"], "exclude": [] } },
  "bypass_actors": [ { "actor_id": 5, "actor_type": "RepositoryRole", "bypass_mode": "always" } ],
  "rules": [
    { "type": "deletion" },
    { "type": "non_fast_forward" },
    { "type": "pull_request", "parameters": {
        "required_approving_review_count": 1,
        "require_code_owner_review": true,
        "dismiss_stale_reviews_on_push": false,
        "require_last_push_approval": false,
        "required_review_thread_resolution": true,
        "allowed_merge_methods": ["merge", "squash", "rebase"] } }
  ] }
JSON

# ---------- 5. Tag Protection (la baseline + les futurs v*)
gh api repos/MentoraOS/mentora/rulesets -X POST --input - <<'JSON'
{ "name": "Tag Protection", "target": "tag", "enforcement": "active",
  "conditions": { "ref_name": { "include": ["refs/tags/foundation-v1.0.0", "refs/tags/v*"], "exclude": [] } },
  "bypass_actors": [],
  "rules": [
    { "type": "deletion" },
    { "type": "non_fast_forward" },
    { "type": "update" }
  ] }
JSON

# ---------- 6. VÉRIFICATION FINALE
gh api repos/MentoraOS/mentora/rulesets --jq '.[] | "\(.id) \(.name) [\(.enforcement)]"'
# Test négatif (DOIT échouer avec GH013/protected):
#   git push origin main            -> refusé (PR obligatoire)
#   git push origin :release        -> refusé (deletion bloquée)
#   git push -f origin develop      -> refusé (non fast-forward bloqué)
#   git push origin :refs/tags/foundation-v1.0.0 -> refusé (tag protégé)
```

**Notes d'exécution** : `actor_id: 5` + `RepositoryRole` = rôle *admin* du dépôt (le bypass org-admin) — vérifier l'id retourné par l'API si GitHub le fait évoluer ; la `Tag Protection` n'a AUCUN bypass (personne ne déplace la baseline, pas même le CTO — un déplacement de baseline serait un acte Titre VII avec son propre appareil). Le premier lot CI (R5) ajoutera `required_status_checks` aux trois Rulesets de branches par `gh api … -X PUT`.

---

*Ce plan est la seule sortie possible du Lot 3 sans authentification GitHub. Aucun Ruleset n'existe du fait de ce lot et aucun n'est prétendu exister. Toute divergence découverte par l'audit authentifié (étape 0) se traite AVANT création.*

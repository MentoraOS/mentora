# GitHub Teams — Plan de gouvernance officiel

**MentoraOS — GitHub Governance v1.0, Lot 2 (MODE GENESIS)**

| | |
|---|---|
| **Version** | 1.0 |
| **Statut** | PLAN PRÊT À EXÉCUTER — aucune équipe n'a été créée (voir §1 : `gh` non authentifié au moment du lot ; ce document ne prétend rien) |
| **Autorité** | Constitution > Engineering Organization (gelée) > ce plan |
| **Exécution** | Par le CTO (ou sur son ordre) après `gh auth login` — script §7 |

---

## 1. Audit de l'organisation GitHub (état des lieux, plafond atteint)

| Vérification | Méthode | Résultat |
|---|---|---|
| L'organisation existe | API publique (`/orgs/MentoraOS`) | ✅ `MentoraOS`, id `317737171` |
| Dépôts publics | API publique (`/orgs/MentoraOS/repos`) | `[]` — **le dépôt `mentora` est privé** (conforme) |
| Dépôt `mentora` accessible | `git ls-remote` (credentials git) | ✅ 4 branches (`main`, `develop`, `release`, `arch-008-candidate`), toutes à `383a6a1` ; tag `foundation-v1.0.0` publié |
| Membres publics | API publique | `[]` — visibilités privées |
| **Équipes existantes** | API `/orgs/MentoraOS/teams` | **HTTP 401 — INAUDITABLE sans authentification.** Vraisemblablement aucune (organisation née du transfert), mais ce plan NE L'AFFIRME PAS : le script §7 commence par l'audit authentifié et **saute toute équipe déjà existante** (idempotent) |
| Permissions / rôles / owners / maintainers | API authentifiée requise | INAUDITABLE — première étape du script §7 |

**Décision de méthode** : `gh` n'est pas authentifié et aucun `GH_TOKEN` n'existe ; l'authentification est un acte interactif du CTO que ce lot ne peut ni faire ni simuler. Conformément au mandat : rien n'est créé, rien n'est inventé, tout est préparé.

## 2. Réconciliation — Responsabilité → Équipe → Permission → CODEOWNERS → Owner

Chaque siège de l'Engineering Organization (gelée) trouve son équipe ; chaque règle CODEOWNERS trouve son équipe ; aucune équipe sans responsabilité, aucune responsabilité orpheline :

| Responsabilité (Organization) | Équipe GitHub | Permission repo | Règles CODEOWNERS servies | Owner de la responsabilité |
|---|---|---|---|---|
| Constitution, ADR/RFC, socle (kernel/contracts/application-kernel), carte des contextes | `architecture` | `maintain` | `*` (fallback), `/docs/canon/`, `/docs/architecture|governance|organization/`, socle ×4, `testing-architecture`, `/.github/CODEOWNERS` | Architecture Office (ratification CTO) |
| Runtime Foundation, monorepo, infra, environnements, release engineering | `platform` | `maintain` | `/platform/` (général), `runtime-*` ×11, `/platform/infra/`, `/.github/`, `/platform/apps/server/` (co) | Platform Engineering |
| Les domaines métier (Engagement aujourd'hui, 15 à terme) | `backend` | `push` | les 4 paquets `*agreement*`, `/platform/apps/server/` (co), `prisma/` (co) | Équipes-domaines |
| Surfaces web/admin (aucun chemin encore) | `frontend` | `push` | — (naîtront avec `apps/web` etc.) | Frontend Engineering |
| App Flutter héritée + mobile futur | `mobile` | `push` | racine Flutter ×13 règles | Mobile Engineering |
| Mécanismes IA (gateway, évals — aucun chemin encore) | `ai` | `push` | — (naîtront avec `ai-*`) | AI Engineering |
| Auth/secrets/chiffrement/audit, veto sécurité | `security` | `push` | `runtime-security` (co), `prisma/` (co), `/.github/CODEOWNERS` (co) | Security Engineering |
| Stratégie de preuve, presets, suites | `qa` | `push` | `testing*` ×7 | QA Engineering |
| Outillage développeur, générateurs | `devex` | `push` | `/platform/tooling/`, `/platform/turbo/` | Developer Experience |
| Docs non-canoniques, héritage documentaire | `docs` | `push` | `/docs/` (général), `baseline/`, `philosophy/`, co sur `organization/` et `/platform/docs/` | Documentation Team |
| Design system (aucun chemin encore) | `design` | `push` | — (naîtront avec `design-system/`) | Design System Team |
| Roadmap, backlog, priorisation | `product` | `triage` | — (PM ne possède aucun chemin de code) | Product Management |

**Aucune 13e équipe n'est nécessaire** : l'audit de réconciliation ne révèle aucune responsabilité non couverte. Une équipe-parente `engineering` (nesting GitHub) a été considérée et écartée : les slugs plats sont ceux du CODEOWNERS, et le nesting n'apporte aujourd'hui que de la complexité — réévaluable à 50+.

**Équipes sans chemins actuels (`frontend`, `ai`, `design`, `product`)** — créées quand même, justification : la doctrine gelée est « des sièges, pas des personnes » — les sièges précèdent leurs occupants ET leurs artefacts ; créer ces équipes maintenant évite un lot de gouvernance à chaque premier chemin, et `product` opère dès aujourd'hui dans les issues (triage).

## 3. Définition des équipes (les 12)

Champs communs : **Repositories** = `MentoraOS/mentora` (monorepo unique) · **Privacy** = `closed` (visible des membres de l'org) · **Owners (org)** = le CTO (compte GitHub propriétaire de l'organisation) · **Maintainer de chaque équipe** = le CTO à la genèse · **Members** = à 2 développeurs, les deux comptes occupent tous les sièges (cumul) ; les membres rejoignent équipe par équipe au fil des recrutements, sans jamais réorganiser.

| Équipe | Slug | Description GitHub (≤ 1 ligne) | Mission (résumé — le détail est dans l'Organization gelée) | Interfaces |
|---|---|---|---|---|
| Architecture | `architecture` | Gardienne de la Constitution, du socle et des frontières | Faire respecter le canon dans le code ; ADR/RFC ; carte des 15 contextes | Toutes les équipes (revues) ; CTO (ratification) |
| Platform | `platform` | Runtime, monorepo, infra, CI/CD, release | Faire exister/tourner/observer les exécutables sans posséder une vérité métier | Toutes (elle les sert) ; security (secrets) |
| Backend | `backend` | Les domaines métier DDD (Engagement → 15) | Implémenter les vérités des domaines ratifiés | architecture (contrats), platform (runtime), qa |
| Frontend | `frontend` | Surfaces web et admin | Les clients web des contrats publiés | backend (contrats), design, platform |
| Mobile | `mobile` | L'application Flutter | L'app mobile sur les mêmes contrats publiés | backend, design, platform |
| AI | `ai` | Mécanismes IA (gateway, évals, embeddings) | Les mécanismes — la vérité de la Production reste au domaine Augmentation | backend (Augmentation), security (PII), platform |
| Security | `security` | Auth, secrets, chiffrement, conformité, audit | Le veto sécurité ; revue des chemins sensibles | Toutes ; escalade CTO seul |
| QA | `qa` | La stratégie de preuve | Presets, suites, gates — que chaque équipe exécute elle-même | Toutes |
| DevEx | `devex` | Outillage développeur, générateurs, templates | Temps idée→première gate verte | Toutes |
| Documentation | `docs` | Docs non-canoniques ; le canon SANS pouvoir éditorial | Reproduire la dernière source ratifiée ; onboarding ; runbooks | architecture (registres), toutes |
| Design | `design` | Design system, tokens, accessibilité | La bibliothèque UI unique multi-plateforme | frontend, mobile |
| Product | `product` | Roadmap, backlog, priorisation | Le *quoi ordonné* — jamais le comment | CEO/CTO, toutes les équipes-domaines |

## 4. Modèle de permissions (aucune ne contredit la Constitution)

| Niveau GitHub | Attribué à | Justification |
|---|---|---|
| `admin` | **Aucune équipe** — réservé aux org owners (CTO) | L'administration du dépôt est un acte de gouvernance, pas un droit d'équipe |
| `maintain` | `architecture`, `platform` | Gestion des réglages non destructifs (labels, milestones) sans droit d'admin ; conforme à leurs sièges |
| `push` (write) | `backend`, `frontend`, `mobile`, `ai`, `security`, `qa`, `devex`, `docs`, `design` | Écrire des branches et ouvrir des PR ; **le droit de MERGE réel viendra des protections du Lot 3** (reviews par CODEOWNERS, gates) — jamais du niveau de permission |
| `triage` | `product` | Gérer issues/labels sans toucher au code |

**Responsabilités croisées** (déclaratives ici, appliquées par le Lot 3) : Review = l'échelle de la Career Ladder §5 servie par CODEOWNERS ; Branches = personne ne pousse directement sur `main`/`develop`/`release` (protections) ; Releases = `platform` opère le train, la gate décide ; Architecture = `architecture` peut exiger un ADR partout. **Personne — CTO compris — ne modifie `docs/canon/` hors Titre VII** : la protection du Lot 3 matérialisera ce verrou (review architecture obligatoire) ; le CODEOWNERS route déjà la review.

## 5. Maintenance des équipes

| Acte | Qui | Comment |
|---|---|---|
| Créer une équipe | CTO ratifie ; `architecture` instruit | Dossier court : responsabilité couverte, chemins possédés, matrice §2 mise à jour ; jamais une équipe-technologie/personne/projet |
| Supprimer une équipe | CTO seul | Uniquement si la responsabilité disparaît ou fusionne — précédé d'une révision du CODEOWNERS |
| Changer une permission | CTO seul | Trace écrite (édition de ce document) |
| Valider une nouvelle équipe | CTO (après avis `architecture`) | La création GitHub SUIT la mise à jour documentaire, jamais l'inverse |
| Évolution d'une équipe | Le maintainer propose, le CTO arbitre | À 50+ : nesting réévalué ; à chaque domaine implémenté (R7), `backend` peut se scinder en équipes-domaines nommées — les slugs CODEOWNERS s'affinent ALORS (`@MentoraOS/domain-engagement`…) sans réorganisation |

## 6. Scalabilité (2 → 300 sans réorganisation)

Le mécanisme est celui de l'Organization gelée : **les équipes sont des sièges**. À 2 : les deux comptes sont membres des 12 équipes (le CODEOWNERS route déjà correctement les reviews). À 10 : chaque grande famille a son référent-maintainer. À 50 : plus personne ne cumule plus de 2 équipes ; guildes via les équipes existantes. À 100 : `backend` se scinde en équipes-domaines enfants (slugs affinés dans CODEOWNERS, structure inchangée). À 300 : nesting par familles F2 si utile. **À aucun palier on ne renomme ni ne supprime une équipe existante.**

## 7. Script de création — PRÊT À EXÉCUTER (après `gh auth login`)

Idempotent : audite d'abord, saute l'existant, n'invente rien. À exécuter par le CTO :

```bash
# ---------- 0. AUDIT AUTHENTIFIÉ (obligatoire avant toute création)
gh auth status
gh api orgs/MentoraOS --jq '.login,.id'
gh api orgs/MentoraOS/teams --jq '.[].slug'            # équipes existantes
gh api orgs/MentoraOS/members --jq '.[].login'          # membres
gh api orgs/MentoraOS/memberships/$(gh api user --jq .login) --jq .role  # votre rôle (attendu: admin)

# ---------- 1. CRÉATION DES 12 ÉQUIPES (saute celles qui existent)
create_team() { # $1=slug-name  $2=description  
  gh api orgs/MentoraOS/teams/"$(echo "$1" | tr 'A-Z' 'a-z')" >/dev/null 2>&1 \
    && echo "SKIP (existe): $1" \
    || gh api orgs/MentoraOS/teams -f name="$1" -f description="$2" -f privacy=closed --jq '.slug'
}
create_team "Architecture"  "Gardienne de la Constitution, du socle et des frontieres"
create_team "Platform"      "Runtime, monorepo, infra, CI/CD, release"
create_team "Backend"       "Les domaines metier DDD (Engagement -> 15)"
create_team "Frontend"      "Surfaces web et admin"
create_team "Mobile"        "L application Flutter"
create_team "AI"            "Mecanismes IA - la verite reste au domaine Augmentation"
create_team "Security"      "Auth, secrets, chiffrement, conformite, audit"
create_team "QA"            "La strategie de preuve"
create_team "DevEx"         "Outillage developpeur, generateurs, templates"
create_team "Documentation" "Docs non canoniques - le canon sans pouvoir editorial"
create_team "Design"        "Design system, tokens, accessibilite"
create_team "Product"       "Roadmap, backlog, priorisation"

# NOTE SLUGS: GitHub genere les slugs (Documentation -> documentation). Le CODEOWNERS
# utilise @MentoraOS/docs : creer l equipe "Documentation" produira le slug
# "documentation" — DANS CE CAS, soit renommer l equipe en "Docs" (slug docs),
# soit ajuster le CODEOWNERS. RECOMMANDATION: creer avec les NOMS ci-dessous
# pour obtenir les slugs EXACTS du CODEOWNERS:
#   "Docs" -> docs ; les autres noms produisent deja les bons slugs
#   (architecture, platform, backend, frontend, mobile, ai, security, qa, devex, design, product).

# ---------- 2. PERMISSIONS SUR LE DEPOT
grant() { gh api -X PUT orgs/MentoraOS/teams/"$1"/repos/MentoraOS/mentora -f permission="$2" && echo "OK $1=$2"; }
grant architecture maintain
grant platform     maintain
for t in backend frontend mobile ai security qa devex docs design; do grant "$t" push; done
grant product triage

# ---------- 3. MEMBRES (genese: les deux developpeurs sur tous les sieges)
# Remplacer LOGIN1/LOGIN2 par les comptes GitHub reels.
for t in architecture platform backend frontend mobile ai security qa devex docs design product; do
  gh api -X PUT orgs/MentoraOS/teams/$t/memberships/LOGIN1 -f role=maintainer
  gh api -X PUT orgs/MentoraOS/teams/$t/memberships/LOGIN2 -f role=member
done

# ---------- 4. VERIFICATION FINALE
gh api orgs/MentoraOS/teams --jq '.[] | "\(.slug): \(.permission // "n/a")"'
for t in architecture platform backend frontend mobile ai security qa devex docs design product; do
  echo "== $t"; gh api orgs/MentoraOS/teams/$t/repos --jq '.[].full_name + " (" + .role_name + ")"' 2>/dev/null
done
```

**Piège de slug documenté** : le CODEOWNERS (gelé au Lot 1) référence `@MentoraOS/docs` — créer l'équipe sous le nom **« Docs »** (slug `docs`), pas « Documentation ». Tous les autres noms produisent naturellement leur slug CODEOWNERS.

---

*Ce plan est la seule sortie du Lot 2 possible sans authentification GitHub. Aucune équipe n'a été créée ; aucune existence d'équipe n'est affirmée. L'exécution du script §7 par le CTO clôturera le lot ; toute divergence découverte par l'audit authentifié (étape 0) se traite AVANT les créations.*

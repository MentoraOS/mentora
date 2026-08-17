# Environments, Secrets & Variables — Plan de gouvernance officiel

**MentoraOS — GitHub Governance v1.0, Lot 4 (MODE GENESIS)**

| | |
|---|---|
| **Version** | 1.0 |
| **Statut** | PLAN PRÊT À EXÉCUTER — aucun Environment, Secret ni Variable n'a été créé (§1 : `gh` non authentifié ; rien n'est prétendu) |
| **Lois maîtresses** | I-8 (le code référence par NOM, le coffre détient) · I-5/F4.4 (config déclarée ; aucun flag caché ne gouverne le métier) · S-9 (les données réelles ne quittent jamais la production) |
| **Règle absolue de ce document** | AUCUNE valeur réelle de secret n'est écrite ici, nulle part, jamais |

---

## 1. Audit (état des lieux, plafond sans authentification)

| Vérification | Méthode | Résultat |
|---|---|---|
| Environments / Secrets / Variables / Deployments / OIDC / permissions workflows / protection rules | API authentifiée requise | **INAUDITABLES** (`gh` non authentifié, `GH_TOKEN` absent) — le script §9 commence par cet audit et s'arrête si l'existant surprend |
| Workflows GitHub Actions | dépôt | **AUCUN** (`.github/workflows` inexistant) — cohérent avec le Lot 3 : les checks sont « Future R5 » |
| Traces de déploiement réelles dans le dépôt | scan | `firebase.json` présent (héritage Flutter réel) ; **aucun** `vercel.json` ; aucun manifeste cloud |
| Fournisseurs ratifiés par le corpus | lecture | PostgreSQL/Prisma (gelé, 2B-1). **Aucun autre fournisseur n'est ratifié** — Supabase, Redis, Vercel, Sentry, OpenAI, Anthropic n'apparaissent dans AUCUNE décision ; ils n'entrent au catalogue ci-dessous que CONDITIONNÉS à leur ADR (Handbook §15 : « toute dépendance nouvelle est une décision ») |

## 2. Stratégie des Environments (les 3)

| | **development** | **staging** | **production** |
|---|---|---|---|
| Mission | Développement quotidien ; casser ici | Validation d'une Release Candidate — miroir de production | La production — rien d'autre |
| Branches autorisées | `develop`, `feature/*` | `release/*` | `main` uniquement |
| Déploiement | Automatique autorisé | Automatique sur coupe de `release/*` ; review optionnelle (le train du Handbook §14 valide par la gate + smoke) | **Manuel ou validé** : reviewers obligatoires |
| Reviewers requis | Aucun | Optionnels (équipe `platform`) | **Obligatoires** : `platform` + `security` (le CTO à la genèse — il occupe ces sièges) |
| Wait timer | 0 | 0 | **10 minutes** — documenté : la fenêtre d'annulation humaine après approbation ; assez courte pour un hotfix, assez longue pour un « stop » |
| Secrets | de dev uniquement (jetables) | de staging (jamais ceux de prod) | de production, au niveau ENVIRONMENT exclusivement |
| Variables | `APP_ENV=development`… | `APP_ENV=staging`… | `APP_ENV=production`… |
| Data | Spec uniquement | Spec/synthétique — **jamais** de données réelles (S-9) | Les seules données réelles |

Alignement Rulesets (Lot 3) : production ne peut déployer que depuis `main` (protégée), staging depuis `release/*` (protégée) — la chaîne branche→environnement est verrouillée aux deux bouts.

## 3. Catalogue des Secrets — classification COMPLÈTE

Discipline : (a) **aucune valeur écrite, aucun faux secret créé** ; (b) Environment Secret par défaut, Repository Secret seulement si tous les environnements partagent légitimement ; (c) chaque secret a une Foundation propriétaire ; (d) un secret d'un fournisseur non ratifié **n'existe pas tant que son ADR n'est pas accepté** (statut « conditionné »).

Légende criticité : 🔴 Critique · 🟠 Élevé · 🟡 Moyen · ⚪ Faible. « Utilisateurs autorisés » = équipes (Lot 2) ; à la genèse, le CTO occupe ces sièges.

| Secret | Description (nom seul, I-8) | Type / Environment | Criticité | Utilisateurs | Foundation propriétaire | Rotation | Impact si compromis | Révocation |
|---|---|---|---|---|---|---|---|---|
| `MENTORA_AGREEMENT_DATABASE_URL` | URL du moteur Agreement (CI: base de TEST jetable ; staging/prod: leurs moteurs) | Environment (les 3, valeurs distinctes) | 🔴 (prod) / ⚪ (CI-test) | `platform` | **R5** (CI) puis R8 (envs réels) | 90 j (prod) ; libre (test) | Prod : accès aux vérités — lockdown §7 immédiat | Rotation credentials moteur + redéploiement ; l'URL de test se régénère avec le conteneur |
| `DATABASE_URL` | Alias générique NON UTILISÉ — le nom canonique est `MENTORA_AGREEMENT_DATABASE_URL` (schéma I-5 déclaré) ; réservé pour interdire sa création sauvage | — | — | — | — | — | — | — |
| `FIREBASE_SERVICE_ACCOUNT` | Compte de service Firebase (héritage Flutter RÉEL : `firebase.json` en racine) | Environment production (mobile) | 🟠 | `mobile`, `platform` | Héritage / R6 (surfaces) | 180 j | Push/notifs mobile usurpables | Console Firebase : révoquer la clé du SA, en émettre une neuve |
| `JWT_PRIVATE_KEY` | Clé de signature des sessions (I&A) — **le coffre la détient, GitHub n'en reçoit qu'une copie de déploiement SI l'ADR vault l'exige** | Environment production | 🔴 | `security` | **R5/R6** (I&A) — création à l'implémentation de `Credential`/`Session`, pas avant | 90 j avec chevauchement de clés (kid) | Forge de sessions — lockdown §7 | Rotation de paire + invalidation des sessions actives (le domaine I&A la prévoit par conception) |
| `JWT_PUBLIC_KEY` | Clé publique de vérification (pas un secret stricto sensu — Variable candidate) | Variable d'environnement plutôt que Secret | ⚪ | `security` | R5/R6 | Suit la privée | Aucun (publique) | Suit la privée |
| `SUPABASE_URL` / `SUPABASE_ANON_KEY` / `SUPABASE_SERVICE_ROLE_KEY` | **CONDITIONNÉS — fournisseur NON ratifié** (le moteur gelé est PostgreSQL/Prisma auto-hébergeable ; Supabase serait une décision d'hébergement) | Environment (si ADR accepté) | 🔴 (service role) / 🟡 (anon) | `platform` | **ADR requis** — au plus tôt R8 (hébergement prod) | 90 j | Service role = accès moteur complet | Dashboard fournisseur + rotation |
| `REDIS_URL` | **CONDITIONNÉ — aucun cache ratifié** (F5.6 borne le cache par la loi 15/P17 ; aucun besoin né) | Environment (si ADR) | 🟠 | `platform` | **ADR requis** — au plus tôt R9/R10 | 180 j | Lecture de projections/caches | Rotation credentials |
| `OPENAI_API_KEY` / `ANTHROPIC_API_KEY` | **CONDITIONNÉS — fournisseurs IA non ratifiés** ; l'AI Gateway (mécanisme, Organization §7) les recevra par ADR | Environment (si ADR) | 🟠 | `ai` | **ADR requis** — R7+ (domaine Augmentation servi par la gateway) | 90 j | Coûts + fuite de prompts | Dashboard fournisseur : revoke + réémission |
| `SENTRY_DSN` | **CONDITIONNÉ — puits d'observabilité non ratifié** (O-10 : les puits sont interchangeables ; le choix est un ADR R5/R9) | Environment | 🟡 | `platform` | **ADR requis** — R5 (observabilité CI) ou R9 | 365 j | Injection d'événements parasites | Rotation DSN côté fournisseur |
| `VERCEL_TOKEN` / `VERCEL_PROJECT_ID` / `VERCEL_ORG_ID` | **CONDITIONNÉS — aucun front déployable n'existe** (aucun `apps/web`, aucun `vercel.json`) | Environment (si ADR) | 🟠 (token) / ⚪ (ids) | `frontend`, `platform` | **ADR requis** — R6 (Experience & API Surface) | 90 j (token) | Déploiement usurpé de surfaces | Revoke token dashboard |

**Synthèse** : 2 secrets à créer dès l'exécution (CI R5) : `MENTORA_AGREEMENT_DATABASE_URL` (environment `development`, valeur = base de test jetable) ; rien d'autre n'existe légitimement aujourd'hui. 1 héritage réel à rapatrier proprement (Firebase, à l'audit du premier workflow mobile). Tout le reste : **conditionné à ADR** — les créer maintenant serait fabriquer de faux secrets.

## 4. Catalogue des Variables (non-secrètes ; aucune valeur fictive)

Rappel constitutionnel : la config runtime du serveur est le SCHÉMA DÉCLARÉ `MENTORA_*` (I-5, gelé au 2B-3) — les Variables GitHub alimentent la CI/le déploiement et ne créent JAMAIS un canal de config métier caché (F4.4 : aucun flag caché ne gouverne le métier ; les paramètres PRODUIT restent gouvernés/journalisés).

| Variable | Rôle | Portée | Foundation |
|---|---|---|---|
| `APP_NAME` | Nom d'affichage des déploiements | Repository | R5 |
| `APP_ENV` | `development` / `staging` / `production` | Environment (chacune la sienne) | R5 |
| `API_URL` / `WEB_URL` | URLs publiques par environnement | Environment | R6 (naissent avec les surfaces) |
| `DEFAULT_LANGUAGE` / `DEFAULT_REGION` | Défauts d'expérience (fr / ML au produit — valeurs fixées à la création réelle, pas ici) | Environment | R6 |
| `LOG_LEVEL` | Alimente `MENTORA_LOG_THRESHOLD` au déploiement (le schéma I-5 reste l'unique lecteur) | Environment | R5 |
| `FEATURE_FLAGS` | **REFUSÉ comme variable libre** : un flag qui gouverne le métier est de la config PRODUIT gouvernée (F4.4) — si un système de flags naît, ce sera par ADR avec journalisation ; jamais une chaîne fourre-tout dans GitHub | — | ADR requis |

## 5. OIDC Strategy

**Pourquoi** : les clés longue durée stockées (tokens cloud, service accounts) sont le premier vecteur de compromission ; OIDC fait émettre à GitHub Actions un jeton éphémère par run, échangé chez le fournisseur cloud contre un rôle scoped — plus rien de volable au repos, conforme à l'esprit I-8 (référence, jamais détention).
**À partir de quand** : **R8** (Production Split & Fleet — le premier déploiement cloud réel) ; l'ADR du fournisseur cloud (R8) DOIT inclure la fédération OIDC comme exigence non négociable ; les éventuels tokens créés avant (Vercel R6 si ratifié) sont marqués « à migrer OIDC » à leur naissance.
**Impact sur Actions** : `permissions: id-token: write` par workflow concerné ; suppression des secrets cloud statiques correspondants ; les Rulesets/Environments restent inchangés (OIDC change la *preuve d'identité*, pas la gouvernance).

## 6. Rotation Policy

| Criticité | Fréquence | Déclencheurs additionnels |
|---|---|---|
| 🔴 Critique | 90 jours | Départ d'un détenteur ; incident ; doute |
| 🟠 Élevé | 180 jours | idem |
| 🟡 Moyen | 365 jours | idem |
| ⚪ Faible | Opportuniste (à chaque toucher) | — |

**Responsable** : l'équipe `security` (le CTO à la genèse) ; chaque secret a UN propriétaire nommé dans le tableau §3. **Audit** : revue trimestrielle du catalogue (rituel Quarterly, Handbook §16) — chaque secret existant doit correspondre à une ligne du §3 ; un secret hors catalogue est un incident. **Traçabilité** : toute création/rotation/révocation = une note écrite (issue) citant nom, environnement, motif, date — jamais la valeur. **Expiration** : préférer les mécanismes d'expiration natifs du fournisseur quand ils existent (tokens à TTL) plutôt que la discipline seule.

## 7. Emergency Lockdown — procédure officielle

**Qui agit** : le premier qui CONSTATE alerte (canal incident, Handbook §9) ; l'équipe `security` conduit ; le CTO est l'autorité de bypass. Personne n'attend une permission pour COUPER.

**Ordre strict** :
1. **Couper les déploiements** : désactiver GitHub Actions du dépôt (Settings → Actions → Disable) OU verrouiller les 3 environments (reviewers → aucun approbateur) — 1 minute, réversible.
2. **Révoquer À LA SOURCE** (chez le fournisseur : moteur DB, Firebase, IA…) le secret compromis — la révocation source prime sur la rotation GitHub.
3. **Rotater** : nouvelle valeur au coffre, mise à jour de l'Environment Secret, JAMAIS dans un fichier/commit/log.
4. **Balayer** : scan de l'historique Git et des logs CI pour la valeur compromise (si elle a touché l'historique : la valeur est morte À JAMAIS, on ne « nettoie » pas l'histoire — on révoque, l'histoire publiée ne se réécrit pas).
5. **Inspecter** : Journal probant + Relevés d'accès (F5.3) sur la fenêtre d'exposition ; toute écriture suspecte est traitée en incident de vérité (P0).
6. **Redémarrer** : ré-activer les déploiements ; redéployer avec les nouvelles valeurs ; instances NEUVES (R-4 — on ne « répare » pas une instance, on en fait naître).
7. **Post-mortem blameless ≤ 5 jours** (Handbook §9) ; leçon au catalogue.

**Cas particuliers** : fuite `MENTORA_AGREEMENT_DATABASE_URL` prod = étapes 1-2 en parallèle + gel des retraits (Economy, quand il existera) ; compromission d'un COMPTE GitHub = retrait immédiat de l'org (`gh api -X DELETE orgs/MentoraOS/members/<login>`), audit des actions du compte, rotation de TOUT ce qu'il pouvait lire ; compromission GitHub org = basculer le dépôt en lecture seule (archive temporaire) + appui sur le clone local canonique du CTO.

## 8. Futures Foundations — qui consommera quoi

| Foundation | Environments | Secrets | Variables | OIDC | Actions |
|---|---|---|---|---|---|
| **R5 Integration** | `development` actif (CI) | `MENTORA_AGREEMENT_DATABASE_URL` (test) ; SENTRY si ADR observabilité | `APP_NAME`, `APP_ENV`, `LOG_LEVEL` | non | **premiers workflows** : la gate (typecheck/lint/test/build) devient les checks requis du Lot 3 |
| **R6 Experience** | `staging` s'active (previews) | VERCEL_* si ADR ; JWT_* à l'I&A servie | `API_URL`, `WEB_URL`, langues | tokens marqués « à migrer » | deploy des surfaces |
| **R7 Domain Expansion** | inchangés | OPENAI/ANTHROPIC si ADR gateway (Augmentation) | — | non | évals IA en CI |
| **R8 Prod Split & Fleet** | `production` s'active réellement | secrets prod par environment ; **vault** = source, GitHub = copie de déploiement minimale | prod | **OUI — bascule OIDC obligatoire** | déploiements cloud fédérés |
| **R9 Data** | inchangés | credentials entrepôt (ADR) | — | oui | pipelines |

## 9. Commandes prêtes à exécuter (après `gh auth login`, après Lots 2-3)

```bash
# ---------- 0. AUDIT AUTHENTIFIÉ (obligatoire)
gh api repos/MentoraOS/mentora/environments --jq '.environments[].name' 2>/dev/null   # attendu: vide
gh secret list --repo MentoraOS/mentora                                                # attendu: vide
gh variable list --repo MentoraOS/mentora                                              # attendu: vide
gh api repos/MentoraOS/mentora/actions/permissions --jq '.'                            # permissions workflows

# ---------- 1. LES 3 ENVIRONMENTS
gh api -X PUT repos/MentoraOS/mentora/environments/development --input - <<'JSON'
{ "deployment_branch_policy": { "protected_branches": false, "custom_branch_policies": true } }
JSON
gh api -X POST repos/MentoraOS/mentora/environments/development/deployment-branch-policies -f name='develop'
gh api -X POST repos/MentoraOS/mentora/environments/development/deployment-branch-policies -f name='feature/*'

gh api -X PUT repos/MentoraOS/mentora/environments/staging --input - <<'JSON'
{ "deployment_branch_policy": { "protected_branches": false, "custom_branch_policies": true } }
JSON
gh api -X POST repos/MentoraOS/mentora/environments/staging/deployment-branch-policies -f name='release/*'
gh api -X POST repos/MentoraOS/mentora/environments/staging/deployment-branch-policies -f name='release'

# production : reviewers OBLIGATOIRES + wait timer 10 min + main seule
# (remplacer TEAM_ID_PLATFORM / TEAM_ID_SECURITY par les ids issus de:  gh api orgs/MentoraOS/teams/<slug> --jq .id)
gh api -X PUT repos/MentoraOS/mentora/environments/production --input - <<'JSON'
{ "wait_timer": 10,
  "reviewers": [ { "type": "Team", "id": TEAM_ID_PLATFORM }, { "type": "Team", "id": TEAM_ID_SECURITY } ],
  "deployment_branch_policy": { "protected_branches": true, "custom_branch_policies": false } }
JSON

# ---------- 2. VARIABLES initiales (non-secrètes ; valeurs à fournir PAR LE CTO à l'exécution)
gh variable set APP_NAME  --repo MentoraOS/mentora --body 'Mentora'
gh variable set APP_ENV   --env development --repo MentoraOS/mentora --body 'development'
gh variable set APP_ENV   --env staging     --repo MentoraOS/mentora --body 'staging'
gh variable set APP_ENV   --env production  --repo MentoraOS/mentora --body 'production'
gh variable set LOG_LEVEL --env development --repo MentoraOS/mentora --body 'debug'
gh variable set LOG_LEVEL --env production  --repo MentoraOS/mentora --body 'info'

# ---------- 3. LE SEUL SECRET LÉGITIME AUJOURD'HUI (valeur saisie par le CTO, jamais écrite ailleurs)
gh secret set MENTORA_AGREEMENT_DATABASE_URL --env development --repo MentoraOS/mentora
#   (invite interactive — la valeur = l'URL de la base de TEST jetable, criticité ⚪ en dev)

# ---------- 4. VÉRIFICATION FINALE
gh api repos/MentoraOS/mentora/environments --jq '.environments[] | .name'
gh secret list --repo MentoraOS/mentora --env development
gh variable list --repo MentoraOS/mentora
```

---

*Aucun Environment, Secret ni Variable n'existe du fait de ce lot et aucun n'est prétendu exister. Aucune valeur secrète ne figure dans ce document ni dans aucun autre fichier du dépôt — et cela restera vrai pour toujours (I-8).*

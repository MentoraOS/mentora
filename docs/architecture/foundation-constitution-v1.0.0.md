# Foundation Constitution v1.0.0

> Ce document énonce les règles permanentes de la Foundation de Mentora.
> Il ne décrit pas la Foundation : il énonce ce qui ne changera pas.
>
> Filiation : mentora-expert-platform-v2.md → MES → Design System →
> Flutter Design Kit → Foundation. En cas de conflit, l'ordre de
> préséance du corpus prévaut ; ce document gouverne le gel et les
> conditions de toute évolution future de la Foundation.

Statut : **GELÉE** — baseline `foundation-v1.0.0`.

---

## 1. Architecture

- **Une responsabilité = un propriétaire.** Toute chose est possédée par
  exactement une voix ; ce que deux voix se partageraient appartient à
  une fondation, une fois.
- **Une voix = une question.** Chaque objet de la Foundation répond à
  une question et à une seule ; il ne répond jamais à la place d'une
  autre voix.
- **Une vérité = une voix.** Une vérité n'est jamais déclarée deux
  fois ; les mots qu'une forme ajoute sont des alias sur l'unique
  détenteur, jamais des seconds champs.
- **La Foundation exprime. Le produit décide.** Aucune voix de la
  Foundation ne calcule, ne choisit, n'ordonne, ne filtre, ne retient,
  n'interprète : elle exprime ce qui fut annoncé, en entier, toujours.
- **Les registres sont fermés.** Une forme, une voix, un vocabulaire
  n'apparaissent que par extension délibérée d'un registre fermé —
  jamais par décision locale d'un écran.
- **Un layout est un écran entier.** Il n'est jamais placé dans un
  autre ; l'assemblée unique est le seul chemin d'une forme vers un
  écran.

## 2. Réductions

- **Extraction au deuxième utilisateur.** Une fondation ne s'extrait
  que lorsqu'une véritable machinerie est partagée par un second
  utilisateur réel. Jamais avant. Jamais pour un motif.
- **Motif ≠ machinerie.** La ressemblance des formes n'est pas un corps
  commun : les voix par domaine — leurs mots, leurs refus — sont de la
  substance, et ne se généralisent pas.
- **Aucune abstraction prématurée.** Aucune abstraction vaut mieux
  qu'une mauvaise abstraction.
- **Aucune réduction reportée.** Une réduction démontrée s'exécute
  avant la vague qui l'a révélée ; elle ne s'empile pas.

## 3. Dépendances

- **DAG uniquement.** Le graphe des imports de la Foundation est un
  graphe orienté sans cycle, en couches strictement descendantes :
  tokens → registres et moteurs → composants → compositions →
  structures → layouts.
- **Aucun cycle.** Aucune couche ne remonte ; aucune fondation fermée
  n'importe une autre fondation fermée.
- **Aucun couplage transversal.** Un pont entre fondations est public,
  déclaré et unidirectionnel — jamais implicite, jamais réciproque. Les
  balayages d'isolement interdisent jusqu'au fait de *nommer* une voix
  qui n'est pas la sienne.

## 4. Objets

- **Immuables.** Tout champ est `final` ; un fait énoncé ne bouge plus.
- **`const`.** Toute voix est constructible en constante et se
  canonicalise par le compilateur.
- **`==` et `hashCode`.** Toute voix-valeur définit l'égalité par ses
  faits, et son empreinte avec elle.
- **Canonicalisation lorsque pertinente.** Les rassemblements —
  registres, graphes, magasins — portent la sémantique d'identité :
  déclarés une fois, comme la topologie, ils ne définissent pas
  d'égalité de valeur.
- **Aucune valeur non typée.** Ni `dynamic`, ni `Object?`, ni champ
  affaibli : le compilateur porte les contrats que l'exécution n'aura
  pas à rattraper.

## 5. Refus

- **Fail closed.** Ce qui n'honore pas son contrat refuse de se
  construire ; rien ne se résout par défaut, rien ne se devine.
- **Un refus = une voix.** Chaque refus appartient à exactement un
  propriétaire, et il est vérifié par son message, dans la voix de ce
  propriétaire.
- **Aucun refus partagé.** Ce que toute forme d'une famille refuse est
  refusé une fois, dans la fondation, et ne peut être contourné ; une
  spécialisation n'ajoute que ce qu'elle refuse en propre.
- **Le compilateur d'abord.** Ce qu'un type peut interdire n'est jamais
  confié à une vérification d'exécution.

## 6. Gouvernance

- **Toute évolution future consomme la Foundation.** Les écrans, les
  produits et les plateformes se construisent sur les voix gelées ; ils
  n'en créent pas de parallèles.
- **Une fondation gelée ne se modifie que sur erreur architecturale
  démontrable.** Ni goût, ni confort, ni opportunité : une preuve — et
  la correction s'accompagne de la mise à jour des balayages qui
  auraient dû la rendre impossible.
- **Les balayages sont la loi exécutable.** Tout invariant de ce
  document existe sous forme de scan structurel — jamais lexical — et
  la suite complète le re-prouve à chaque exécution. Un balayage ne
  s'assouplit pas ; un ensemble exact s'étend par acte délibéré du
  Design System.
- **Le catalogue vivant est obligatoire.** Toute forme et tout
  composant de la Foundation est présenté, documenté et vérifiable dans
  le laboratoire interne, construit avec les voix officielles
  elles-mêmes.

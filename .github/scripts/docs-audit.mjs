// MentoraOS — docs-audit (R5 Phase 2, Lot 4)
//
// Le vérificateur documentaire officiel : ZÉRO dépendance (node builtins
// seulement), le même outil en local et en CI. Il ne modifie jamais la
// documentation — il démontre qu'elle est cohérente.
//
// Vérifie, pour tout Markdown du dépôt (hors artefacts) :
//   - les liens relatifs (fichiers cibles existants)
//   - les images référencées
//   - les ancres internes (#...) et inter-fichiers (file.md#...)
// Ignore les blocs de code (fences) et le code inline — jamais de faux
// positif sur un exemple. Les URLs externes (http/https/mailto) sont HORS
// périmètre : les vérifier rendrait la gate dépendante du réseau tiers.
//
// Sortie : docs-report.json (le rapport documentaire officiel) + code de
// sortie. Politique d'échec : liens/fichiers/images cassés = ÉCHEC ;
// ancres invalides = ÉCHEC ; canon modifié sans autorisation = ÉCHEC
// (l'état du canon arrive par variables d'environnement, calculé par le
// workflow qui, lui, voit la PR).

import {
  readFileSync,
  readdirSync,
  statSync,
  existsSync,
  writeFileSync,
} from "node:fs";
import { join, dirname, resolve, relative, sep } from "node:path";

const ROOT = resolve(process.argv[2] ?? ".");
const SKIP_DIRS = new Set([
  "node_modules",
  "dist",
  ".turbo",
  ".git",
  "build",
  ".dart_tool",
  ".idea",
  ".claude",
  "release-out",
  "ephemeral", // artefacts générés Flutter (plugin symlinks) — gitignorés, docs de fournisseurs
]);

// ---------- collecte des fichiers Markdown
const mdFiles = [];
const walk = (dir) => {
  for (const entry of readdirSync(dir)) {
    if (SKIP_DIRS.has(entry)) continue;
    const full = join(dir, entry);
    let st;
    try {
      st = statSync(full);
    } catch {
      continue; // liens/chemins illisibles : hors périmètre
    }
    if (st.isDirectory()) walk(full);
    else if (entry.toLowerCase().endsWith(".md")) mdFiles.push(full);
  }
};
walk(ROOT);

// ---------- neutralisation des blocs de code (fences + inline)
const stripCode = (text) => {
  const lines = text.split("\n");
  let inFence = false;
  const kept = lines.map((line) => {
    const fence = /^\s*(```|~~~)/.test(line);
    if (fence) {
      inFence = !inFence;
      return "";
    }
    if (inFence) return "";
    return line.replace(/`[^`]*`/g, ""); // code inline
  });
  return kept.join("\n");
};

// ---------- slugs d'ancres façon GitHub (approximation fidèle : minuscules,
// ponctuation retirée, espaces → tirets, doublons suffixés -1, -2…)
const slugify = (heading) => {
  return heading
    .trim()
    .toLowerCase()
    .replace(/[*_`~]/g, "")
    .replace(/\[([^\]]*)\]\([^)]*\)/g, "$1") // liens dans les titres
    .replace(/[^\p{L}\p{N}\s_-]/gu, "")
    .replace(/\s/g, "-");
};

const anchorsOf = new Map(); // fichier -> Set(slugs)
for (const file of mdFiles) {
  const text = stripCode(readFileSync(file, "utf8"));
  const slugs = new Set();
  const counts = new Map();
  for (const m of text.matchAll(/^#{1,6}\s+(.+?)\s*#*\s*$/gm)) {
    const base = slugify(m[1]);
    const n = counts.get(base) ?? 0;
    counts.set(base, n + 1);
    slugs.add(n === 0 ? base : `${base}-${n}`);
  }
  // ancres HTML explicites <a id="..."> / name="..."
  for (const m of text.matchAll(/<a\s+(?:id|name)="([^"]+)"/g)) slugs.add(m[1]);
  anchorsOf.set(file, slugs);
}

// ---------- vérification des références
const brokenLinks = [];
const missingImages = [];
const invalidAnchors = [];
let totalLinks = 0;
let totalImages = 0;

const rel = (p) => relative(ROOT, p).split(sep).join("/");

for (const file of mdFiles) {
  const text = stripCode(readFileSync(file, "utf8"));
  const refs = [
    ...[...text.matchAll(/(!?)\[[^\]]*\]\(([^)\s]+)(?:\s+"[^"]*")?\)/g)].map(
      (m) => ({
        image: m[1] === "!",
        target: m[2],
      }),
    ),
  ];
  for (const { image, target } of refs) {
    if (/^(https?:|mailto:|tel:)/i.test(target)) continue; // externes : hors périmètre (réseau tiers)
    const [pathPart, anchorPart] = target.split("#");
    if (image) totalImages += 1;
    else totalLinks += 1;

    let targetFile = file;
    if (pathPart !== "") {
      const decoded = decodeURIComponent(pathPart);
      targetFile = resolve(dirname(file), decoded);
      if (!existsSync(targetFile)) {
        (image ? missingImages : brokenLinks).push(`${rel(file)} -> ${target}`);
        continue;
      }
    }
    if (
      anchorPart !== undefined &&
      anchorPart !== "" &&
      targetFile.toLowerCase().endsWith(".md")
    ) {
      const known = anchorsOf.get(resolve(targetFile));
      if (known !== undefined && !known.has(anchorPart.toLowerCase())) {
        invalidAnchors.push(`${rel(file)} -> ${target}`);
      }
    }
  }
}

// ---------- état du canon (calculé par le workflow, transmis en env)
const canonChangedFiles = (process.env.DOCS_CANON_CHANGED ?? "")
  .split("\n")
  .map((l) => l.trim())
  .filter((l) => l !== "");
const canonAuthorized = process.env.DOCS_CANON_AUTHORIZED === "true";
const canonViolation = canonChangedFiles.length > 0 && !canonAuthorized;

// ---------- rapport officiel
const failed =
  brokenLinks.length > 0 ||
  missingImages.length > 0 ||
  invalidAnchors.length > 0 ||
  canonViolation;

const report = {
  generatedAt: new Date().toISOString(),
  markdownFiles: mdFiles.length,
  links: totalLinks,
  images: totalImages,
  brokenLinks,
  missingImages,
  invalidAnchors,
  canon: {
    changedFiles: canonChangedFiles,
    authorized: canonChangedFiles.length > 0 ? canonAuthorized : null,
    violation: canonViolation,
  },
  result: failed ? "FAIL" : "PASS",
};

writeFileSync(
  join(ROOT, "docs-report.json"),
  JSON.stringify(report, null, 2) + "\n",
);

console.log(
  `docs-audit — ${report.markdownFiles} fichiers, ${report.links} liens, ${report.images} images | ` +
    `cassés: ${brokenLinks.length}, images manquantes: ${missingImages.length}, ancres invalides: ${invalidAnchors.length} | ` +
    `canon: ${canonChangedFiles.length} modifié(s), autorisé: ${report.canon.authorized} | ${report.result}`,
);
for (const b of brokenLinks) console.log("  LIEN CASSÉ    : " + b);
for (const b of missingImages) console.log("  IMAGE ABSENTE : " + b);
for (const b of invalidAnchors) console.log("  ANCRE INVALIDE: " + b);
if (canonViolation) {
  console.log("  CANON MODIFIÉ SANS AUTORISATION TITRE VII :");
  for (const f of canonChangedFiles) console.log("    - " + f);
}

process.exit(failed ? 1 : 0);

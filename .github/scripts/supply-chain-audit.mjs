// MentoraOS — supply-chain-audit (R5 Phase 2, Lot 5)
//
// L'inventaire outillé de la chaîne d'approvisionnement : ZÉRO dépendance
// (builtins Node), le même outil en local et en CI. Il ne met rien à
// jour — il PROUVE l'état : composants épinglés, non épinglés, versions,
// mises à jour disponibles (si fournies), niveau de risque.
//
// Sortie : supply-chain-report.json. Politique : une action GitHub non
// épinglée par SHA = FAIL (la loi du Lot 5 CI/CD) ; le reste informe.

import { readFileSync, readdirSync, existsSync, writeFileSync } from "node:fs";
import { join, resolve } from "node:path";

const ROOT = resolve(process.argv[2] ?? ".");

// ---------- actions GitHub : épinglage SHA obligatoire
const workflowsDir = join(ROOT, ".github/workflows");
const pinnedActions = [];
const unpinnedActions = [];
for (const f of existsSync(workflowsDir) ? readdirSync(workflowsDir) : []) {
  if (!/\.ya?ml$/.test(f)) continue;
  const text = readFileSync(join(workflowsDir, f), "utf8");
  for (const m of text.matchAll(/uses:\s*([^\s#]+)/g)) {
    const ref = m[1];
    const entry = `${f}: ${ref}`;
    if (/@[0-9a-f]{40}$/.test(ref)) pinnedActions.push(entry);
    else unpinnedActions.push(entry);
  }
}

// ---------- images docker : workflows + compose (tag vs digest)
const dockerImages = [];
const scanImages = (file, label) => {
  if (!existsSync(file)) return;
  const text = readFileSync(file, "utf8");
  for (const m of text.matchAll(/image:\s*([^\s#]+)/g)) {
    dockerImages.push({
      source: label,
      image: m[1],
      digestPinned: m[1].includes("@sha256:"),
    });
  }
};
for (const f of existsSync(workflowsDir) ? readdirSync(workflowsDir) : []) {
  if (/\.ya?ml$/.test(f))
    scanImages(join(workflowsDir, f), `.github/workflows/${f}`);
}
scanImages(
  join(ROOT, "platform/infra/docker-compose.dev.yml"),
  "platform/infra/docker-compose.dev.yml",
);

// ---------- toolchain épinglée
const readJson = (p) => JSON.parse(readFileSync(join(ROOT, p), "utf8"));
const rootPkg = readJson("platform/package.json");
const adaptersPkg = readJson(
  "platform/packages/adapters-persistence-agreement/package.json",
);
const nvmrc = readFileSync(join(ROOT, "platform/.nvmrc"), "utf8").trim();
const workflowText = (existsSync(workflowsDir) ? readdirSync(workflowsDir) : [])
  .filter((f) => /\.ya?ml$/.test(f))
  .map((f) => readFileSync(join(workflowsDir, f), "utf8"))
  .join("\n");
const corepackPin = workflowText.match(/corepack@(\d+\.\d+\.\d+)/)?.[1] ?? null;
const syftPin = workflowText.match(/SYFT_VERSION:\s*(\S+)/)?.[1] ?? null;

// ---------- catalog pnpm (source unique des versions partagées)
const workspaceYaml = readFileSync(
  join(ROOT, "platform/pnpm-workspace.yaml"),
  "utf8",
);
const catalog = {};
const catalogBlock = workspaceYaml.match(/catalog:\n((?:\s{2}[^\n]+\n)+)/);
if (catalogBlock) {
  for (const line of catalogBlock[1].split("\n")) {
    const m = line.match(/^\s{2}["']?([^"':]+)["']?:\s*(\S+)/);
    if (m) catalog[m[1]] = m[2];
  }
}

// ---------- dépendances critiques (les fondations de la toolchain)
const critical = {
  node: nvmrc,
  pnpm: rootPkg.packageManager ?? null,
  corepack: corepackPin,
  turbo: rootPkg.devDependencies?.turbo ?? null,
  typescript: catalog.typescript ?? null,
  prisma: adaptersPkg.devDependencies?.prisma ?? null,
  "@prisma/client": adaptersPkg.dependencies?.["@prisma/client"] ?? null,
  eslint: catalog.eslint ?? null,
  vitest: catalog.vitest ?? null,
  prettier: catalog.prettier ?? null,
  syft: syftPin,
};

// ---------- mises à jour disponibles (fournies par la CI via pnpm outdated,
// fichier optionnel — l'audit reste utilisable hors ligne)
let updatesAvailable = null;
const outdatedPath = join(ROOT, "outdated.json");
if (existsSync(outdatedPath)) {
  try {
    const raw = JSON.parse(readFileSync(outdatedPath, "utf8"));
    updatesAvailable = Object.entries(raw).map(([name, info]) => ({
      name,
      current: info.current ?? null,
      latest: info.latest ?? null,
    }));
  } catch {
    updatesAvailable = "unreadable";
  }
}

// ---------- risque & verdict
const unpinnedDocker = dockerImages.filter((d) => !d.digestPinned);
const failed = unpinnedActions.length > 0; // la seule loi bloquante de ce rapport
const risk = failed ? "HIGH" : unpinnedDocker.length > 0 ? "MEDIUM" : "LOW";

const report = {
  generatedAt: new Date().toISOString(),
  criticalDependencies: critical,
  catalog,
  actions: { pinned: pinnedActions, unpinned: unpinnedActions },
  dockerImages,
  pinnedComponents: {
    node: true,
    pnpm: rootPkg.packageManager != null,
    corepack: corepackPin != null,
    syft: syftPin != null,
    actionsBySha: unpinnedActions.length === 0,
  },
  unpinnedComponents: {
    dockerImagesByDigest: unpinnedDocker.map((d) => `${d.source}: ${d.image}`),
  },
  updatesAvailable,
  riskLevel: risk,
  result: failed ? "FAIL" : "PASS",
};

writeFileSync(
  join(ROOT, "supply-chain-report.json"),
  JSON.stringify(report, null, 2) + "\n",
);

console.log(
  `supply-chain-audit — actions: ${pinnedActions.length} épinglées / ${unpinnedActions.length} NON épinglées | ` +
    `docker: ${dockerImages.length} images (${unpinnedDocker.length} sans digest) | ` +
    `maj dispo: ${Array.isArray(updatesAvailable) ? updatesAvailable.length : "non calculées"} | risque: ${risk} | ${report.result}`,
);
for (const u of unpinnedActions) console.log("  ACTION NON ÉPINGLÉE: " + u);

process.exit(failed ? 1 : 0);

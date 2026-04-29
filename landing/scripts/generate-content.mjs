#!/usr/bin/env node
import { execFileSync } from "node:child_process";
import { readdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, relative } from "node:path";
import { fileURLToPath } from "node:url";

const scriptDir = dirname(fileURLToPath(import.meta.url));
const landingRoot = join(scriptDir, "..");
const repoRoot = join(landingRoot, "..");
const docsRoot = join(repoRoot, "docs");
const outFile = join(landingRoot, "data/prism-content.json");

/**
 * Walks the local Mintlify docs tree and returns every MDX document path.
 *
 * @param {string} directory - Absolute directory to scan.
 * @returns {string[]} Absolute MDX file paths.
 *
 * @example
 * const docs = collectMdxFiles("/repo/docs");
 */
function collectMdxFiles(directory) {
  return readdirSync(directory, { withFileTypes: true }).flatMap((entry) => {
    const path = join(directory, entry.name);
    if (entry.isDirectory()) return collectMdxFiles(path);
    return entry.isFile() && entry.name.endsWith(".mdx") ? [path] : [];
  });
}

/**
 * Extracts frontmatter title and description so landing copy stays tied to docs.
 *
 * @param {string} source - Raw MDX document.
 * @returns {{title: string, description: string}} Parsed metadata.
 *
 * @example
 * const meta = parseFrontmatter("---\\ntitle: Intro\\n---");
 */
function parseFrontmatter(source) {
  const block = source.match(/^---\n([\s\S]*?)\n---/);
  const title = block?.[1].match(/^title:\s*"?(.+?)"?$/m)?.[1] ?? "Untitled";
  const description = block?.[1].match(/^description:\s*"?(.+?)"?$/m)?.[1] ?? "";
  return { title, description };
}

/**
 * Runs a git command without shell interpolation for predictable release metadata.
 *
 * @param {string[]} args - Arguments passed to git.
 * @param {string} fallback - Value used when git metadata is unavailable.
 * @returns {string} Trimmed git output.
 *
 * @example
 * const shortSha = git(["rev-parse", "--short", "HEAD"], "unknown");
 */
function git(args, fallback) {
  try {
    return execFileSync("git", args, { cwd: repoRoot, encoding: "utf8" }).trim();
  } catch {
    return fallback;
  }
}

const docs = collectMdxFiles(docsRoot)
  .map((file) => {
    const source = readFileSync(file, "utf8");
    const meta = parseFrontmatter(source);
    const slug = relative(docsRoot, file).replace(/\.mdx$/, "");
    return {
      slug,
      url: `https://docs.prism.byescaleira.com/${slug}`,
      ...meta,
    };
  })
  .sort((a, b) => a.slug.localeCompare(b.slug));

const mint = JSON.parse(readFileSync(join(repoRoot, "docs/mint.json"), "utf8"));
const changelog = readFileSync(join(repoRoot, "CHANGELOG.md"), "utf8");
const latestRelease = changelog.match(/^## \[([^\]]+)\] - ([0-9-]+)/m);
const latestVersion = latestRelease?.[1] ?? "Unreleased";
const latestDate = latestRelease?.[2] ?? null;

const payload = {
  generatedAt: new Date().toISOString(),
  source: {
    docsUrl: "https://docs.prism.byescaleira.com",
    docsCount: docs.length,
    commit: git(["rev-parse", "--short", "HEAD"], "unknown"),
    branch: git(["branch", "--show-current"], "unknown"),
    latestTag: git(["describe", "--tags", "--abbrev=0"], "none"),
    latestVersion,
    latestDate,
  },
  navigationGroups: mint.navigation.map((group) => ({
    group: group.group,
    count: group.pages.length,
  })),
  docs,
};

writeFileSync(outFile, `${JSON.stringify(payload, null, 2)}\n`);
console.log(`Landing data generated: ${outFile}`);

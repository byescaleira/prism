const modules = [
  {
    name: "Server",
    kind: "PrismServer",
    accent: "#2EF3D0",
    count: 36,
    description:
      "HTTP server, routing, database, GraphQL, MCP, WebSocket rooms, middleware, cron, background tasks, cluster mode, and production infrastructure.",
    features: ["Routing", "Middleware", "Database", "GraphQL", "MCP", "WebSocket Rooms", "SSE", "Cron"],
  },
  {
    name: "UI",
    kind: "PrismUI",
    accent: "#2EF3D0",
    count: 100,
    description:
      "SwiftUI components, design tokens, theming, charts, forms, accessibility tools, animations, and developer experience utilities.",
    features: ["Tokens", "Themes", "Forms", "Charts", "A11y", "Animations", "DevTools", "Snapshots"],
  },
  {
    name: "Architecture",
    kind: "PrismArchitecture",
    accent: "#2EF3D0",
    count: 18,
    description:
      "Composable state management with stores, reducers, effects, middleware, type-safe routing, persistence, time travel, and undo/redo.",
    features: ["Store", "Reducer", "Effects", "Middleware", "Router", "Time Travel", "Persistence", "Undo/Redo"],
  },
  {
    name: "Network",
    kind: "PrismNetwork",
    accent: "#2EF3D0",
    count: 19,
    description:
      "Type-safe HTTP client with endpoints, caching, retry policies, request deduplication, offline queue, multipart uploads, GraphQL, and WebSocket client.",
    features: ["HTTP Client", "Endpoints", "Retry", "Cache", "Offline Queue", "Uploads", "GraphQL", "WebSocket"],
  },
  {
    name: "Intelligence",
    kind: "PrismIntelligence",
    accent: "#2EF3D0",
    count: 16,
    description:
      "On-device ML, Apple Intelligence, NLP, RAG pipelines, vector embeddings, model lifecycle management, and structured output parsing.",
    features: ["CoreML", "CreateML", "Apple Intelligence", "NLP", "RAG", "Embeddings", "Vision", "Structured Output"],
  },
  {
    name: "Capabilities",
    kind: "PrismCapabilities",
    accent: "#2EF3D0",
    count: 27,
    description:
      "Native wrappers for StoreKit, HealthKit, CloudKit, Apple Pay, CallKit, CoreBluetooth, NFC, Camera, GameKit, Location, Motion, and biometrics.",
    features: ["StoreKit", "HealthKit", "CloudKit", "Apple Pay", "NFC", "Camera", "Location", "Biometrics"],
  },
  {
    name: "Video",
    kind: "PrismVideo",
    accent: "#2EF3D0",
    count: 11,
    description:
      "Video metadata, actor-based downloading, AsyncStream progress, resolution detection, and AVFoundation export helpers.",
    features: ["Metadata", "Downloader", "Progress", "Resolution", "AVFoundation", "Export", "Streaming", "Entities"],
  },
];

const tabList = document.querySelector(".module-tabs");
const moduleDetail = document.querySelector(".module-detail");
const featureList = document.querySelector(".feature-list");
const featureMatrix = document.querySelector(".feature-matrix");

/**
 * Renders one selectable module tab in the constellation lab.
 *
 * @param {{name: string, accent: string, count: number}} module - Module data.
 * @param {number} index - Position used by ARIA and default selection.
 * @returns {HTMLButtonElement} Interactive tab element.
 *
 * @example
 * createModuleTab(modules[0], 0);
 */
function createModuleTab(module, index) {
  const button = document.createElement("button");
  button.type = "button";
  button.role = "tab";
  button.id = `module-tab-${module.name.toLowerCase()}`;
  button.dataset.index = String(index);
  button.style.setProperty("--accent", module.accent);
  button.setAttribute("aria-selected", index === 0 ? "true" : "false");
  button.innerHTML = `<span>${module.name}</span><small>${module.count} features</small>`;
  button.addEventListener("click", () => selectModule(index));
  return button;
}

/**
 * Updates the detail panel without reloading the page so the section feels like a real product surface.
 *
 * @param {number} index - Selected module index.
 *
 * @example
 * selectModule(2);
 */
function selectModule(index) {
  const module = modules[index];
  document.querySelectorAll("[role='tab']").forEach((tab, tabIndex) => {
    tab.setAttribute("aria-selected", String(tabIndex === index));
  });
  moduleDetail.style.setProperty("--accent", module.accent);
  moduleDetail.querySelector(".module-kind").textContent = module.kind;
  moduleDetail.querySelector("h3").textContent = module.name;
  moduleDetail.querySelector("p:not(.module-kind)").textContent = module.description;
  featureList.replaceChildren(
    ...module.features.map((feature) => {
      const item = document.createElement("li");
      item.textContent = feature;
      return item;
    }),
  );
}

/**
 * Renders the module matrix from one shared data source to avoid marketing copy drifting from tabs.
 *
 * @returns {void}
 *
 * @example
 * renderFeatureMatrix();
 */
function renderFeatureMatrix() {
  featureMatrix.replaceChildren(
    ...modules.map((module) => {
      const card = document.createElement("article");
      card.style.setProperty("--accent", module.accent);
      card.innerHTML = `
        <h3>${module.name}</h3>
        <p>${module.description}</p>
        <ul>${module.features.slice(0, 5).map((item) => `<li>${item}</li>`).join("")}</ul>
        <strong>${module.count} documented capabilities</strong>
      `;
      return card;
    }),
  );
}

/**
 * Loads generated docs/git/release metadata so SEO-visible content tracks source docs and commits.
 *
 * @returns {Promise<void>}
 *
 * @example
 * await hydrateContentManifest();
 */
async function hydrateContentManifest() {
  try {
    const response = await fetch("/data/prism-content.json");
    const manifest = await response.json();
    document.querySelector("#doc-count").textContent = manifest.source.docsCount;
    document.querySelector("#sync-docs").textContent = `${manifest.source.docsCount} MDX pages`;
    document.querySelector("#sync-commit").textContent = manifest.source.commit;
    document.querySelector("#sync-version").textContent = manifest.source.latestVersion;
    document.querySelector("#sync-tag").textContent = manifest.source.latestTag;
  } catch (error) {
    console.warn("Unable to hydrate landing manifest", error);
  }
}

/**
 * Copies a code example and gives immediate accessible feedback.
 *
 * @param {HTMLButtonElement} button - Button with a data-copy target id.
 * @returns {Promise<void>}
 *
 * @example
 * await copyCode(document.querySelector("[data-copy='server-code']"));
 */
async function copyCode(button) {
  const target = document.getElementById(button.dataset.copy);
  await navigator.clipboard.writeText(target.innerText);
  const previous = button.textContent;
  button.textContent = "Copied";
  window.setTimeout(() => {
    button.textContent = previous;
  }, 1200);
}

/**
 * Adds scroll-based reveal states with IntersectionObserver for performant motion.
 *
 * @returns {void}
 *
 * @example
 * setupRevealMotion();
 */
function setupRevealMotion() {
  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) entry.target.classList.add("is-visible");
      });
    },
    { threshold: 0.16 },
  );
  document.querySelectorAll(".reveal").forEach((element) => observer.observe(element));
}

tabList.replaceChildren(...modules.map(createModuleTab));
selectModule(0);
renderFeatureMatrix();
setupRevealMotion();
hydrateContentManifest();

document.querySelectorAll("[data-copy]").forEach((button) => {
  button.addEventListener("click", () => copyCode(button));
});

document.addEventListener("pointermove", (event) => {
  document.documentElement.style.setProperty("--cursor-x", `${event.clientX}px`);
  document.documentElement.style.setProperty("--cursor-y", `${event.clientY}px`);
});

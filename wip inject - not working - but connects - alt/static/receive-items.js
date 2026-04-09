const queue = [];

const backendStatusEl = document.getElementById("backendStatus");
const gameStatusEl = document.getElementById("gameStatus");
const backpackStatusEl = document.getElementById("backpackStatus");
const queueCountEl = document.getElementById("queueCount");
const serialListEl = document.getElementById("serialList");
const logListEl = document.getElementById("logList");
const singleSerialEl = document.getElementById("singleSerial");
const batchSerialsEl = document.getElementById("batchSerials");

function addLog(message, tone = "neutral") {
  const entry = document.createElement("div");
  entry.className = `log-entry ${tone}`;
  entry.textContent = `[${new Date().toLocaleTimeString()}] ${message}`;
  logListEl.prepend(entry);
  while (logListEl.children.length > 16) {
    logListEl.removeChild(logListEl.lastChild);
  }
}

async function apiGet(path) {
  const response = await fetch(path, { cache: "no-store" });
  return response.json();
}

async function apiPost(path, payload = {}) {
  const response = await fetch(path, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
  return response.json();
}

function setStatusPill(element, text, tone) {
  element.textContent = text;
  element.classList.remove("good", "warn", "bad");
  if (tone) {
    element.classList.add(tone);
  }
}

function normalizeSerials(text) {
  return text
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter(Boolean);
}

function addSerials(serials) {
  let added = 0;
  let invalid = 0;

  serials.forEach((serial) => {
    if (!serial.startsWith("@U")) {
      invalid += 1;
      return;
    }
    if (queue.some((entry) => entry.serial === serial)) {
      return;
    }
    queue.push({ serial, selected: false, state: "queued" });
    added += 1;
  });

  renderQueue();
  if (added > 0) {
    addLog(`Added ${added} serial${added === 1 ? "" : "s"} to the queue.`, "good");
  }
  if (invalid > 0) {
    addLog(`Skipped ${invalid} invalid line${invalid === 1 ? "" : "s"} that did not start with @U.`, "warn");
  }
}

function renderQueue() {
  queueCountEl.textContent = `${queue.length} item${queue.length === 1 ? "" : "s"}`;

  if (queue.length === 0) {
    serialListEl.className = "serial-list empty-state";
    serialListEl.textContent = "No serials queued yet.";
    return;
  }

  serialListEl.className = "serial-list";
  serialListEl.replaceChildren();

  queue.forEach((entry, index) => {
    const row = document.createElement("div");
    row.className = "serial-row";

    const checkbox = document.createElement("input");
    checkbox.type = "checkbox";
    checkbox.checked = entry.selected;
    checkbox.addEventListener("change", () => {
      entry.selected = checkbox.checked;
    });

    const content = document.createElement("div");

    const meta = document.createElement("div");
    meta.className = "serial-meta";
    meta.innerHTML = `<span>Queue #${index + 1}</span><span>${entry.state}</span>`;

    const code = document.createElement("div");
    code.className = "serial-code";
    code.textContent = entry.serial;

    content.append(meta, code);

    const tag = document.createElement("div");
    tag.className = "row-tag";
    tag.textContent = entry.state;

    row.append(checkbox, content, tag);
    serialListEl.appendChild(row);
  });
}

async function refreshStatus() {
  try {
    const status = await apiGet("/api/status");
    setStatusPill(backendStatusEl, "Backend: online", "good");

    if (!status.connected) {
      setStatusPill(gameStatusEl, "Game: not attached", "warn");
    } else if (!status.gengine) {
      setStatusPill(gameStatusEl, "Game: attached, GEngine missing", "warn");
    } else if (!status.backpack_ready) {
      setStatusPill(gameStatusEl, "Game: attached, backpack not ready", "warn");
    } else {
      setStatusPill(gameStatusEl, "Game: backpack ready", "good");
    }

    if (status.backpack_ready) {
      const count = status.backpack_count ?? "?";
      const max = status.backpack_max ?? "?";
      const maxSize = status.backpack_max_size ?? "?";
      const tone = typeof count === "number" && count >= 200 ? "warn" : "good";
      setStatusPill(backpackStatusEl, `Backpack: ${count}/${max} (max size ${maxSize})`, tone);
    } else {
      setStatusPill(backpackStatusEl, "Backpack: unavailable", "warn");
    }
  } catch (error) {
    setStatusPill(backendStatusEl, "Backend: offline", "bad");
    setStatusPill(gameStatusEl, "Game: unknown", "bad");
    setStatusPill(backpackStatusEl, "Backpack: unknown", "bad");
  }
}

async function attachToGame() {
  addLog("Attempting to attach to Borderlands 4...");
  const result = await apiPost("/api/attach");
  if (result.ok) {
    addLog("Attach succeeded.", "good");
  } else {
    addLog(result.error || "Attach failed.", "bad");
  }
  await refreshStatus();
}

function getSelectedIndexes() {
  return queue
    .map((entry, index) => ({ entry, index }))
    .filter(({ entry }) => entry.selected)
    .map(({ index }) => index);
}

async function injectSelected() {
  const selected = getSelectedIndexes();
  if (selected.length !== 1) {
    addLog("Select exactly one serial to use Inject Selected.", "warn");
    return;
  }

  const entry = queue[selected[0]];
  const result = await apiPost("/api/inject", { serial: entry.serial });
  if (result.ok) {
    entry.state = `injected to slot ${result.slot}`;
    addLog(result.message || "Serial injected.", "good");
  } else {
    entry.state = "failed";
    addLog(result.error || "Inject failed.", "bad");
  }
  renderQueue();
  await refreshStatus();
}

async function injectAll() {
  if (queue.length === 0) {
    addLog("Queue is empty.", "warn");
    return;
  }

  const serials = queue.map((entry) => entry.serial);
  const result = await apiPost("/api/batch-inject", { serials });
  if (result.ok) {
    queue.forEach((entry, index) => {
      entry.state = index < result.injected ? "injected" : "not injected";
    });
    addLog(result.message || "Batch inject complete.", "good");
  } else {
    addLog(result.error || "Batch inject failed.", "bad");
  }
  renderQueue();
  await refreshStatus();
}

function deleteSelected() {
  const selected = getSelectedIndexes();
  if (selected.length === 0) {
    addLog("No queued serials selected.", "warn");
    return;
  }
  selected
    .sort((a, b) => b - a)
    .forEach((index) => queue.splice(index, 1));
  renderQueue();
  addLog(`Deleted ${selected.length} queued serial${selected.length === 1 ? "" : "s"}.`);
}

function clearQueue() {
  queue.length = 0;
  renderQueue();
  addLog("Cleared queued serials.");
}

document.getElementById("addSingleButton").addEventListener("click", () => {
  const value = singleSerialEl.value.trim();
  if (!value) {
    addLog("Enter a serial before clicking Add.", "warn");
    return;
  }
  addSerials([value]);
  singleSerialEl.value = "";
});

document.getElementById("addBatchButton").addEventListener("click", () => {
  const lines = normalizeSerials(batchSerialsEl.value);
  if (lines.length === 0) {
    addLog("Paste at least one serial line first.", "warn");
    return;
  }
  addSerials(lines);
  batchSerialsEl.value = "";
});

document.getElementById("deleteSelectedButton").addEventListener("click", deleteSelected);
document.getElementById("clearQueueButton").addEventListener("click", clearQueue);
document.getElementById("attachButton").addEventListener("click", attachToGame);
document.getElementById("injectSelectedButton").addEventListener("click", injectSelected);
document.getElementById("injectAllButton").addEventListener("click", injectAll);
document.getElementById("refreshStatusButton").addEventListener("click", refreshStatus);

renderQueue();
refreshStatus();
setInterval(refreshStatus, 4000);

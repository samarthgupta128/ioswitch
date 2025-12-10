// DOM elements
const domainListEl = document.getElementById("domainList");
const newDomainInput = document.getElementById("newDomain");
const addBtn = document.getElementById("addBtn");
const statusEl = document.getElementById("status");
const nativeWarningEl = document.getElementById("nativeWarning");

// Current list of domains
let domains = [];

// Load domains from storage
function loadDomains() {
  browser.storage.local.get("redirectDomains").then((result) => {
    domains = result.redirectDomains || ["x.ai", "grok.com"];
    renderDomains();
  });
}

// Save domains to storage
function saveDomains() {
  browser.storage.local.set({ redirectDomains: domains }).then(() => {
    showStatus("Settings saved!", "success");
  });
}

// Render the domain list
function renderDomains() {
  domainListEl.innerHTML = "";

  domains.forEach((domain, index) => {
    const item = document.createElement("div");
    item.className = "domain-item";

    const nameSpan = document.createElement("span");
    nameSpan.className = "domain-name";
    nameSpan.textContent = domain;

    const removeBtn = document.createElement("button");
    removeBtn.textContent = "Remove";
    removeBtn.addEventListener("click", () => removeDomain(index));

    item.appendChild(nameSpan);
    item.appendChild(removeBtn);
    domainListEl.appendChild(item);
  });
}

// Add a new domain
function addDomain() {
  let domain = newDomainInput.value.trim().toLowerCase();

  // Remove protocol if present
  domain = domain.replace(/^https?:\/\//, "");
  // Remove www. prefix
  domain = domain.replace(/^www\./, "");
  // Remove trailing slash and path
  domain = domain.split("/")[0];

  if (!domain) {
    showStatus("Please enter a domain", "error");
    return;
  }

  // Basic domain validation
  if (!/^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,}$/i.test(domain)) {
    showStatus("Please enter a valid domain (e.g., x.ai)", "error");
    return;
  }

  if (domains.includes(domain)) {
    showStatus("Domain already in the list", "error");
    return;
  }

  domains.push(domain);
  saveDomains();
  renderDomains();
  newDomainInput.value = "";
}

// Remove a domain
function removeDomain(index) {
  domains.splice(index, 1);
  saveDomains();
  renderDomains();
}

// Show status message
function showStatus(message, type) {
  statusEl.textContent = message;
  statusEl.className = "status " + type;

  setTimeout(() => {
    statusEl.className = "status";
  }, 3000);
}

// Check if native messaging is working
function checkNativeMessaging() {
  browser.runtime
    .sendNativeMessage("ioswitch", { ping: true })
    .then(() => {
      nativeWarningEl.style.display = "none";
    })
    .catch(() => {
      nativeWarningEl.style.display = "block";
    });
}

// Event listeners
addBtn.addEventListener("click", addDomain);

newDomainInput.addEventListener("keypress", (e) => {
  if (e.key === "Enter") {
    addDomain();
  }
});

// Initialize
loadDomains();
checkNativeMessaging();

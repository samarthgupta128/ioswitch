// Default list of domains to redirect to external browser
let redirectDomains = ["x.ai", "grok.com"];

// Load saved domains from storage on startup
browser.storage.local.get("redirectDomains").then((result) => {
  if (result.redirectDomains && result.redirectDomains.length > 0) {
    redirectDomains = result.redirectDomains;
    console.log("Loaded redirect domains:", redirectDomains);
  } else {
    // Save default domains if none exist
    browser.storage.local.set({ redirectDomains: redirectDomains });
  }
});

// Listen for storage changes (when user updates domain list)
browser.storage.onChanged.addListener((changes, area) => {
  if (area === "local" && changes.redirectDomains) {
    redirectDomains = changes.redirectDomains.newValue;
    console.log("Updated redirect domains:", redirectDomains);
  }
});

// Check if a URL matches any of the redirect domains
function shouldRedirect(url) {
  try {
    const urlObj = new URL(url);
    const hostname = urlObj.hostname.toLowerCase();

    return redirectDomains.some((domain) => {
      const normalizedDomain = domain.toLowerCase().replace(/^www\./, "");
      const normalizedHostname = hostname.replace(/^www\./, "");
      return (
        normalizedHostname === normalizedDomain ||
        normalizedHostname.endsWith("." + normalizedDomain)
      );
    });
  } catch (e) {
    console.error("Error parsing URL:", e);
    return false;
  }
}

// Intercept web requests before they load
browser.webRequest.onBeforeRequest.addListener(
  function (details) {
    // Only handle main frame navigation (not iframes, images, scripts, etc.)
    if (details.type !== "main_frame") {
      return {};
    }

    // Check if this URL should be redirected
    if (shouldRedirect(details.url)) {
      console.log("Intercepting URL for external browser:", details.url);

      // Try to open in external browser via native messaging
      browser.runtime
        .sendNativeMessage("ioswitch", { url: details.url })
        .then(() => {
          console.log("Successfully sent URL to external browser:", details.url);
          // Close the tab after successful redirect
          browser.tabs.remove(details.tabId).catch(() => {});
        })
        .catch((error) => {
          console.error("Native messaging failed:", error);

          // Fallback: Show redirect page with manual instructions
          browser.tabs.update(details.tabId, {
            url:
              browser.runtime.getURL("redirect.html") +
              "?url=" +
              encodeURIComponent(details.url),
          });
        });

      // Block the original request in Firefox
      return { cancel: true };
    }

    return {};
  },
  { urls: ["<all_urls>"] },
  ["blocking"]
);

// Also handle when user types URL in address bar or clicks links
browser.webNavigation.onBeforeNavigate.addListener((details) => {
  // Only handle main frame
  if (details.frameId !== 0) {
    return;
  }

  if (shouldRedirect(details.url)) {
    console.log("Navigation intercepted:", details.url);
  }
});

console.log("IO Switch extension loaded. Redirecting domains:", redirectDomains);

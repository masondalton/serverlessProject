const API_BASE = window.APP_CONFIG.API_BASE;

async function loadBenders() {
  try {
    const res = await fetch(`${API_BASE}/benders`);
    const benders = await res.json();

    const container = document.getElementById("benders-list");
    container.innerHTML = "";

    benders.forEach((b) => {
      const div = document.createElement("div");
      div.className = "bender-card";
      div.textContent = `${b.name} — ${b.nation} (${b.elements.join(", ")})`;
      container.appendChild(div);
    });
  } catch (err) {
    console.error("Failed to load benders", err);
  }
}

document.addEventListener("DOMContentLoaded", loadBenders);

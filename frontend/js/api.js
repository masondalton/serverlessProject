(() => {
  const API_BASE = window.APP_CONFIG.API_BASE;

  async function request(path, { method = "GET", body, auth = false } = {}) {
    const headers = { "Content-Type": "application/json" };
    if (auth && window.Auth?.getIdToken()) {
      headers["Authorization"] = `Bearer ${window.Auth.getIdToken()}`;
    }

    const res = await fetch(`${API_BASE}${path}`, {
      method,
      headers,
      body: body ? JSON.stringify(body) : undefined
    });

    let data = null;
    try {
      data = await res.json();
    } catch {
      data = null;
    }

    if (!res.ok) {
      const msg = (data && data.error) ? data.error : res.statusText;
      throw new Error(msg);
    }

    return data;
  }

  async function listBenders() {
    return request("/benders");
  }

  async function upsertBender(bender) {
    return request("/admin/bender", { method: "PUT", body: bender, auth: true });
  }

  async function deleteBender(id) {
    return request(`/admin/bender/${encodeURIComponent(id)}`, { method: "DELETE", auth: true });
  }

  window.Api = {
    listBenders,
    upsertBender,
    deleteBender
  };
})();

(() => {
  const API_BASE = window.APP_CONFIG.API_BASE;

  async function request(path, { method = "GET", body, auth = false, query } = {}) {
    const headers = { "Content-Type": "application/json" };
    if (auth && window.Auth?.getIdToken()) {
      headers["Authorization"] = `Bearer ${window.Auth.getIdToken()}`;
    }

    const url = new URL(`${API_BASE}${path}`);
    if (query) {
      Object.entries(query).forEach(([k, v]) => {
        if (v !== undefined && v !== null && v !== "") {
          url.searchParams.set(k, v);
        }
      });
    }

    const res = await fetch(url.toString(), {
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

  async function listBenders(filters = {}) {
    return request("/benders", { query: filters });
  }

  async function upsertBender(bender) {
    return request("/admin/bender", { method: "PUT", body: bender, auth: true });
  }

  async function deleteBender(id) {
    return request(`/admin/bender/${encodeURIComponent(id)}`, { method: "DELETE", auth: true });
  }

  async function listTechniques(filters = {}) {
    return request("/techniques", { query: filters });
  }

  async function upsertTechnique(tech) {
    return request("/admin/technique", { method: "PUT", body: tech, auth: true });
  }

  async function deleteTechnique(id) {
    return request(`/admin/technique/${encodeURIComponent(id)}`, { method: "DELETE", auth: true });
  }

  async function getNation(name) {
    return request(`/nations/${encodeURIComponent(name)}`);
  }

  async function submitQuiz(answers) {
    return request("/quiz", { method: "POST", body: { answers } });
  }

  window.Api = {
    listBenders,
    upsertBender,
    deleteBender,
    listTechniques,
    upsertTechnique,
    deleteTechnique,
    getNation,
    submitQuiz
  };
})();

(() => {
  const config = window.APP_CONFIG || {};
  const TOKEN_KEY_ID = "avatar_id_token";
  const TOKEN_KEY_ACCESS = "avatar_access_token";
  const cognitoBase = (() => {
    if (!config.COGNITO_DOMAIN) return "";
    return config.COGNITO_DOMAIN.startsWith("http")
      ? config.COGNITO_DOMAIN
      : `https://${config.COGNITO_DOMAIN}`;
  })();

  function baseRedirectUri() {
    return `${window.location.origin}${window.location.pathname}`;
  }

  function loginUrl() {
    const params = new URLSearchParams({
      client_id: config.COGNITO_CLIENT_ID,
      response_type: "code",
      scope: "openid email",
      redirect_uri: baseRedirectUri()
    });
    return `${cognitoBase}/login?${params.toString()}`;
  }

  function logoutUrl() {
    const params = new URLSearchParams({
      client_id: config.COGNITO_CLIENT_ID,
      logout_uri: `${window.location.origin}/`,
      redirect_uri: `${window.location.origin}/`
    });
    return `${cognitoBase}/logout?${params.toString()}`;
  }

  function storeTokens({ id_token, access_token }) {
    if (id_token) localStorage.setItem(TOKEN_KEY_ID, id_token);
    if (access_token) localStorage.setItem(TOKEN_KEY_ACCESS, access_token);
  }

  function clearTokens() {
    localStorage.removeItem(TOKEN_KEY_ID);
    localStorage.removeItem(TOKEN_KEY_ACCESS);
  }

  function getIdToken() {
    return localStorage.getItem(TOKEN_KEY_ID);
  }

  function getAccessToken() {
    return localStorage.getItem(TOKEN_KEY_ACCESS);
  }

  function isAuthenticated() {
    return Boolean(getIdToken());
  }

  async function exchangeCodeForTokens(authCode) {
    const tokenUrl = `${cognitoBase}/oauth2/token`;
    const body = new URLSearchParams({
      grant_type: "authorization_code",
      client_id: config.COGNITO_CLIENT_ID,
      code: authCode,
      redirect_uri: baseRedirectUri()
    });

    const res = await fetch(tokenUrl, {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: body.toString()
    });

    const data = await res.json();
    if (!res.ok) {
      throw new Error(data.error || "Authentication failed");
    }

    storeTokens(data);
    // Remove query params so refreshes don't re-exchange
    window.history.replaceState({}, document.title, baseRedirectUri());
    return data;
  }

  async function bootstrapAuth() {
    const params = new URLSearchParams(window.location.search);
    const code = params.get("code");
    if (code) {
      try {
        await exchangeCodeForTokens(code);
      } catch (err) {
        console.error("Failed to exchange auth code", err);
      }
    }
  }

  window.Auth = {
    loginUrl,
    logoutUrl,
    getIdToken,
    getAccessToken,
    isAuthenticated,
    clearTokens,
    bootstrapAuth
  };
})();

#!/bin/bash

set -e

if [ -z "$DOMAIN_NAME" ]; then
    DOMAIN_NAME="localhost"
fi

DIR="/var/hugo/me"

echo "[INFO] Starting Hugo Setup..."

if [ -d "$DIR" ]; then
    echo "[INFO] Cleaning up existing directory..."
    rm -rf "$DIR"
fi

echo "[INFO] Creating new site..."
mkdir -p "$DIR"
cd "$DIR"

# create new site
hugo new site . --force --format yaml

echo "[INFO] Configuring config.yaml..."
cat > config.yaml <<EOF
baseURL: "https://${DOMAIN_NAME}/hugo/"
languageCode: "en-us"
title: "Inception Bonus"
theme: []
disableKinds: ["taxonomy", "taxonomyTerm"]
EOF

# CSS styles
STYLE="
<style>
    :root { --bg: #1a1b26; --text: #a9b1d6; --accent: #7aa2f7; }
    body { background: var(--bg); color: var(--text); font-family: sans-serif; margin: 0; padding: 2rem; display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 100vh; }
    h1 { color: var(--accent); }
    article { background: #24283b; padding: 2rem; border-radius: 10px; max-width: 600px; box-shadow: 0 4px 6px rgba(0,0,0,0.3); }
    a { color: #bb9af7; text-decoration: none; }
    a:hover { text-decoration: underline; }
</style>
"

# Create Layout
mkdir -p layouts/_default

# List.html
cat > layouts/_default/list.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>{{ .Title }}</title>
    $STYLE
</head>
<body>
    <h1>🚀 Inception Bonus</h1>
    <article>
        <h2>{{ .Title }}</h2>
        <div>{{ .Content }}</div>
        <p>Served via NGINX Proxy</p>
    </article>
</body>
</html>
EOF

# Single.html
cat > layouts/_default/single.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>{{ .Title }}</title>
    $STYLE
</head>
<body>
    <article>
        <h1>{{ .Title }}</h1>
        <div>{{ .Content }}</div>
        <a href="{{ .Site.BaseURL }}">Go Back</a>
    </article>
</body>
</html>
EOF

# Create Content
echo "[INFO] Creating Content..."
mkdir -p content
cat > content/_index.md <<EOF
---
title: "Hugo is Running!"
---
### Status: Operational

If you are seeing this page, your **Docker network** and **Nginx Proxy** are working correctly.

* Generated with **Hugo**
* Served by **Nginx**
* Secured with **SSL**
EOF

echo "[INFO] Setup complete. Starting Server..."

# execute server
exec hugo server \
    --bind="0.0.0.0" \
    --baseURL="https://${DOMAIN_NAME}/hugo/" \
    --port=1313 \
    --appendPort=false \
    -D
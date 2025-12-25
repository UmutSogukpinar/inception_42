#!/bin/sh
set -e

# Define the installation directory
DIR="/hugo_src"
echo "[INFO] Starting Hugo Setup..."

# Check if the site already exists to prevent overwriting
if [ -f "$DIR/config.yaml" ]; then
    echo "[INFO] Site already exists. Skipping setup..."
    cd $DIR
else
    echo "[INFO] Site not found. Creating new site..."
    
    # Clean up old directory if it exists
    rm -rf $DIR
    mkdir -p $DIR
    cd $DIR

    # 1. Create a New Hugo Site
    hugo new site . --force --format yaml

    # 2. Configure config.yaml
    # Replace 'login.42.fr' with your actual domain/port if needed
    echo "[INFO] Configuring config.yaml..."
    cat > config.yaml <<EOF
baseURL: "https://login.42.fr/hugo/"
languageCode: "en-us"
title: "Inception Bonus"
theme: []
disableKinds: ["taxonomy", "taxonomyTerm"]
EOF

    # 3. Create Layouts with Embedded CSS (Dark Theme)
    echo "[INFO] Creating Professional Layouts..."
    mkdir -p layouts/_default

    # Define the CSS style variable
    STYLE="
    <style>
        :root {
            --bg-color: #1a1b26;
            --card-bg: #24283b;
            --text-color: #a9b1d6;
            --heading-color: #7aa2f7;
            --accent-color: #bb9af7;
            --link-color: #7dcfff;
        }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: var(--bg-color);
            color: var(--text-color);
            margin: 0;
            padding: 0;
            line-height: 1.6;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }
        nav {
            background: var(--card-bg);
            padding: 1rem 2rem;
            border-bottom: 2px solid var(--accent-color);
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
        }
        nav h1 { margin: 0; font-size: 1.5rem; color: var(--heading-color); }
        main {
            max-width: 800px;
            margin: 2rem auto;
            padding: 0 1rem;
            flex: 1;
            width: 100%;
        }
        article {
            background: var(--card-bg);
            padding: 2rem;
            border-radius: 12px;
            margin-bottom: 2rem;
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.3);
            transition: transform 0.2s;
        }
        article:hover { transform: translateY(-5px); }
        h1, h2, h3 { color: var(--heading-color); margin-top: 0; }
        a { color: var(--link-color); text-decoration: none; font-weight: bold; }
        a:hover { text-decoration: underline; color: var(--accent-color); }
        .meta { font-size: 0.9rem; color: #565f89; margin-bottom: 1rem; display: block; }
        footer {
            text-align: center;
            padding: 2rem;
            background: var(--card-bg);
            margin-top: auto;
            font-size: 0.9rem;
            color: #565f89;
        }
        .avatar {
            width: 80px;
            height: 80px;
            background: linear-gradient(45deg, var(--accent-color), var(--heading-color));
            border-radius: 50%;
            margin: 0 auto 1rem;
            display: block;
            box-shadow: 0 0 15px var(--heading-color);
        }
    </style>
    "

    # Create List Page Layout (Homepage)
    cat > layouts/_default/list.html <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ .Title }} - Inception</title>
    $STYLE
</head>
<body>
    <nav>
        <h1>🚀 Inception 42 Hugo</h1>
    </nav>
    
    <main>
        <div class="avatar"></div>
        <article>
            <h1>{{ .Title }}</h1>
            <span class="meta">System Status: Active</span>
            <div>{{ .Content }}</div>
        </article>

        <article>
             <h2>About This Project</h2>
             <p>This website is hosted inside a Docker container using Hugo static site generator. It is served via NGINX proxy.</p>
        </article>
    </main>

    <footer>
        <p>Created for 42 Inception Bonus</p>
    </footer>
</body>
</html>
EOF

    # Create Single Page Layout (Individual Posts)
    cat > layouts/_default/single.html <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ .Title }}</title>
    $STYLE
</head>
<body>
    <nav>
        <h1><a href="{{ .Site.BaseURL }}">← Back to Home</a></h1>
    </nav>
    
    <main>
        <article>
            <h1>{{ .Title }}</h1>
            <span class="meta">Published just now</span>
            <div>{{ .Content }}</div>
        </article>
    </main>

    <footer>
        <p>42 Network</p>
    </footer>
</body>
</html>
EOF

    # 4. Create Content
    echo "[INFO] Creating Content..."
    mkdir -p content
    cat > content/_index.md <<EOF
---
title: "Hugo Service Running"
---
### Welcome to the Bonus Part!

This site demonstrates a fully functional **Hugo Server** running in a container.

* **High Performance** (Static Site Generator)
* **Modern Architecture** (Containerized)
* **Secure** (Served via NGINX)
EOF

    echo "[INFO] Setup complete."
fi

echo "[INFO] Starting Hugo Server..."

# 5. Start Hugo Server
# - bind=0.0.0.0: Required to be accessible from outside the container
# - baseURL: Matches the NGINX proxy path
# - appendPort=false: Important for proxying correctly
exec hugo server \
    --bind="0.0.0.0" \
    --baseURL="https://login.42.fr/hugo/" \
    --port=1313 \
    --appendPort=false \
    -D
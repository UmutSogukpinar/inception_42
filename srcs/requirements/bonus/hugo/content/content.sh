#!/bin/bash

set -e

if [ -z "$DOMAIN_NAME" ]; then
    DOMAIN_NAME="localhost"
fi

DIR="/var/hugo/me"

echo "[INFO] Starting 42 Project Blog Setup..."

if [ -d "$DIR" ]; then
    echo "[INFO] Cleaning up existing directory..."
    rm -rf "$DIR"
fi

echo "[INFO] Creating new site..."
mkdir -p "$DIR"
cd "$DIR"

# Create a new Hugo site with YAML configuration
hugo new site . --force --format yaml

echo "[INFO] Configuring config.yaml..."
cat > config.yaml <<EOF
baseURL: "https://${DOMAIN_NAME}/hugo/"
languageCode: "en-us"
title: "42 Survival Guide"
theme: []
disableKinds: ["taxonomy", "taxonomyTerm"]
EOF

# --- STYLING (CSS) ---
STYLE="
<style>
    :root { 
        --bg: #1a1b26; 
        --card-bg: #24283b;
        --text: #a9b1d6; 
        --heading: #7aa2f7; 
        --link: #bb9af7;
        --code-bg: #414868;
    }
    body { 
        background: var(--bg); 
        color: var(--text); 
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
        margin: 0; 
        padding: 0; 
        display: flex; 
        flex-direction: column; 
        align-items: center; 
        min-height: 100vh; 
    }
    header {
        width: 100%;
        background: #16161e;
        padding: 1.5rem;
        text-align: center;
        border-bottom: 2px solid var(--heading);
        margin-bottom: 2rem;
    }
    header h1 { margin: 0; color: var(--heading); }
    
    main {
        max-width: 800px;
        width: 90%;
        margin-bottom: 3rem;
    }

    /* Card Design */
    article { 
        background: var(--card-bg); 
        padding: 2rem; 
        border-radius: 12px; 
        box-shadow: 0 4px 6px rgba(0,0,0,0.3); 
        margin-bottom: 2rem;
    }

    h1, h2, h3 { color: var(--heading); }
    
    a { color: var(--link); text-decoration: none; font-weight: bold; }
    a:hover { text-decoration: underline; color: #fff; }

    /* List Props */
    ul.project-list { list-style: none; padding: 0; }
    ul.project-list li {
        background: var(--card-bg);
        margin-bottom: 1rem;
        padding: 1.5rem;
        border-radius: 8px;
        border-left: 4px solid var(--heading);
        transition: transform 0.2s;
    }
    ul.project-list li:hover { transform: translateX(10px); }
    
    code { background: var(--code-bg); padding: 0.2rem 0.4rem; border-radius: 4px; color: #e0af68; }
    .back-btn { display: inline-block; margin-top: 1rem; padding: 0.5rem 1rem; background: var(--heading); color: #1a1b26; border-radius: 4px; }
    .back-btn:hover { text-decoration: none; opacity: 0.9; color: #000; }
</style>
"

# --- LAYOUTS ---
mkdir -p layouts/_default

# List.html
cat > layouts/_default/list.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>{{ .Title }}</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    $STYLE
</head>
<body>
    <header>
        <h1>🚀 42 Guide</h1>
    </header>
    <main>
        <article>
            <h2>Welcome Coder</h2>
            <div>{{ .Content }}</div>
        </article>

        <h3>Project Archives</h3>
        <ul class="project-list">
            {{ range .Site.RegularPages }}
            <li>
                <a href="{{ .RelPermalink }}" style="font-size: 1.2rem;">📂 {{ .Title }}</a>
                <p>{{ .Summary }}</p>
            </li>
            {{ end }}
        </ul>
    </main>
</body>
</html>
EOF

# Single.html
cat > layouts/_default/single.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>{{ .Title }} - 42 Projects</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    $STYLE
</head>
<body>
    <header>
        <h1>{{ .Title }}</h1>
    </header>
    <main>
        <article>
            <div>{{ .Content }}</div>
            <hr style="border-color: #414868; margin: 2rem 0;">
            <a href="{{ .Site.BaseURL }}" class="back-btn">⬅ Back to Dashboard</a>
        </article>
    </main>
</body>
</html>
EOF

# --- CONTENT CREATION ---
echo "[INFO] Creating Project Content..."
mkdir -p content

# Main Page
cat > content/_index.md <<EOF
---
title: "Home"
---
This blog serves as a documentation hub for the **42 Curriculum**. 
Here you will find summaries, tips, and logic breakdowns for the core projects.

**Current Status:**
* **System:** Operational
* **Language:** C / C++
* **Norminette:** Strict
EOF

# Project 1: Libft
cat > content/libft.md <<EOF
---
title: "Libft: Your First Library"
date: 2023-01-01
---
### 🛠 The Project
**Libft** is the very first project at 42. It challenges you to recreate standard C library functions (like \`printf\`, \`strcat\`, \`atoi\`) from scratch.

### 💡 Key Concepts
* **Memory Management:** Understanding \`malloc\` and \`free\`.
* **Pointers:** Manipulating data directly in memory.
* **Linked Lists:** Creating the \`t_list\` struct and utility functions.

### ⚠️ Common Pitfalls
1.  Forgetting to protect against \`NULL\` pointers.
2.  Memory leaks in list manipulation functions.
3.  **Norminette** errors (25 lines max, 5 vars max).
EOF

# Project 2: Born2beroot
cat > content/born2beroot.md <<EOF
---
title: "Born2beroot: System Administration"
date: 2023-02-01
---
### 🖥 The Project
**Born2beroot** is an introduction to virtualization and system administration. You must install a Linux OS (Debian or Rocky) on a Virtual Machine.

### 🔐 Security Requirements
* **LVM:** Logical Volume Management with encryption.
* **SSH:** Port 4242 only, root login disabled.
* **UFW:** Firewall configuration.
* **Password Policy:** Strong passwords with expiry dates.
* **Sudo:** Strict configuration for user privileges.

### 🧠 The Logic
* **Partitioning:** Properly setting up partitions for root, home, and swap.
* **Service Management:** Ensuring SSH and UFW are correctly configured and enabled on boot.
EOF

# Project 3: so_long
cat > content/so_long.md <<EOF
---
title: "so_long: 2D Game Engine"
date: 2023-03-01
---
### 🎮 The Project
**so_long** is a small 2D game created using the **MiniLibX** graphical library. The goal is to collect items and escape the map.

### 🎨 Graphics & Logic
* **MiniLibX:** Handling windows, images, and key hooks.
* **Map Parsing:** Reading a \`.ber\` file and checking validity (flood fill algorithm).
* **Event Handling:** Moving the character with W/A/S/D.

### 👾 The Rules
* The map must be rectangular and enclosed by walls.
* You must handle textures (xpm files).
* No memory leaks allowed, even on exit.
EOF

# Project 4: Minishell
cat > content/minishell.md <<EOF
---
title: "Minishell: As beautiful as a shell"
date: 2023-04-01
---
### 🐚 The Project
**Minishell** is often considered the first "big boss" of the Common Core. You must write your own bash-like shell.

### ⚙️ Features
1.  **Parsing:** Tokenizing input, handling quotes (\`'\` vs \`"\`), and expanding environment variables (\`$USER\`).
2.  **Execution:** Using \`fork\`, \`execve\`, and \`waitpid\`.
3.  **Pipes & Redirections:** Handling \`|\`, \`<\`, \`>\`, \`<<\`, and \`>>\`.
4.  **Builtins:** \`cd\`, \`echo\`, \`export\`, \`unset\`, \`env\`, \`exit\`, \`pwd\`.

### 🧠 The Logic
* **Parsing Complexity:** You must handle multiple levels of quoting and variable expansion.
* **Process Management:** Properly managing child processes and avoiding zombies.

EOF

echo "[INFO] Setup complete. Starting Server..."

# Start the Hugo server
exec hugo server \
    --bind="0.0.0.0" \
    --baseURL="https://${DOMAIN_NAME}/hugo/" \
    --port=1313 \
    --appendPort=false \
    -D

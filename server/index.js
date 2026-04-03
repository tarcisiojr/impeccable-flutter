import { serve, file } from "bun";
import homepage from "../public/index.html";
import cheatsheet from "../public/cheatsheet.html";
import gallery from "../public/gallery.html";
import {
  getSkills,
  getCommands,
  getCommandSource,
  getPatterns,
  handleFileDownload,
  handleBundleDownload
} from "./lib/api-handlers.js";

const server = serve({
  port: process.env.PORT || 3000,

  routes: {
    "/": homepage,
    "/cheatsheet": cheatsheet,
    "/gallery": gallery,

    // Static assets - all public subdirectories
    "/assets/*": async (req) => {
      const url = new URL(req.url);
      if (url.pathname.includes('..')) return new Response("Bad Request", { status: 400 });
      const filePath = `./public${url.pathname}`;
      const assetFile = file(filePath);
      if (await assetFile.exists()) {
        return new Response(assetFile, {
          headers: { "X-Content-Type-Options": "nosniff", "X-Frame-Options": "DENY" }
        });
      }
      return new Response("Not Found", { status: 404 });
    },
    "/css/*": async (req) => {
      const url = new URL(req.url);
      if (url.pathname.includes('..')) return new Response("Bad Request", { status: 400 });
      const filePath = `./public${url.pathname}`;
      const assetFile = file(filePath);
      if (await assetFile.exists()) {
        return new Response(assetFile, {
          headers: { "Content-Type": "text/css", "X-Content-Type-Options": "nosniff", "X-Frame-Options": "DENY" }
        });
      }
      return new Response("Not Found", { status: 404 });
    },
    "/js/*": async (req) => {
      const url = new URL(req.url);
      if (url.pathname.includes('..')) return new Response("Bad Request", { status: 400 });
      // Check public/js/ first, then fall back to built artifacts
      const headers = { "Content-Type": "application/javascript", "X-Content-Type-Options": "nosniff", "X-Frame-Options": "DENY" };
      const publicFile = file(`./public${url.pathname}`);
      if (await publicFile.exists()) return new Response(publicFile, { headers });
      // Built browser detector served at /js/detect-antipatterns-browser.js
      const basename = url.pathname.split('/').pop();
      const builtFile = file(`./.claude/skills/critique/scripts/${basename}`);
      if (await builtFile.exists()) return new Response(builtFile, { headers });
      return new Response("Not Found", { status: 404 });
    },
    // Test fixtures (for browser visual testing)
    "/fixtures/*": async (req) => {
      const url = new URL(req.url);
      if (url.pathname.includes('..')) return new Response("Bad Request", { status: 400 });
      const filePath = `./tests${url.pathname}`;
      const assetFile = file(filePath);
      if (await assetFile.exists()) {
        const ext = url.pathname.split('.').pop();
        const types = { html: 'text/html', css: 'text/css', js: 'application/javascript' };
        return new Response(assetFile, {
          headers: { "Content-Type": types[ext] || "application/octet-stream", "X-Content-Type-Options": "nosniff" }
        });
      }
      return new Response("Not Found", { status: 404 });
    },
    "/antipattern-images/*": async (req) => {
      const url = new URL(req.url);
      if (url.pathname.includes('..')) return new Response("Bad Request", { status: 400 });
      const filePath = `./public${url.pathname}`;
      const assetFile = file(filePath);
      if (await assetFile.exists()) {
        return new Response(assetFile, {
          headers: { "X-Content-Type-Options": "nosniff" }
        });
      }
      return new Response("Not Found", { status: 404 });
    },
    "/antipattern-examples/*": async (req) => {
      const url = new URL(req.url);
      if (url.pathname.includes('..')) return new Response("Bad Request", { status: 400 });
      const filePath = `./public${url.pathname}`;
      const assetFile = file(filePath);
      if (await assetFile.exists()) {
        return new Response(assetFile, {
          headers: { "Content-Type": "text/html", "X-Content-Type-Options": "nosniff", "X-Frame-Options": "SAMEORIGIN" }
        });
      }
      return new Response("Not Found", { status: 404 });
    },

    // API: Get all skills
    "/api/skills": {
      async GET() {
        const skills = await getSkills();
        return Response.json(skills);
      },
    },
    
    // API: Get all commands
    "/api/commands": {
      async GET() {
        const commands = await getCommands();
        return Response.json(commands);
      },
    },

    // API: Get patterns and antipatterns
    "/api/patterns": {
      async GET() {
        const patterns = await getPatterns();
        return Response.json(patterns);
      },
    },

    // API: Get command source content
    "/api/command-source/:id": async (req) => {
      const { id } = req.params;
      const result = await getCommandSource(id);
      if (result && result.error) {
        return Response.json({ error: result.error }, { status: result.status });
      }
      if (!result) {
        return Response.json({ error: "Command not found" }, { status: 404 });
      }
      return Response.json({ content: result });
    },

    // API: Download individual file
    "/api/download/:type/:provider/:id": async (req) => {
      const { type, provider, id } = req.params;
      return handleFileDownload(type, provider, id);
    },
    
    // API: Download provider bundle ZIP
    "/api/download/bundle/:provider": async (req) => {
      const { provider } = req.params;
      return handleBundleDownload(provider);
    },
  },
  
  // Serve root-level static files (og-image.png, favicon, robots.txt, etc.)
  fetch(req) {
    const url = new URL(req.url);
    if (url.pathname.includes('..')) {
      return new Response("Bad Request", { status: 400 });
    }
    const filePath = `./public${url.pathname}`;
    const staticFile = file(filePath);
    if (staticFile.size > 0) {
      return new Response(staticFile);
    }
    return new Response("Not Found", { status: 404 });
  },

  development: process.env.NODE_ENV !== "production",
});

console.log(`🎨 impeccable.style running at ${server.url}`);


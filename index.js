#!/usr/bin/env node
import { promises as fs } from "node:fs";
import path from "node:path";
import url from "node:url";
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";

const __filename = url.fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Caminho fixo para os .txt (definido no build)
const LEIS_DIR = "C:\\Users\\pedro\\CÓDIGOS";
const SUPORTADAS = [".txt"];

async function listarArquivosLeis() {
  const entries = await fs.readdir(LEIS_DIR, { withFileTypes: true });
  return entries
    .filter(e => e.isFile() && SUPORTADAS.includes(path.extname(e.name).toLowerCase()))
    .map(e => path.join(LEIS_DIR, e.name));
}
async function lerArquivoTexto(filePath) { return fs.readFile(filePath, "utf8"); }
function escRegex(s) { return String(s).replace(/[.*+?^${}()|[\]\\]/g, "\\$&"); }
function construirRegexCitada({ padrao, leis, artigos, incisos, paragrafos }) {
  if (padrao && padrao.trim().length > 0) return new RegExp(padrao, "ig");
  const leiPart = leis?.length ? `(?:${leis.map(escRegex).join("|")})`
    : `(?:CF\\/?88|CPC(?:\\/?15)?|CC(?:\\/?02)?|CPP|CP|CLT|CDC|ECA|Lei\\s*\\d{1,6}\\/\\d{2,4})`;
  const artPart = artigos?.length ? `(?:${artigos.map(a => escRegex(String(a))).join("|")})` : `\\d{1,4}[A-Za-z]?`;
  const incPart = incisos?.length ? `(?:${incisos.map(escRegex).join("|")})` : `(?:[IVXLCDM]+)?`;
  const parPart = paragrafos?.length ? `(?:${paragrafos.map(escRegex).join("|")})` : `(?:Â§+\\s*\\d+Âº?)?`;
  const pattern = `\\bart\\.?\\s*${artPart}\\b(?:\\s*,\\s*${parPart})?(?:\\s*,\\s*inciso\\s*${incPart})?(?:\\s*,\\s*(?:do|da|de)\\s*${leiPart})?`;
  return new RegExp(pattern, "ig");
}
function normalizarCitacao(raw) {
  const artigo    = /art\\.?\\s*([\\dA-Za-z]+)/i.exec(raw)?.[1] ?? null;
  const paragrafo = /(Â§+\\s*\\d+Âº?)/i.exec(raw)?.[1] ?? null;
  const inciso    = /inciso\\s*([IVXLCDM]+)/i.exec(raw)?.[1] ?? null;
  const lei       = /\\b(CF\\/?88|CPC(?:\\/?15)?|CC(?:\\/?02)?|CPP|CP|CLT|CDC|ECA|Lei\\s*\\d{1,6}\\/\\d{2,4})\\b/i.exec(raw)?.[1] ?? null;
  return { texto: raw.trim(), lei, artigo, paragrafo, inciso };
}

const server = new McpServer({ name: "mcp-lei", version: "1.0.4" });

server.tool("listar_arquivos_lei", {}, async () => {
  const files = await listarArquivosLeis();
  return { content: [{ type: "text", text: JSON.stringify(files, null, 2) }] };
});

server.tool(
  "search_citacao_lei",
  {
    padrao: z.string().optional().describe('Regex opcional. Ex.: "\\\\bart\\\\.?\\\\s*37\\\\b"'),
    leis: z.array(z.string()).optional().describe('Ex.: ["CF/88","CPC","CC"]'),
    artigos: z.array(z.union([z.string(), z.number()])).optional().describe('Ex.: [37, 186, "1.022"]'),
    incisos: z.array(z.string()).optional().describe('Ex.: ["I","II","III"]'),
    paragrafos: z.array(z.string()).optional().describe('Ex.: ["Â§ 6Âº"]'),
    maxHits: z.number().int().positive().default(500).describe("Limite mÃ¡ximo de resultados")
  },
  async (input) => {
    const rx = construirRegexCitada(input);
    const files = await listarArquivosLeis();
    const resultados = [];
    for (const f of files) {
      const txt = await lerArquivoTexto(f);
      const linhas = txt.split(/\\r?\\n/);
      for (let i = 0; i < linhas.length; i++) {
        const linha = linhas[i];
        let m; rx.lastIndex = 0;
        while ((m = rx.exec(linha)) !== null) {
          const trecho = linha.slice(Math.max(0, m.index - 60), Math.min(linha.length, m.index + m[0].length + 60));
          resultados.push({ arquivo: path.basename(f), linha: i + 1, match: m[0], contexto: trecho, normalizado: normalizarCitacao(m[0]) });
          if (resultados.length >= (input.maxHits ?? 500)) {
            return { content: [{ type: "text", text: JSON.stringify(resultados, null, 2) }] };
          }
        }
      }
    }
    return { content: [{ type: "text", text: JSON.stringify(resultados, null, 2) }] };
  }
);

server.tool(
  "extrair_citacoes",
  {
    path: z.string().describe('Nome do arquivo no diretÃ³rio de leis, ex.: "CPC.txt"'),
    padrao: z.string().optional().describe("Regex opcional; se omitido, usa padrÃ£o genÃ©rico.")
  },
  async ({ path: relPath, padrao }) => {
    const full = path.join(LEIS_DIR, relPath);
    const txt = await lerArquivoTexto(full);
    const rx = construirRegexCitada({ padrao });
    const linhas = txt.split(/\\r?\\n/);
    const out = [];
    for (let i = 0; i < linhas.length; i++) {
      const linha = linhas[i];
      let m; rx.lastIndex = 0;
      while ((m = rx.exec(linha)) !== null) {
        out.push({ arquivo: path.basename(full), linha: i + 1, match: m[0], normalizado: normalizarCitacao(m[0]) });
      }
    }
    return { content: [{ type: "text", text: JSON.stringify(out, null, 2) }] };
  }
);

const transport = new StdioServerTransport();
await server.connect(transport);

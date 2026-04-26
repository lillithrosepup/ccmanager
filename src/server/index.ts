import Elysia from "elysia";
import { staticPlugin } from "@elysia/static";
import { MIGRATION_LEVEL } from "./constants";
import { C2SPacket, S2CPacket, C2SHandlers } from "./packets";
import z from "zod";
import { join } from "node:path";
import envVars from "./environment";
import logixlysia from "logixlysia";

export type Client = {
  wsId: string;
  name: string;
  flags: string[];
  send: (data: z.input<typeof S2CPacket>) => void;
  sendPostValidation: (data: z.output<typeof S2CPacket>) => void;
};

export const clients = new Map<string, Client>();

export function sendAll(data: z.input<typeof S2CPacket>) {
  const packet = S2CPacket.parse(data);
  for (const client of clients.values()) {
    client.sendPostValidation(packet);
  }
}

const CLIENT_FOLDER = join(import.meta.dir, "../client");

async function renderTemplate(
  fileName: string,
  vars: Record<string, string | number | boolean>,
) {
  return await Bun.file(join(CLIENT_FOLDER, `${fileName}.tmpl.lua`))
    .text()
    .then((text) =>
      text.replace(/\{(\w+)\}/g, (_, key) => {
        const val = vars[key];
        if (val === undefined) return "";
        if (typeof val === "boolean") return val ? "true" : "false";
        return String(val);
      }),
    );
}

const server = new Elysia()
  .use(
    logixlysia({
      config: {
        customLogFormat: "{method} {pathname} {status} {message}",
      },
    }),
  )
  .get("/setup", ({ headers }) =>
    headers["user-agent"]?.includes("computercraft")
      ? renderTemplate("setup", {
          isSSL: envVars.SSL,
          connectHost: envVars.HOST,
          connectPort: envVars.PORT ? envVars.PORT : envVars.SSL ? 443 : 80,
        })
      : `wget run http${envVars.SSL && "s"}://${envVars.HOST}${envVars.PORT ? ":" + envVars.PORT : ""}/setup`,
  )
  .use(
    new Elysia({ prefix: "/client" }).use(
      staticPlugin({ assets: CLIENT_FOLDER, prefix: "" }),
    ),
  )
  .group("/api", (g) =>
    g
      .get("/clients", () =>
        [...clients.values()].map((i) => ({
          name: i.name,
          flags: i.flags,
        })),
      )
      .get("/migration", () => MIGRATION_LEVEL),
  )

  .ws("/", {
    body: C2SPacket,
    // headers: z.object({
    //   Authorization: z.string(),
    // }),
    query: z.object({
      nodeName: z.string(),
      flags: z.preprocess(
        (val) => (typeof val === "string" ? [val] : val),
        z.array(z.string()).optional(),
      ),
    }),
    open(ws) {
      // TODO: auth
      const client: Client = {
        wsId: ws.id,
        name: ws.data.query.nodeName,
        flags: ws.data.query.flags || [],
        send(data) {
          const packet = S2CPacket.parse(data);
          ws.send(packet);
        },
        sendPostValidation(data) {
          ws.send(data);
        },
      };
      clients.set(ws.data.query.nodeName, client);

      ws.data.store.logger.info(ws.data.request, "New Node:", ws.data.query);

      sendAll({
        t: "nodeConnect",
        name: ws.data.query.nodeName,
        flags: ws.data.query.flags || [],
      });

      for (const client of [...clients.values()]) {
        if (client.wsId == ws.id) continue;
        ws.send(
          S2CPacket.parse({
            t: "nodeConnect",
            name: client.name,
            flags: client.flags,
          }),
        );
      }
    },
    async message(ws, p) {
      const client = clients.get(ws.data.query.nodeName);
      if (!client) {
        ws.data.store.logger.error(
          ws.data.request,
          `Client ${ws.data.query.nodeName} is not in clients map!`,
        );
        ws.close();
        return;
      }
      const handler = C2SHandlers[p.t];
      if (!handler) {
        ws.data.store.logger.error(
          ws.data.request,
          `Unknown packet type: ${p.t}`,
        );
        return;
      }
      try {
        await handler(p, client, ws.data.store);
      } catch (e) {
        ws.data.store.logger.error(
          ws.data.request,
          "Error in packet handler!",
          { e, client, p },
        );
      }
    },
    close(ws) {
      ws.data.store.logger.info(
        ws.data.request,
        `Client ${ws.data.query.nodeName} disconnected`,
      );
      clients.delete(ws.data.query.nodeName);
      sendAll({
        t: "nodeDisconnect",
        name: ws.data.query.nodeName,
        flags: ws.data.query.flags || [],
      });
    },
  });

server.listen(3000);

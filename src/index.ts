import Elysia from "elysia";
import { MIGRATION_LEVEL } from "./constants";
import { C2SPacket, S2CPacket, C2SHandlers } from "./packets";
import z from "zod";

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

const server = new Elysia()
  .get("/migration", () => MIGRATION_LEVEL)
  .ws("/ws", {
    body: C2SPacket,
    // headers: z.object({
    //   Authorization: z.string(),
    // }),
    query: z.object({
      nodeName: z.string(),
      flags: z.array(z.string()).optional(),
    }),
    open(ws) {
      // TODO: auth
      clients.set(ws.data.query.nodeName, {
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
      });

      console.log("New Node:", ws.data.query);

      sendAll({
        t: "nodeConnect",
        name: ws.data.query.nodeName,
        flags: ws.data.query.flags || [],
      });
    },
    async message(ws, p) {
      const client = clients.get(ws.data.query.nodeName);
      if (!client) {
        console.error(
          `Client ${ws.data.query.nodeName} is not in clients map!`,
        );
        ws.close();
        return;
      }
      const handler = C2SHandlers[p.t];
      if (!handler) {
        console.error("Unknown packet type:", p.t);
        return;
      }
      try {
        await handler(p, client);
      } catch (e) {
        console.error("Error in packet handler!", e, client, p);
      }
    },
    close(ws) {
      console.log(`Client ${ws.data.query.nodeName} disconnected`);
      clients.delete(ws.data.query.nodeName);
      sendAll({
        t: "nodeDisconnect",
        name: ws.data.query.nodeName,
        flags: ws.data.query.flags || [],
      });
    },
  });

console.log("Server listening on port 3000");
server.listen(3000);

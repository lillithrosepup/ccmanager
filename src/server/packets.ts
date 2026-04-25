import type { MaybePromise } from "bun";
import z from "zod";
import { clients, sendAll, type Client } from ".";

export const S2CPacket = z.discriminatedUnion("t", [
  z.object({
    t: z.literal("update"),
  }),
  z.object({
    t: z.literal("nodeConnect"),
    name: z.string(),
    flags: z.array(z.string()),
  }),
  z.object({
    t: z.literal("nodeDisconnect"),
    name: z.string(),
    flags: z.array(z.string()),
  }),
]);

export const C2SPacket = z.discriminatedUnion("t", [
  z.object({ t: z.literal("globalUpdate") }),
  z.object({
    t: z.literal("sendToClient"),
    client: z.string(),
    packet: S2CPacket,
  }),
]);

export const C2SHandlers: Record<
  string,
  (data: z.infer<typeof C2SPacket>, client: Client) => MaybePromise<void>
> = {
  globalUpdate: (data) => {
    if (data.t !== "globalUpdate") return;
    sendAll({ t: "update" });
  },
  sendToClient: (data, client) => {
    if (data.t !== "sendToClient") return;
    switch (data.client) {
      case "all":
        sendAll(data.packet);
        break;
      case "self":
        // idk why youd wanna do this but okay man
        client.send(data.packet);
        break;
      default: {
        const targetClient = clients.get(data.client);
        if (!targetClient) return;
        targetClient.send(data.packet);
      }
    }
  },
};

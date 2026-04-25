import type { MaybePromise } from "bun";
import z from "zod";
import { clients, type Client } from ".";

export const S2CPacket = z.discriminatedUnion("t", [
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
    console.log("Updating all clients...");
  },
  sendToClient: (data) => {
    if (data.t !== "sendToClient") return;
    const targetClient = clients.get(data.client);
    if (!targetClient) return;
    targetClient.send(data.packet);
  },
};

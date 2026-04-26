import type { MaybePromise } from "bun";
import z from "zod";
import { clients, sendAll, type Client } from ".";
import type { Logger, Pino } from "logixlysia";

export const S2CPacket = z.discriminatedUnion("t", [
  z.object({
    t: z.literal("update"),
  }),
  z.object({
    t: z.literal("reboot"),
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
  z.object({
    t: z.literal("keyDown"),
    keyCode: z.number(),
  }),
  z.object({
    t: z.literal("keyUp"),
    keyCode: z.number(),
  }),
]);

export const C2SPacket = z.discriminatedUnion("t", [
  z.object({ t: z.literal("update") }),
  z.object({ t: z.literal("reboot"), client: z.string() }),
  z.object({
    t: z.literal("send"),
    client: z.string(),
    packet: S2CPacket,
  }),
]);

export const C2SHandlers: Record<
  string,
  (
    data: z.infer<typeof C2SPacket>,
    client: Client,
    store: {},
  ) => MaybePromise<void>
> = {
  update: (data) => {
    if (data.t !== "update") return;
    sendAll({ t: "update" });
  },
  reboot: (data) => {
    if (data.t !== "reboot") return;
    switch (data.client) {
      case "all":
        sendAll({ t: "reboot" });
        break;
      default: {
        const targetClient = clients.get(data.client);
        if (!targetClient) return;
        targetClient.send({ t: "reboot" });
      }
    }
  },
  send: (data, client) => {
    if (data.t !== "send") return;
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

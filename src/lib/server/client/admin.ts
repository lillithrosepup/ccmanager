import { ServerPacketType, type ServerPacketData } from '$lib/packets/server';
import { Client } from '.';
import type { ExtendedWebSocket } from '../websocket/server';

export class Admin extends Client {
	constructor(ws: ExtendedWebSocket, name: string, id: number, debug = false, command: boolean) {
		super(ws, name, id, debug, command);

		this.on(ServerPacketType.Packet, (data: ServerPacketData[ServerPacketType.Packet]) => {
			this.ws.wss.getNode(data.node)?.send(data.packet.type, data.packet.data);
		});
	}
}

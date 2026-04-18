import { ClientPacketType, type ClientPacket, type ClientPacketData } from '$lib/packets/client';
import { ServerPacketType, type ServerPacket, type ServerPacketData } from '$lib/packets/server';
import type { ExtendedWebSocket } from '$lib/server/websocket/server';
import { SerializableClient } from '$lib/types/client';

export class Client implements SerializableClient {
	name: string;
	id: number;
	ws: ExtendedWebSocket;
	turtle: boolean;
	command: boolean;

	_debug: boolean = false;
	get debug(): boolean {
		return this._debug;
	}
	set debug(value: boolean) {
		this._debug = value;
		this.send(ClientPacketType.SetDebug, value);
	}

	get serializable(): SerializableClient {
		return new SerializableClient(this);
	}

	// eslint-disable-next-line @typescript-eslint/no-explicit-any
	listeners: Map<string, Map<number, (...args: any[]) => void>> = new Map();

	packetQueue: ClientPacket<ClientPacketType>[] = [];

	heartbeats: number[] = [];

	constructor(
		ws: ExtendedWebSocket,
		name: string,
		id: number,
		debug = false,
		turtle = false,
		command = false,
	) {
		this.ws = ws;
		this.name = name;
		this.id = id;
		this.debug = debug;
		this.turtle = turtle;
		this.command = command;

		this.ws.on('close', (code, reason) => {
			this.emit('close', code, reason.toString());
		});

		this.ws.on('message', (message) => {
			const packet = JSON.parse(message.toString()) as ServerPacket<ServerPacketType>;
			if (this.debug) {
				console.log(`Node ${this.name} (${this.id}) Received`, packet);
			}
			this.emit(packet.type, packet.data);
			this.emit('packet', packet);
		});

		setInterval(() => {
			if (this.ws.readyState !== this.ws.OPEN) {
				return;
			}
			const now = Date.now();
			this.send(ClientPacketType.Heartbeat, now);
			this.heartbeats.push(now);

			if (this.heartbeats.length > 10) {
				this.close(1008, 'Heartbeat timeout');
			}
		}, 1000);

		this.on(ServerPacketType.Heartbeat, (data) => {
			this.heartbeats = this.heartbeats.filter((heartbeat) => heartbeat > data);
		});

		this.on(ServerPacketType.Chat, (message) => {
			const commandNode = Array.from(this.ws.wss.nodes.values()).find((i) => i.command);
			if (!commandNode) return;
			commandNode.runCommand(`tellraw @a {"text":"[${this.name} (${this.id})] ${message}"}`);
		});

		setInterval(() => {
			if (this.packetQueue.length > 0) {
				const packet = this.packetQueue.shift()!;
				if (this.debug) {
					console.log(`Node ${this.name} (${this.id}) Sent`, packet);
				}
				this.ws.send(JSON.stringify(packet));
				this.emit('packetOut', packet);
			}
		}, 100);
	}

	send<T extends ClientPacketType>(type: T, data: ClientPacketData[T]) {
		if (this.ws.readyState !== this.ws.OPEN) {
			return;
		}
		const packet = {
			type,
			data
		} as ClientPacket<T>;
		this.packetQueue.push(packet);
	}

	reboot() {
		this.send(ClientPacketType.Reboot, {});
	}

	eval(code: string): Promise<ServerPacketData[ServerPacketType.Eval]> {
		const now = Date.now();
		return new Promise((resolve) => {
			this.send(ClientPacketType.Eval, {
				nonce: now,
				code
			});
			const onId = this.on(ServerPacketType.Eval, (data) => {
				if (data.nonce === now) {
					this.off(ServerPacketType.Eval, onId);
					resolve(data);
				}
			});
		});
	}

	runCommand(command: string): Promise<ServerPacketData[ServerPacketType.Command]> {
		const now = Date.now();
		return new Promise((resolve) => {
			this.send(ClientPacketType.Command, {
				nonce: now,
				command
			});
			const onId = this.on(ServerPacketType.Command, (data) => {
				if (data.nonce === now) {
					this.off(ServerPacketType.Command, onId);
					resolve(data);
				}
			});
		});
	}

	emit(event: 'close', code: number, reason: string): void;
	emit(event: 'packet', packet: ServerPacket<ServerPacketType>): void;
	emit(event: 'packetOut', packet: ClientPacket<ClientPacketType>): void;
	emit<T extends ServerPacketType>(type: T, data: ServerPacketData[T]): void;
	// eslint-disable-next-line @typescript-eslint/no-explicit-any
	emit(event: string, ...args: any[]) {
		this.listeners.get(event)?.forEach((callback) => callback(...args));
	}

	on(event: 'close', callback: (code: number, reason: string) => void): number;
	on(event: 'packet', callback: (packet: ServerPacket<ServerPacketType>) => void): number;
	on(event: 'packetOut', callback: (packet: ClientPacket<ClientPacketType>) => void): number;
	on<T extends ServerPacketType>(type: T, callback: (data: ServerPacketData[T]) => void): number;
	// eslint-disable-next-line @typescript-eslint/no-explicit-any
	on(event: string, callback: (...args: any[]) => void): number {
		const listeners = this.listeners.get(event) || new Map();
		const id = Math.random();
		listeners.set(id, callback);
		this.listeners.set(event, listeners);
		return id;
	}

	once(event: 'close', callback: (code: number, reason: string) => void): number;
	once(event: 'packet', callback: (packet: ServerPacket<ServerPacketType>) => void): number;
	once(event: 'packetOut', callback: (packet: ClientPacket<ClientPacketType>) => void): number;
	once<T extends ServerPacketType>(type: T, callback: (data: ServerPacketData[T]) => void): number;
	// eslint-disable-next-line @typescript-eslint/no-explicit-any
	once(event: string, callback: (...args: any[]) => void): number {
		const id = this.on(event as ServerPacketType, (...args) => {
			this.off(event as ServerPacketType, id);
			callback(...args);
		});
		return id;
	}

	off(event: 'close', id: number): void;
	off(event: 'packet', id: number): void;
	off(event: 'packetOut', id: number): void;
	off<T extends ServerPacketType>(type: T, id: number): void;
	off(event: string, id: number) {
		const listeners = this.listeners.get(event);
		if (listeners) {
			listeners.delete(id);
		}
	}

	close(code: number, reason: string) {
		this.ws.close(code, reason);
	}
}

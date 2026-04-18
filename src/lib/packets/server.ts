import type { ClientType } from '$lib/types';
import type { TurtleDirection } from '$lib/types/direction';
import type { ClientPacket, ClientPacketType } from './client';

export enum ServerPacketType {
	Register = 'register',
	Heartbeat = 'heartbeat',
	Eval = 'eval',

	// Admin ones

	Move = 'move',
	Dig = 'dig',
	Refuel = 'refuel',
	Command = 'command',
	Chat = 'chat',
	Packet = 'packet',
}

export type ServerPacketData = {
	[ServerPacketType.Register]: {
		type: ClientType;
		name: string;
		id: number;
		password: string;
		debug?: boolean;
		turtle: boolean;
		command: boolean;
	};
	[ServerPacketType.Heartbeat]: number;
	[ServerPacketType.Eval]: {
		nonce: number;
		success: boolean;
		// eslint-disable-next-line @typescript-eslint/no-explicit-any
		output: string;
	};

	// Admin ones

	[ServerPacketType.Move]: {
		id: number;
		direction: TurtleDirection;
	};

	[ServerPacketType.Dig]: {
		id: number;
		direction: TurtleDirection;
	};
	[ServerPacketType.Refuel]: number;

	[ServerPacketType.Command]: {
		nonce: number;
		success: boolean;
		logs: string[];
	};
	[ServerPacketType.Chat]: string;
	[ServerPacketType.Packet]: {
		node: number | string;
		packet: ClientPacket<ClientPacketType>;
	};
};

export type ServerPacket<T extends ServerPacketType> = {
	type: T;
	data: ServerPacketData[T];
};

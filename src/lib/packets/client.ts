import type { SerializableClient } from '$lib/types/client';
import type { Direction, TurtleDirection } from '$lib/types/direction';
import type { ServerPacket, ServerPacketType } from './server';

export enum ClientPacketType {
	Register = 'register',
	Heartbeat = 'heartbeat',
	Eval = 'eval',
	Toggle = 'toggle',
	TurnOn = 'turnOn',
	TurnOff = 'turnOff',
	Update = 'update',
	SetDebug = 'setDebug',
	AdminNodePacket = 'adminNodePacket',
	Command = 'command',
	Reboot = 'reboot',

	// Turtle
	Move = 'move',
	Dig = 'dig',
	Refuel = 'refuel',
	TurtleMode = 'turtleMode',
	KeyDown = 'keyDown',
	KeyUp = 'keyUp'
}

export type ClientPacketData = {
	[ClientPacketType.Register]: {
		success: boolean;
		message?: string;
	};
	[ClientPacketType.Heartbeat]: number;
	[ClientPacketType.Eval]: {
		nonce: number;
		code: string;
	};
	[ClientPacketType.Toggle]: Direction;
	[ClientPacketType.TurnOn]: Direction;
	[ClientPacketType.TurnOff]: Direction;
	[ClientPacketType.KeyDown]: number;
	[ClientPacketType.KeyUp]: number;
	[ClientPacketType.Update]: Record<string, never>;
	[ClientPacketType.SetDebug]: boolean;
	[ClientPacketType.AdminNodePacket]: {
		node: SerializableClient;
		toServer: boolean;
		packet: ServerPacket<ServerPacketType> | ClientPacket<ClientPacketType>;
	};
	[ClientPacketType.Command]: {
		nonce: number;
		command: string;
	};
	[ClientPacketType.Reboot]: Record<string, never>;

	// Turtle
	[ClientPacketType.Move]: TurtleDirection;
	[ClientPacketType.Dig]: TurtleDirection;
	[ClientPacketType.Refuel]: Record<string, never>;
	[ClientPacketType.TurtleMode]: {
		mode: string;
		args: string[];
	};
};

export type ClientPacket<T extends ClientPacketType> = {
	type: T;
	data: ClientPacketData[T];
};

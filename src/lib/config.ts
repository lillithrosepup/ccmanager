import { ClientType } from './types';

export interface ServerConfig {
	connectPort: number;
	connectHost: string;
	ssl: boolean;

	passwords: {
		admin: string;
		node: string;
	};
	waypointMode: 'xaero' | 'journey';
}

export interface ClientBootConfig {
	host: string;
	port: number;
	ssl: boolean;
	type: ClientType;
	customBootUrl?: string;
}

export interface BaseClientConfig {
	password: string;
	id: number;
}

export interface AdminClientConfig extends BaseClientConfig {}

export interface NodeClientConfig extends BaseClientConfig {
	name: string;
}

const serverConfig: ServerConfig = {
	connectPort: parseInt(process.env.CONNECT_PORT || '8081'),
	connectHost: process.env.CONNECT_HOST || 'localhost',
	ssl: process.env.SSL === 'true',

	passwords: {
		admin: process.env.ADMIN_PASSWORD || 'admin',
		node: process.env.NODE_PASSWORD || 'node'
	},
	waypointMode: (process.env.WAYPOINT_MODE || 'journey') as 'xaero' | 'journey'
};

export default serverConfig;

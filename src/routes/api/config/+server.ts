import serverConfig, { type ServerConfig } from '$lib/config';
import { json, type RequestHandler } from '@sveltejs/kit';

export const GET: RequestHandler = async () => {
	const config: Partial<ServerConfig> = Object.assign({}, serverConfig);
	delete config.passwords;
	return json(config);
};

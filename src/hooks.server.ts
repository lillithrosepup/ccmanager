import { building } from '$app/environment';
import serverConfig from '$lib/config';
import { ClientPacketType } from '$lib/packets/client';
import { ServerPacketType, type ServerPacket, type ServerPacketData } from '$lib/packets/server';
import { Admin } from '$lib/server/client/admin';
import { Node } from '$lib/server/client/node';
import type { ExtendedGlobal } from '$lib/server/websocket/server';
import { GlobalThisWSS } from '$lib/server/websocket/server';
import { ClientType } from '$lib/types';
import { redirect, text, type Handle } from '@sveltejs/kit';

// This can be extracted into a separate file
let wssInitialized = false;
const startupWebsocketServer = () => {
	if (wssInitialized) return;
	console.log('[wss:kit] setup');
	const wss = (globalThis as ExtendedGlobal)[GlobalThisWSS];
	if (wss !== undefined) {
		wss.on('connection', (ws) => {
			if (ws.wss) return;
			ws.wss = wss;
			// This is where you can authenticate the client from the request
			// const session = await getSessionFromCookie(request.headers.cookie || '');
			// if (!session) ws.close(1008, 'User not authenticated');
			// ws.userId = session.userId;
			console.log(`[wss:kit] client connected (${ws.socketId})`);

			ws.on('close', (_: unknown, code: number, reason: string) => {
				console.log(
					`[wss:kit] client ${ws.item?.name} (${ws.item?.id}) disconnected (${ws.socketId}) with code ${code} and reason ${reason}`
				);
			});

			ws.once('message', (message) => {
				const packet = JSON.parse(message.toString()) as ServerPacket<ServerPacketType>;

				if (packet.type !== ServerPacketType.Register) {
					ws.send(
						JSON.stringify({
							type: ClientPacketType.Register,
							data: {
								success: false,
								message: 'Invalid packet type'
							}
						})
					);
					ws.close(1008, 'Invalid packet type');
					return;
				}

				const data = packet.data as ServerPacketData[ServerPacketType.Register];

				switch (data.type) {
					case ClientType.Node: {
						ws.type = ClientType.Node;
						const node = new Node(
							ws,
							data.name,
							data.id,
							data.debug || false,
							data.turtle,
							data.command,
							data.airship
						);
						ws.item = node;

						if (data.password !== serverConfig.passwords.node) {
							node.send(ClientPacketType.Register, {
								success: false,
								message: 'Invalid password'
							});
							ws.close(1008, 'Invalid password');
							return;
						}

						wss.nodes.set(ws.item.id, node);

						node.send(ClientPacketType.Register, {
							success: true
						});

						node.on('close', () => {
							wss.nodes.delete(node.id);
						});

						break;
					}

					case ClientType.Admin: {
						ws.type = ClientType.Admin;
						const admin = new Admin(
							ws,
							data.name,
							data.id,
							data.debug || false,
							data.command,
						);
						ws.item = admin;

						if (data.password !== serverConfig.passwords.admin) {
							admin.send(ClientPacketType.Register, {
								success: false,
								message: 'Invalid password'
							});
							ws.close(1008, 'Invalid password');
							return;
						}

						wss.admins.set(ws.item.id, admin);

						admin.send(ClientPacketType.Register, {
							success: true
						});

						admin.on('close', () => {
							wss.admins.delete(admin.id);
						});

						break;
					}

					default:
						ws.send(
							JSON.stringify({
								error: 'Invalid client type'
							})
						);
						ws.close(1008, 'Invalid client type');
						return;
				}
			});
		});

		wssInitialized = true;
	}
};

export const handle = (async ({ event, resolve }) => {
	startupWebsocketServer();
	// Skip WebSocket server when pre-rendering pages
	if (!building) {
		const wss = (globalThis as ExtendedGlobal)[GlobalThisWSS];
		if (wss !== undefined) {
			event.locals.wss = wss;

			if (event.url.pathname.startsWith('/api/admin/nodes')) {
				let node = wss.nodes.get(Number(event.params.id));
				if (!node) {
					for (const n of wss.nodes.values()) {
						if (n.name === event.params.id) {
							node = n;
							break;
						}
					}
				}
				if (node) {
					event.locals.node = node;
				}
			}
		}
	}

	if (event.url.pathname.startsWith('/api/node')) {
		if (
			!event.cookies.get('password') ||
			event.cookies.get('password') !== serverConfig.passwords.node
		) {
			return text('Unauthorized', { status: 401 });
		}

		const node = event.locals.wss.getNode(event.params.id!);
		if (node) {
			event.locals.node = node;
		}
	} else if (
		!['/websocket', '/login', '/setup', '/api/render', '/api/config'].includes(event.url.pathname) &&
		!event.url.pathname.includes('/lua')
	) {
		if (
			!event.cookies.get('password') ||
			event.cookies.get('password') !== serverConfig.passwords.admin
		) {
			console.log('event', event);
			return redirect(302, '/login');
		}
	}

	const response = await resolve(event, {
		filterSerializedResponseHeaders: (name) => name === 'content-type'
	});
	return response;
}) satisfies Handle;

<script lang="ts">
	import Monaco from '$lib/components/Monaco.svelte';
	import { ClientPacketType, type ClientPacket, type ClientPacketData } from '$lib/packets/client';
	import { ServerPacketType, type ServerPacket, type ServerPacketData } from '$lib/packets/server';
	import { ClientType } from '$lib/types';
	import type monaco from 'monaco-editor';
	import { onMount } from 'svelte';
	import { writable, type Writable } from 'svelte/store';
	import type { PageServerData } from './$types';

	export let data: PageServerData;

	let evalCode = 'return "Hello World!"';
	let evalOut: monaco.editor.IStandaloneCodeEditor | null = null;

	async function evalLua() {
		const res = await fetch(`/api/admin/nodes/${data.node.id}/eval`, {
			method: 'POST',
			body: evalCode
		});

		let packet: ServerPacketData[ServerPacketType.Eval] = await res.json();

		if (packet.success) {
			evalOut?.setValue(packet.output);
		} else {
			evalOut?.setValue('Error: ' + packet.output);
		}
	}

	const debug = writable(data.node.debug);

	let ws: WebSocket;

	onMount(() => {
		let first = true;
		debug.subscribe(() => {
			if ($debug) {
				ws = new WebSocket(
					`ws${location.protocol === 'https:' ? 's' : ''}://${location.host}/websocket`
				);
				ws.onopen = () => {
					ws?.send(
						JSON.stringify({
							type: ServerPacketType.Register,
							data: {
								type: ClientType.Admin,
								password: data.password,
								name: 'Website-' + data.node.id,
								id: data.node.id,
								turtle: false
							}
						} as ServerPacket<ServerPacketType.Register>)
					);
				};

				ws.onmessage = (e) => {
					let packet: ClientPacket<ClientPacketType> = JSON.parse(e.data);
					switch (packet.type) {
						case ClientPacketType.Register:
							if (!(packet as ClientPacket<ClientPacketType.Register>).data.success) {
								ws?.close();
								alert('Failed to register with server!');
							}
							break;
						case ClientPacketType.Heartbeat:
							ws?.send(
								JSON.stringify({
									type: ServerPacketType.Heartbeat,
									data: packet.data
								} as ServerPacket[ServerPacketType.Heartbeat])
							);
							break;
						case ClientPacketType.AdminNodePacket:
							if (packet.data.node.id !== data.node.id) return;
							const incPacket = (packet.data as ClientPacketData[ClientPacketType.AdminNodePacket])
								.packet;
							if (incPacket.type === ServerPacketType.Heartbeat) return;
							if (packet.data.toServer) {
								serverPackets.update((packets) => {
									if (packets.length > 9) packets.pop();
									packets.push(incPacket as ServerPacket[ServerPacketType]);
									return packets;
								});
							} else {
								clientPackets.update((packets) => {
									if (packets.length > 9) packets.pop();
									packets.push(incPacket as ClientPacket[ClientPacketType]);
									return packets;
								});
							}
							break;
					}
				};
			} else {
				ws?.close();
			}

			if (first) {
				first = false;
				return;
			}
			fetch(`/api/admin/nodes/${data.node.id}/debug`, {
				method: 'POST',
				body: $debug ? 'true' : 'false'
			});
		});
	});

	let outgoingPacket = JSON.stringify(
		{
			type: '',
			data: {}
		},
		null,
		2
	);

	const serverPackets: Writable<ServerPacket[ServerPacketType][]> = writable([]);
	const clientPackets: Writable<ClientPacket[ClientPacketType][]> = writable([]);

	$: {
		serverPacketsEditor?.setValue(JSON.stringify($serverPackets.reverse(), null, 2));
	}

	$: {
		clientPacketsEditor?.setValue(JSON.stringify($clientPackets.reverse(), null, 2));
	}

	let serverPacketsEditor: monaco.editor.IStandaloneCodeEditor | null = null;
	let clientPacketsEditor: monaco.editor.IStandaloneCodeEditor | null = null;

	function sendPacket() {
		const packet = JSON.parse(outgoingPacket) as ClientPacket[ClientPacketType];

		fetch(`/api/admin/nodes/${data.node.id}/packet`, {
			method: 'POST',
			body: JSON.stringify(packet)
		});
	}
</script>

<div class="size-full flex flex-col items-center">
	<div class="self-start">
		<h1>{data.node.name}</h1>
		<p>#{data.node.id}</p>
	</div>

	<div class="size-full flex flex-col items-center p-3 gap-3">
		<div
			class="debug flex flex-col h-1/10 items-center w-full p-3 bg-slate-800 rounded-xl"
			class:active={$debug}
		>
			<h2>Debug</h2>
			<input type="checkbox" bind:checked={$debug} />

			{#if $debug}
				<div class="size-full flex pb-5 flex-row">
					<div class="w-1/3 h-full items-center overflow-hidden">
						<div class="flex flex-row">
							<h3>Outgoing</h3>
							<button class="ml-5 h-6 rounded-xl bg-slate-500 w-16" on:click={sendPacket}>
								<span>send</span>
							</button>
						</div>
						<Monaco bind:code={outgoingPacket} language={'json'} />
					</div>

					<div class="w-1/3 h-full items-center overflow-hidden">
						<h3>To Server</h3>
						<Monaco bind:editor={serverPacketsEditor} language={'json'} code={'{}'} />
					</div>
					<div class="w-1/3 h-full items-center overflow-hidden">
						<h3>To Client</h3>
						<Monaco bind:editor={clientPacketsEditor} language={'json'} code={'{}'} />
					</div>
				</div>
			{/if}
		</div>

		<div class="flex flex-col w-full h-3/4 p-3 bg-slate-800 rounded-xl">
			<button on:click={evalLua}>Eval</button>
			<div class="size-full flex pb-5 flex-row">
				<div class="w-1/2 h-full items-center overflow-hidden">
					<h3>Input</h3>
					<Monaco bind:code={evalCode} language={'lua'} />
				</div>

				<div class="w-1/2 h-full items-center overflow-hidden">
					<h3>Output</h3>
					<Monaco bind:editor={evalOut} language={'text'} code="Output will appear here!" />
				</div>
			</div>
		</div>
	</div>
</div>

<style>
	.debug.active {
		height: 75%;
	}
</style>

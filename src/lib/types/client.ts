export class SerializableClient {
	name: string;
	id: number;
	debug: boolean;
	turtle: boolean;
	command: boolean;

	constructor(client: SerializableClient) {
		this.name = client.name;
		this.id = client.id;
		this.debug = client.debug;
		this.turtle = client.turtle;
		this.command = client.command;
	}
}

import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { Mwbot } from "mwbot-ts";
import z from "zod";

const server = new McpServer({
	name: "DragDown Cargo Database MCP Server",
	description: `An MCP server that provides access to the Cargo database of the Dragdown wiki (runs on MediaWiki). The database tables have details about framedata, hitboxes and more. The different games are AFQM ('A Few Quick Matches'), NASB2 (Nintendo All Stars Brawl 2), PPlus (Project+, a mod of Super Smash Bros. Brawl, like Project M), RoA2 (Rivals of Aether 2) and a few more.

	This MCP server helps AI to understand the data that's flowing through the Lua modules in this codebase so it can help more effectively to refactor the code.
		
	To get data, you need to use the "select" tool, which allows you to run SQL SELECT queries through the MediaWiki API. However, to use this tool effectively, you first need to know the names of the tables and fields (columns) in the Cargo database. You can obtain this information using the "list-tables" and "list-fields" tools provided by this MCP server.`,
	version: "1.0.0",
	capabilities: {
		resources: {},
		tools: {},
		prompts: {},
	},
});

const mw = await Mwbot.init({
	apiUrl: "https://dragdown.wiki/w/api.php",
	credentials: {
		username: process.env.DRAGDOWN_USERNAME,
		password: process.env.DRAGDOWN_PASSWORD,
	},
	suppressWarnings: true,
});

server.registerTool(
	"list-tables",
	{
		title: "List tables",
		description: "List all tables",
		annotations: {
			destructiveHint: false,
			idempotentHint: true,
			readOnlyHint: true,
			openWorldHint: true,
		},
	},
	async () => {
		const data = await mw.fetch({
			action: "cargotables",
			format: "json",
			formatversion: 2,
		});

		return {
			content: [
				{
					type: "text",
					text: JSON.stringify(data.cargotables),
				},
			],
			structuredContent: {
				tables: data.cargotables,
			},
		};
	}
);

server.registerTool(
	"list-fields",
	{
		title: "List fields of table",
		description: `List all fields (columns) of a specified table. The field type 'Wikitext' is like 'String'.
			
			To use this tool, you need to know the table name. You can get the table names by using the "list-tables" tool if the user didn't provide it. If you're unsure if the user has provided the correct table name, it's best to use the "list-tables" tool first to confirm.
			
			It's totally fine to retry calling this tool if you get an error. Just use "list-tables" first to confirm the table name, then call this tool again with the correct table name.`,
		annotations: {
			destructiveHint: false,
			idempotentHint: true,
			readOnlyHint: true,
			openWorldHint: true,
		},
		inputSchema: z.object({
			table: z
				.string()
				.describe(
					"The Cargo table name to list fields for. If you're not sure which table to use, use the 'list-tables' tool first."
				),
		}),
	},
	async (params) => {
		const data = await mw.fetch({
			action: "cargofields",
			table: params.table,
			format: "json",
			formatversion: 2,
		});

		return {
			content: [
				{
					type: "text",
					text: JSON.stringify(data.cargofields),
				},
			],
			structuredContent: {
				fields: data.cargofields,
			},
		};
	}
);

server.registerTool(
	"select",
	{
		title: "Select from table",
		description: `Run an SQL SELECT through the MediaWiki API (action=cargoquery) and return the results as JSON. Equivalent to \`{{#cargo_query:...}}\` in MediaWiki templates and \`mw.ext.cargo.query(...)\` in MediaWiki Lua modules.
			
			To query successfully, you need to know the table name(s) and field name(s). You can get these by using the "list-tables" and "list-fields" tools if the user didn't provide them. If you're unsure if the user has provided them or if they're correct, it's best to use the "list-tables" and "list-fields" tools first to confirm.
			
			It's totally fine to retry calling this tool if you get an error. Just use "list-tables" and "list-fields" first to confirm the table and field names, then call this tool again with the correct names.`,
		inputSchema: z.object({
			tables: z
				.array(z.string())
				.min(1)
				.describe(
					"The Cargo table(s) to query. Corresponds to SQL FROM clause. If you're not sure which table to use, use the 'list-tables' tool first."
				),
			fields: z
				.array(z.string())
				.min(1)
				.describe(
					"The fields to select. Corresponds to SQL SELECT columns but doesn't support wildcard/asterisk. If you're not sure which fields to use, use the 'list-fields' tool first."
				),
			where: z
				.string()
				.optional()
				.describe(
					"the conditions for this query, if any; can include operators like AND, OR and NOT. Corresponds to the SQL WHERE clause."
				),
			groupBy: z
				.string()
				.optional()
				.describe(
					'one or more fields whose values should be grouped together in one row each. Corresponds to the SQL GROUP BY clause. Note that DISTINCT does not work in Cargo (except within a function like COUNT()), so in most cases you must use "groupBy" to eliminate duplicates.'
				),
			orderBy: z
				.string()
				.optional()
				.describe(
					'one or more fields by which the result set should be sorted; the default value is "_pageName ASC", which does an ascending sort on page name. Setting it to "_rowID" should sort rows by the same order they were entered. Corresponds to the SQL ORDER BY clause.'
				),
			limit: z
				.number()
				.optional()
				.describe(
					"the maximum number of rows to display. Corresponds to the SQL LIMIT clause."
				),
			offset: z
				.number()
				.optional()
				.describe(
					"the number of initial rows to skip. Corresponds to the SQL OFFSET clause."
				),
		}),
		annotations: {
			destructiveHint: false,
			idempotentHint: true,
			readOnlyHint: true,
			openWorldHint: true,
		},
	},
	async (params) => {
		const response = await mw.fetch({
			action: "cargoquery",
			tables: params.tables.join(","),
			fields: params.fields.join(","),
			where: params.where,
			group_by: params.groupBy,
			order_by: params.orderBy,
			limit: params.limit,
			offset: params.offset,
			format: "json",
			formatversion: 2,
		});

		if (!("cargoquery" in response)) {
			return {
				isError: true,
				content: [
					{
						type: "text",
						text: JSON.stringify(response),
					},
				],
			};
		}

		const entries = response.cargoquery.map((entry) => entry.title);

		return {
			content: [
				{
					type: "text",
					text: JSON.stringify(entries),
				},
			],
			structuredContent: {
				entries,
			},
		};
	}
);

const transport = new StdioServerTransport();
await server.connect(transport);

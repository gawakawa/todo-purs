import { httpServerHandler } from "cloudflare:node";
import { main } from "./output/Main/index.js";

main();
export default httpServerHandler({ port: 8080 });

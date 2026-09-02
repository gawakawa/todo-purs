import { env } from "cloudflare:workers";

export const queryImpl = (sql) => (params) => async () => {
  const { results } = await env.DB.prepare(sql)
    .bind(...params)
    .all();
  return results;
};

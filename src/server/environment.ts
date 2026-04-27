import z from "zod";

export const envSchema = z.object({
  NODE_ENV: z.enum(["development", "production"]),
  HOST: z.string(),
  SSL: z.stringbool(),
  PORT: z.coerce.number().optional(),
});

const envVars = envSchema.parse(process.env);

export default envVars;

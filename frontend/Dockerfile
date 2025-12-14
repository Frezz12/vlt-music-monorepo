# -------- Build --------
FROM oven/bun:1.3 AS builder

WORKDIR /app

COPY package.json bun.lock ./
RUN bun install --frozen-lockfile

COPY . .
RUN bun run build

# -------- Runtime --------
FROM oven/bun:1.3 AS runner

WORKDIR /app

COPY --from=builder /app/.output ./.output

EXPOSE 3000

ENV HOST=0.0.0.0
ENV PORT=3000
ENV NODE_ENV=production

CMD ["bun", ".output/server/index.mjs"]

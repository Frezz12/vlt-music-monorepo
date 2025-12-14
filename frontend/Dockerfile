FROM oven/bun:1.1 AS builder

WORKDIR /app

COPY package.json bun.lockb ./
RUN bun install --frozen-lockfile

COPY . .
RUN bun run build

# ------------------------

FROM oven/bun:1.1 AS runner

WORKDIR /app

COPY --from=builder /app/.output ./.output

EXPOSE 3000

ENV HOST=0.0.0.0
ENV PORT=3000
ENV NODE_ENV=production

CMD ["bun", ".output/server/index.mjs"]

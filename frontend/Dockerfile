# Frontend Dockerfile
FROM oven/bun:1-alpine AS builder

WORKDIR /app

# Copy package files - ИСПОЛЬЗУЙТЕ bun.lock вместо bun.lockb
COPY package.json bun.lock ./

# Install ALL dependencies
RUN bun install

# Copy source code
COPY . .

# Build
RUN bun run build

# Production stage
FROM oven/bun:1-alpine AS runner

WORKDIR /app

# Create non-root user
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

# Copy package files - И СЮДА ТОЖЕ
COPY package.json bun.lock ./

# Install ALL dependencies (без --production)
RUN bun install

# Copy built application
COPY --from=builder --chown=nextjs:nodejs /app/.output ./.output

# Set permissions
RUN mkdir -p /app/.output && chown -R nextjs:nodejs /app/.output

USER nextjs

EXPOSE 3000

ENV HOST=0.0.0.0
ENV PORT=3000
ENV NODE_ENV=production

CMD ["bun", ".output/server/index.mjs"]
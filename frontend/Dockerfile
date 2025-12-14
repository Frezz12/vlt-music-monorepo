# Frontend Dockerfile
FROM node:18-alpine AS builder  # ИСПОЛЬЗУЙТЕ NODE вместо Bun

WORKDIR /app

# Copy package files
COPY package.json package-lock.json ./

# Install dependencies
RUN npm ci

# Copy source code
COPY . .

# Build
RUN npm run build

# Production stage
FROM node:18-alpine AS runner

WORKDIR /app

# Create non-root user
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

# Copy package files
COPY package.json package-lock.json ./

# Install production dependencies
RUN npm ci --only=production

# Copy built application
COPY --from=builder --chown=nextjs:nodejs /app/.output ./.output

# Set permissions
RUN mkdir -p /app/.output && chown -R nextjs:nodejs /app/.output

USER nextjs

EXPOSE 3000

ENV HOST=0.0.0.0
ENV PORT=3000
ENV NODE_ENV=production

CMD ["node", ".output/server/index.mjs"]
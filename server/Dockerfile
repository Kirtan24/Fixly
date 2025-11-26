FROM node:20-alpine AS builder
WORKDIR /app

# Install only production dependencies
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# Copy source
COPY . .

FROM node:20-alpine AS runner
WORKDIR /app

# Install curl for health checks
RUN apk update && apk add curl

# Create a non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy built app and dependencies from builder stage
COPY --from=builder /app /app

USER appuser

ENV NODE_ENV=production
EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1

CMD ["node", "server.js"]

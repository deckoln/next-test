FROM oven/bun:latest as builder
WORKDIR /app

# Copy package files
COPY package.json bun.lockb ./
# Install dependencies
RUN bun install

# Copy source files
COPY . .
# Build the application
RUN bun run build

# Production stage
FROM oven/bun:latest
WORKDIR /app

# Copy built assets from builder
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/node_modules ./node_modules

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3000

# Expose port
EXPOSE 3000

# Start the application
CMD ["bun", "next", "start"]
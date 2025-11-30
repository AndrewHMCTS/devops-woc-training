
#Build app
FROM node:22 AS build
WORKDIR /app

# Copy dependency manifests and install dependencies
COPY src/azure-sa/package*.json ./
RUN npm install

COPY src/azure-sa/ ./

# Run app
FROM node:22 AS final
WORKDIR /app

# Copy node_modules and app from build stage
COPY --from=build /app /app
EXPOSE 3000

# Load environment variables from .env and start app
ENV NODE_ENV=production
CMD ["node", "index.js"]




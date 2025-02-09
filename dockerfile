FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies including lite-server globally
RUN npm config set legacy-peer-deps true && \
    npm install -g lite-server && \
    npm install

# Copy the rest of the application
COPY . .

EXPOSE 3000

CMD ["lite-server", "--host", "0.0.0.0"]
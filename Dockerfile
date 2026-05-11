FROM node:22-alpine
WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev

COPY . ./

ENV DRAWIO_BASE_URL=http://localhost:8080/
ENV DRAWIO_OUTPUT_DIR=/data/diagrams
ENV MCP_LISTEN=0.0.0.0
ENV ALLOWED_HOSTS=localhost,127.0.0.1
ENV OPEN_BROWSER=0
ENV VIEWER_PATH=/app/viewer

EXPOSE 3001
CMD ["npm", "start"]

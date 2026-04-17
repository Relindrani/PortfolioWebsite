FROM node:24-alpine AS build
WORKDIR /app

ENV ASTRO_TELEMETRY_DISABLED=1

COPY package.json package-lock.json ./
RUN npm ci

COPY . ./
RUN npm run build

FROM nginx:1.27-alpine AS runtime
WORKDIR /usr/share/nginx/html

COPY --from=build /app/dist ./
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

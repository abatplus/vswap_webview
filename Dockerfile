FROM node:13.10-alpine as build
WORKDIR /app
ENV PATH /app/node_modules/.bin:$PATH

COPY package.json /app/package.json
COPY package-lock.json /app/package-lock.json

RUN npm install

COPY . .
RUN npm run build

# production environment
FROM nginx:1.16.0-alpine

# Use this as an endpoint for health checking with kubernetes (Content-Type won't be application/json, but 200-OK will be enough).
# The copy command below should fail in case somebody needs "/health" as resource of any sort in the frontend.
RUN echo -e "{\"status\":\"UP\"}" >> /usr/share/nginx/html/health

COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

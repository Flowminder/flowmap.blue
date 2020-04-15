ARG NODE_VERSION=13.12.0-alpine
# pull official base image
FROM node:${NODE_VERSION} as build-deps

# set working directory
WORKDIR /app

# install app dependencies
COPY package.json yarn.lock ./
RUN yarn

# add app
COPY . ./

# build app
RUN yarn run build

FROM node:${NODE_VERSION} as serve

RUN yarn global add serve
WORKDIR /app
COPY --from=build-deps /app/build .
EXPOSE 80
# start app
CMD ["serve", "-p", "80", "-s", "."]

FROM nginx:stable-alpine as prod
COPY --from=build-deps /app/build /usr/share/nginx/html
EXPOSE 80
# start app
CMD ["nginx", "-g", "daemon off;"]
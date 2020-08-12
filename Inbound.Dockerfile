FROM node:12.16.1-alpine as builder
USER root
WORKDIR /opt/inbound-thirdparty-scheme-adapter
RUN apk add --no-cache -t build-dependencies git make gcc g++ python libtool autoconf automake \
    && cd $(npm root -g)/npm \
    && npm config set unsafe-perm true \
    && npm install -g node-gyp 
COPY package.json package-lock.json* /opt/inbound-thirdparty-scheme-adapter/
RUN npm ci
COPY . /opt/inbound-thirdparty-scheme-adapter
FROM node:12.16.1-alpine
WORKDIR /opt/inbound-thirdparty-scheme-adapter

# Create empty log file & link stdout to the application log file
RUN mkdir ./logs && touch ./logs/combined.log
RUN ln -sf /dev/stdout ./logs/combined.log

# Create a non-root user: inbound-thirdparty-scheme-adapter-user 
RUN adduser -D inbound-thirdparty-scheme-adapter-user 
USER inbound-thirdparty-scheme-adapter-user 
COPY --chown=inbound-thirdparty-scheme-adapter-user  --from=builder /opt/inbound-thirdparty-scheme-adapter .

EXPOSE 4005
CMD ["npm", "run", "start:inbound"]

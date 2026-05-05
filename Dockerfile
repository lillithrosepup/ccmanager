FROM oven/bun as builder

WORKDIR /build

COPY package.json bun.lock /build/

RUN bun install --frozen-lockfile
COPY . .
RUN bun run build

FROM oven/bun as prod

WORKDIR /ccmgr
COPY --from=builder /build/server.bin /ccmgr/server.bin
COPY /src/client /ccmgr/client

ENTRYPOINT [ "/ccmgr/server.bin" ]
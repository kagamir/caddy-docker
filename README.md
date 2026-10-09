# Caddy Docker

包含 Cloudflare DNS 和 Layer4 插件的 Caddy 镜像，由 GitHub Actions 构建并发布到 GHCR。

## 构建与发布

- 推送到 `main`：发布 `latest` 和完整提交 SHA 标签。
- 推送 `v*` 标签：发布同名标签和 SHA 标签，不覆盖 `latest`。
- Actions → Build and publish Caddy → Run workflow：手动构建。
- PR：执行双架构构建及插件检查，不上传镜像。
- 支持 `linux/amd64`、`linux/arm64`，使用原生交叉编译，在最终镜像中验证插件。
- 使用内置 `GITHUB_TOKEN`，无需配置 PAT 或 Cloudflare 密钥到 CI。

默认跟随 Caddy 2 的官方 builder/alpine 镜像，插件使用 `latest`；每次构建刷新基础镜像并禁用层缓存。上游升级后需手动运行工作流或推送代码，不会自动监听上游更新。此策略不保证历史构建可复现。生产环境可将 Dockerfile 的版本参数固定为精确版本/插件提交，并按镜像 digest 部署。

镜像：`ghcr.io/kagamir/caddy-docker:latest`。

GHCR 包首次发布通常为私有；如需匿名拉取，在 GitHub 的个人 Packages 页面进入包设置，将可见性设为 Public。私有拉取需要先 `docker login ghcr.io`，使用拥有 `read:packages` 权限的令牌。

## 使用

```sh
cp .env.example .env
# 编辑 .env，填写域名及 Cloudflare API Token
docker compose pull
docker compose up -d
docker compose logs -f caddy
```

Cloudflare Token 仅在运行时注入。授予目标 Zone 的 `Zone:Read` 和 `DNS:Edit` 权限，不要提交 `.env`。

`Caddyfile` 提供 DNS-01 自动签证的 HTTPS 示例。Layer4 已编译进入镜像，但未启用具体 TCP/UDP 路由；按需添加配置和对应端口映射。此镜像不会自动成为正向代理。

## 检查插件

```sh
docker run --rm ghcr.io/kagamir/caddy-docker:latest caddy list-modules
```

输出应包含 `dns.providers.cloudflare`、`layer4`。Docker 构建中也会验证这两个模块；缺失时构建失败。

## 本地构建

```sh
docker build --pull -t caddy-custom .
```

上游资料：
- https://github.com/caddyserver/caddy-docker
- https://github.com/caddy-dns/cloudflare
- https://github.com/mholt/caddy-l4
- https://docs.github.com/en/actions/tutorials/publish-packages/publish-docker-images

---
title: PostgreSQL SSL 加密传输配置
date: 2019-10-26 18:59:44
tags: [PostgreSQL, SSL]
---

# 签名证书

## 快速测试证书
```
openssl req -new -x509 -days 365 -nodes -text -out server.crt \
  -keyout server.key -subj "/CN=dbhost.yourdomain.com"
```
然后
```
chmod og-rwx server.key
```

## 生产环境证书
- 创建根密钥
```
openssl req -new -nodes -text -out root.csr \
  -keyout root.key -subj "/CN=root.yourdomain.com"
chmod og-rwx root.key
```
- 创建根证书
```
openssl x509 -req -in root.csr -text -days 3650 \
  -extfile /etc/ssl/openssl.cnf -extensions v3_ca \
  -signkey root.key -out root.crt
```
> 这里的`-extensions v3_ca`中的`v3_ca` 是在 `/etc/ssl/openssl.cnf`文件中的一个配置。配置要求：
> ```
> [ v3_ca ]
> basicConstraints = critical,CA:TRUE
> subjectKeyIdentifier = hash
> authorityKeyIdentifier = keyid:always,issuer:always
> ```

- 创建服务器密钥并签名
```
openssl req -new -nodes -text -out server.csr \
  -keyout server.key -subj "/CN=dbhost.yourdomain.com"
chmod og-rwx server.key

openssl x509 -req -in server.csr -text -days 365 \
  -CA root.crt -CAkey root.key -CAcreateserial \
  -out server.crt
```

- 创建客户端密钥并签名
```
openssl req -new -nodes -text -out client.csr \
  -keyout client.key -subj "/CN=postgres"
chmod og-rwx client.key

openssl x509 -req -in client.csr -text -days 365 \
  -CA root.crt -CAkey root.key -CAcreateserial \
  -out client.crt
```

- 使用 `JDBC` 连接时，key需要转换为der
```
openssl pkcs8 -topk8 -inform PEM -in client.key -outform DER -nocrypt -out client.key.der
```

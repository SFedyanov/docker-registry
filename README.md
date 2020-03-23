# docker-registry
Own docker registry, with synchronization option.


## Prerequisite

### Docker
```
mkdir data
```

### JQ

Doanlad jq from: "https://stedolan.github.io/jq/"
Put to "sync" folder
Rename to jq

### SSL 
```
mkdir certs
openssl req -newkey rsa:4096 -nodes -sha256 -keyout certs/domain.key -x509 -days 365 -out certs/domain.crt
```

### Auth 
First time
```
mkdir auth
htpasswd -Bc auth/registry.password admin
```
Next
```
htpasswd -B auth/registry.password user
```

### Environment file 
Create file "sync.env" inside "sync" folder
File example:
```
SOURCE_REPO_URL=dockerregistry.sitename.com
SOURCE_REPO_LOGIN=admin
SOURCE_REPO_PASSWORD=password
DEST_REPO_URL=dockeranotherregistry.sitename.com
DEST_REPO_LOGIN=admin
DEST_REPO_PASSWORD=password

```

## How to use
```
./sync.sh
```

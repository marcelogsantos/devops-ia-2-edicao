# 🚀 Guia de Deploy - Encontros Tech

Este documento descreve como fazer deploy da aplicação Encontros Tech nos ambientes de Homologação e Produção.

## 📋 Pré-requisitos

- `kubectl` instalado e configurado
- Conexão com o cluster Kubernetes da DigitalOcean
- Contexto configurado: `do-nyc1-k8s-bootcamp2`

## 🔍 Verificar Configuração

```bash
# Verificar contexto atual
kubectl config current-context

# Deve retornar: do-nyc1-k8s-bootcamp2

# Verificar conexão com cluster
kubectl cluster-info
```

---

## 🟡 Deploy em Homologação

### Usando o script automatizado:

```bash
cd 02-encontros-tech/scripts
./deploy-homologacao.sh
```

### Manualmente:

```bash
# Aplicar manifesto
kubectl apply -f 02-encontros-tech/k8s/manifests-homologacao.yaml

# Verificar rollout
kubectl rollout status deployment/encontros-tech -n homologacao --timeout=5m

# Verificar pods
kubectl get pods -n homologacao -l app=encontros-tech

# Verificar service
kubectl get service -n homologacao encontros-tech
```

**URL:** http://164.90.254.138

---

## 🟢 Deploy em Produção

### Usando o script automatizado (RECOMENDADO):

```bash
cd 02-encontros-tech/scripts
./deploy-producao.sh
```

O script vai:
1. Pedir confirmação (digite 'sim')
2. Aplicar o manifesto
3. Aguardar rollout completo
4. Verificar pods e service
5. Fazer smoke test (HTTP 200)

### Manualmente:

```bash
# Aplicar manifesto
kubectl apply -f 02-encontros-tech/k8s/manifests-producao.yaml

# Verificar rollout
kubectl rollout status deployment/encontros-tech -n producao --timeout=5m

# Verificar pods
kubectl get pods -n producao -l app=encontros-tech

# Verificar service
kubectl get service -n producao encontros-tech

# Testar aplicação
curl http://161.35.254.78
```

**URL:** http://161.35.254.78

---

## 📊 Comandos Úteis

### Ver status dos ambientes:

```bash
# Homologação
kubectl get all -n homologacao

# Produção
kubectl get all -n producao
```

### Ver logs:

```bash
# Homologação
kubectl logs -n homologacao -l app=encontros-tech --tail=50

# Produção
kubectl logs -n producao -l app=encontros-tech --tail=50
```

### Escalar réplicas:

```bash
# Homologação
kubectl scale deployment/encontros-tech -n homologacao --replicas=3

# Produção
kubectl scale deployment/encontros-tech -n producao --replicas=3
```

### Fazer rollback:

```bash
# Homologação
kubectl rollout undo deployment/encontros-tech -n homologacao

# Produção
kubectl rollout undo deployment/encontros-tech -n producao
```

---

## 🔄 Fluxo Recomendado

1. **Desenvolver** → Testar localmente
2. **Deploy em Homologação** → `./deploy-homologacao.sh`
3. **Validar em Homologação** → Testar funcionalidades
4. **Deploy em Produção** → `./deploy-producao.sh`
5. **Validar em Produção** → Smoke tests

---

## 🛡️ Secrets Configurados

Os secrets do banco de dados estão armazenados no Kubernetes:

```bash
# Ver secrets (sem exibir valores)
kubectl get secrets -n homologacao
kubectl get secrets -n producao

# Secrets existentes:
# - db-credentials (credenciais do banco)
# - dockerhub-secret (autenticação DockerHub)
```

---

## 🏗️ Build da Imagem Docker

### Fazer build local:

```bash
cd 02-encontros-tech

# Build
docker build -t buiu0917/bootcamp-encontros-tech:v1 .

# Push para DockerHub
docker push buiu0917/bootcamp-encontros-tech:v1
```

### Atualizar imagem nos manifestos:

Edite os arquivos e altere a tag da imagem:
- `k8s/manifests-homologacao.yaml`
- `k8s/manifests-producao.yaml`

```yaml
image: buiu0917/bootcamp-encontros-tech:v2  # Nova versão
```

---

## 📞 Troubleshooting

### Pods não iniciam:

```bash
# Ver eventos
kubectl describe pod -n homologacao -l app=encontros-tech

# Ver logs detalhados
kubectl logs -n homologacao -l app=encontros-tech --all-containers
```

### Service não responde:

```bash
# Verificar endpoints
kubectl get endpoints -n homologacao encontros-tech

# Verificar LoadBalancer
kubectl get service -n homologacao encontros-tech
```

### Rollback de emergência:

```bash
# Produção
kubectl rollout undo deployment/encontros-tech -n producao
kubectl rollout status deployment/encontros-tech -n producao
```

---

## 📚 Estrutura dos Manifestos

```
k8s/
├── manifests-homologacao.yaml  → Namespace: homologacao
├── manifests-producao.yaml     → Namespace: producao
└── manifests.yaml              → Arquivo base (não usado)
```

**Diferenças entre ambientes:**
- **Homologação:** DEBUG=true, LOG_LEVEL=DEBUG, banco de homologação
- **Produção:** DEBUG=false, LOG_LEVEL=INFO, banco de produção

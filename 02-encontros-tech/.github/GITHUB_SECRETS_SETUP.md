# Configuração de Secrets e Variables no GitHub Actions

Este documento contém as instruções para configurar os secrets e variables necessários para o pipeline de CI/CD funcionar.

## 📋 Pré-requisitos

- Acesso ao repositório no GitHub com permissões de admin
- Token do DockerHub
- Arquivo kubeconfig do cluster Kubernetes

## 🔐 Secrets a Configurar

### 1. DOCKERHUB_TOKEN (Secret)

**Descrição:** Token de acesso do DockerHub para fazer push das imagens

**Como configurar:**
1. Acesse: `Settings` → `Secrets and variables` → `Actions`
2. Clique em `New repository secret`
3. Nome: `DOCKERHUB_TOKEN`
4. Value: `<SEU_TOKEN_DOCKERHUB_AQUI>`
5. Clique em `Add secret`

---

### 2. KUBECONFIG (Secret)

**Descrição:** Configuração do cluster Kubernetes em formato base64

**Como obter o valor:**

O arquivo foi gerado em: `/tmp/kubeconfig-base64.txt`

```bash
# Ver o conteúdo (copie este valor)
cat /tmp/kubeconfig-base64.txt
```

**Como configurar:**
1. Acesse: `Settings` → `Secrets and variables` → `Actions`
2. Clique em `New repository secret`
3. Nome: `KUBECONFIG`
4. Value: Cole o conteúdo do arquivo `/tmp/kubeconfig-base64.txt`
5. Clique em `Add secret`

---

## 📝 Variables a Configurar

### 1. DOCKERHUB_USERNAME (Variable)

**Descrição:** Nome de usuário do DockerHub

**Como configurar:**
1. Acesse: `Settings` → `Secrets and variables` → `Actions`
2. Clique na aba `Variables`
3. Clique em `New repository variable`
4. Nome: `DOCKERHUB_USERNAME`
5. Value: `buiu0917`
6. Clique em `Add variable`

---

## 🚀 Como Funciona o Pipeline

### Triggers

O pipeline é acionado quando:
- **Push** para `main` ou `develop`
- **Pull Request** para `main` ou `develop`
- Alterações no diretório `02-encontros-tech/**`

### Jobs

1. **build-and-test**
   - Executa em toda push/PR
   - Instala dependências Python
   - Roda testes com pytest
   - Faz lint do código

2. **build-docker**
   - Executa apenas em push (não em PR)
   - Faz build da imagem Docker
   - Faz push para DockerHub com tags:
     - `main-<sha>` (branch main)
     - `develop-<sha>` (branch develop)
     - `latest` (apenas main)

3. **deploy-homologacao**
   - Executa apenas em push para `develop`
   - Deploy no namespace `homologacao`
   - URL: http://164.90.254.138

4. **deploy-producao**
   - Executa apenas em push para `main`
   - Deploy no namespace `producao`
   - Roda smoke tests
   - URL: http://161.35.254.78

### Fluxo de Deploy

```
develop → Push → Build → Deploy Homologação
   ↓
   PR aprovado
   ↓
main → Push → Build → Deploy Produção
```

---

## ✅ Verificação

Após configurar os secrets e variables:

1. Faça um commit no código:
```bash
git add .
git commit -m "chore: configure GitHub Actions CI/CD"
git push origin main
```

2. Acesse: `Actions` no GitHub
3. Verifique se o workflow está executando
4. Acompanhe os logs de cada job

---

## 🔧 Comandos Úteis via GitHub CLI

Se você tiver o GitHub CLI instalado:

```bash
# Configurar DOCKERHUB_USERNAME (variable)
gh variable set DOCKERHUB_USERNAME --body "buiu0917"

# Configurar DOCKERHUB_TOKEN (secret)
gh secret set DOCKERHUB_TOKEN --body "<SEU_TOKEN_DOCKERHUB_AQUI>"

# Configurar KUBECONFIG (secret)
cat /tmp/kubeconfig-base64.txt | gh secret set KUBECONFIG
```

---

## 📞 Troubleshooting

### Erro: "Error: ImagePullBackOff"
- Verifique se o DOCKERHUB_TOKEN está correto
- Confirme que a imagem foi criada no DockerHub

### Erro: "Unable to connect to the server"
- Verifique se o KUBECONFIG está em base64
- Confirme que o kubeconfig está válido

### Erro: "deployment not found"
- Certifique-se que os namespaces `producao` e `homologacao` existem
- Verifique se os manifestos estão corretos

---

## 📚 Documentação Adicional

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Docker Build Push Action](https://github.com/docker/build-push-action)
- [Kubectl Setup](https://github.com/Azure/setup-kubectl)

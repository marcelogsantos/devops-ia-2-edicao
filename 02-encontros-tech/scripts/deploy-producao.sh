#!/bin/bash
set -e

echo "🚀 Deploy para Produção"
echo "======================="
echo ""

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configurações
NAMESPACE="producao"
APP_NAME="encontros-tech"

echo -e "${YELLOW}⚠️  ATENÇÃO: Você está fazendo deploy em PRODUÇÃO!${NC}"
echo ""
read -p "Deseja continuar? (digite 'sim' para confirmar): " confirmacao

if [ "$confirmacao" != "sim" ]; then
    echo "Deploy cancelado."
    exit 0
fi

echo ""
echo -e "${BLUE}1. Verificando conexão com cluster...${NC}"
kubectl cluster-info --context do-nyc1-k8s-bootcamp2

echo ""
echo -e "${BLUE}2. Aplicando manifesto em ${NAMESPACE}...${NC}"
kubectl apply -f ../k8s/manifests-producao.yaml

echo ""
echo -e "${BLUE}3. Aguardando rollout...${NC}"
kubectl rollout status deployment/${APP_NAME} -n ${NAMESPACE} --timeout=5m

echo ""
echo -e "${BLUE}4. Verificando pods...${NC}"
kubectl get pods -n ${NAMESPACE} -l app=${APP_NAME}

echo ""
echo -e "${BLUE}5. Verificando service...${NC}"
kubectl get service -n ${NAMESPACE} ${APP_NAME}

echo ""
echo -e "${BLUE}6. Testando aplicação...${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://161.35.254.78)
if [ $HTTP_CODE -eq 200 ]; then
    echo -e "${GREEN}✅ Aplicação respondendo: HTTP $HTTP_CODE${NC}"
else
    echo -e "${YELLOW}⚠️  Aplicação retornou: HTTP $HTTP_CODE${NC}"
fi

echo ""
echo -e "${GREEN}✅ Deploy concluído com sucesso!${NC}"
echo ""
echo "URL: http://161.35.254.78"

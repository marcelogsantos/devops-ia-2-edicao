#!/bin/bash
set -e

echo "🚀 Deploy para Homologação"
echo "=========================="
echo ""

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configurações
NAMESPACE="homologacao"
APP_NAME="encontros-tech"

echo -e "${BLUE}1. Verificando conexão com cluster...${NC}"
kubectl cluster-info --context do-nyc1-k8s-bootcamp2

echo ""
echo -e "${BLUE}2. Aplicando manifesto em ${NAMESPACE}...${NC}"
kubectl apply -f ../k8s/manifests-homologacao.yaml

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
echo -e "${GREEN}✅ Deploy concluído com sucesso!${NC}"
echo ""
echo "URL: http://164.90.254.138"

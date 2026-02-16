#!/bin/bash

# Script simples para configurar OAuth do Gmail

echo "📧 Configuração de OAuth para Gmail"
echo ""
echo "=== PASSO 1 ==="
echo "Abra esta URL no navegador:"
echo ""

# Gera a URL de autorização
node -e "
const { google } = require('googleapis');
const fs = require('fs');
const path = require('path');

const CREDENTIALS_PATH = path.join(process.env.HOME, '.config/openclaw/google-credentials.json');

if (!fs.existsSync(CREDENTIALS_PATH)) {
  console.error('❌ Arquivo credentials.json não encontrado!');
  console.error('Caminho esperado:', CREDENTIALS_PATH);
  process.exit(1);
}

const credentials = JSON.parse(fs.readFileSync(CREDENTIALS_PATH, 'utf8'));
const { client_id, client_secret, redirect_uris } = credentials.installed || credentials.web;

const oauth2Client = new google.auth.OAuth2(client_id, client_secret, redirect_uris[0]);

const authUrl = oauth2Client.generateAuthUrl({
  access_type: 'offline',
  scope: ['https://www.googleapis.com/auth/gmail.readonly', 'https://www.googleapis.com/auth/gmail.send'],
});

console.log(authUrl);
console.log('');
"

echo ""
echo "=== PASSO 2 ==="
echo "1. Faça login com sua conta Google (luanvha2550@gmail.com)"
echo "2. Clique em 'Permitir'"
echo "3. Copie o código que aparece"
echo ""
read -p "Cole o código aqui: " AUTH_CODE

echo ""
echo "=== PASSO 3 ==="
echo "Gerando token..."

node -e "
const { google } = require('googleapis');
const fs = require('fs');
const path = require('path');

const CONFIG_DIR = path.join(process.env.HOME, '.config/openclaw');
const TOKEN_PATH = path.join(CONFIG_DIR, 'gmail-token.json');
const CREDENTIALS_PATH = path.join(CONFIG_DIR, 'google-credentials.json');

if (!fs.existsSync(CONFIG_DIR)) {
  fs.mkdirSync(CONFIG_DIR, { recursive: true });
}

const credentials = JSON.parse(fs.readFileSync(CREDENTIALS_PATH, 'utf8'));
const { client_id, client_secret, redirect_uris } = credentials.installed || credentials.web;

const oauth2Client = new google.auth.OAuth2(client_id, client_secret, redirect_uris[0]);

oauth2Client.getToken('$AUTH_CODE').then(({ tokens }) => {
  fs.writeFileSync(TOKEN_PATH, JSON.stringify(tokens, null, 2));
  console.log('✅ Token salvo em:', TOKEN_PATH);
  console.log('');
  console.log('Gmail configurado com sucesso!');
  console.log('Agora você pode usar: skill:gmail send --to \"destino@email.com\" --subject \"Teste\" --body \"Oi\"');
}).catch(err => {
  console.error('❌ Erro:', err.message);
});
"
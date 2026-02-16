# 🚀 INSTRUÇÕES - Compilação node-llama-cpp OTIMIZADA

## 📋 O QUE FOI MELHORADO

Com ajuda da análise inspirada no agente Llama (excelente em código), criei **3 scripts otimizados**:

1. **compile-native-zf-optimized.sh** - COMPLETO com monitoramento
2. **compilezf.sh** - Simplificado mas robusto
3. **status-compilacao.sh** - Monitorar progresso

## 🎯 MELHORIAS IMPLEMENTADAS

✅ **Timeout settings** (30 min para compilação)
✅ **Monitoramento de recursos** (CPU/RAM em tempo real)
✅ **Verification de recursos mínimos** (RAM: 500MB, Disk: 2GB)
✅ **Retry logic** (até 2 tentativas)
✅ **Múltiplos caminhos** para binários (robustez)
✅ **Backup compacto** (tar.gz pronto para transferir)
✅ **Logging detalhado** (para debug se falhar)
✅ **Progress indicators** (saber onde está)

---

## 🚀 COMO USAR

### Opção 1: Script Completos
```bash
cd /home/moltuser/.openclaw/workspace/scripts
./compile-native-zf-optimized.sh
```

**Este script:**
- Verifica Recursos ✓
- Corrige shell config ✓
- Instala OpenClaw (com 2 tentativas, 30 min timeout) ✓
- Extrai binários ✓
- Cria backup compacto ✓
- Cria log de monitoramento ✓

### Opção 2: Script Simplificado
```bash
cd /home/moltuser/.openclaw/workspace/scripts
./compilezf.sh
```

**Este script:**
- Mais simples mas robusto ✓
- Faz tudo em 4 fases ✓
- Ideal para uso rápido ✓

### Opção 3: Monitorar Progresso (enquanto compila)
```bash
cd /home/moltuser/.openclaw/workspace/scripts
./status-compilacao.sh
```

---

## ⚙️ CONFIGURAÇÕES

**Timeout:** 30 minutos (1800 segundos)
**RAM mínima:** 500 MB
**Disk mínimo:** 2 GB
**Max tentativas:** 2

---

## 📊 O QUE ACONTECE DURANTE EXECUÇÃO

### Fase 1: Preparação (30 seg)
- Fix shell config (/bin/sh)
- Verificar recursos RAM/Disk
- Limpar instalação anterior
- Criar diretórios temporários

### Fase 2: Instalação/Compilação (15-30 min)
- `npm i -g openclaw@2026.2.2`
- Isso compila node-llama-cpp NATIVO ARM64
- High CPU usage (expectável)
- High RAM usage (expectável)

### Fase 3: Extração (30 seg)
- Localizar Llama.node
- Localizar libs (.so)
- Copiar para `/tmp/node-llama-binaries/`
- Criar metadados (info.txt)

### Fase 4: Empacotar (10 seg)
- Criar tar.gz
- Mostrar sumário final

---

## ✅ RESULTADO ESPERADO

**Sucesso = Arquivo criado:**
```
/tmp/node-llama-binaries.tar.gz (6120 KB aprox)
```
Contendo:
- Llama.node (binário principal ARM64)
- libllama.so
- libggml.so
- info.txt (metadados)

---

## 🔄 PRÓXIMOS PASSOS

**No ZenFone:**
1. ✅ Executar `./compilezf.sh` ou `./compile-native-zf-optimized.sh`
2. ✅ Aguardar 15-30 min (não feche terminal)
3. ✅ Confirmar que `/tmp/node-llama-binaries.tar.gz` foi criado
4. ✅ Transferir para seu PC

**No PC:**
5. Descompactar tar.gz
6. Copiar binários para fork do Luan: `prebuilt/linux-arm64-musl/`
7. Modificar package.json scripts
8. Commitar e testar

**No ZenFone (futuro):**
9. Testar instalação do fork:
   ```bash
   npm i -g luanvha2550-hash/openclaw-arm64-musl#v2026.2.2-arm64-musl
   ```

---

## ⚠️ TROUBLESHOOTING

### Erro: "TIMEOUT (mais de 30 min)"
**Solução:**
- Feche outros apps
- Libere mais RAM
- Execute quando não estiver usando o ZenFone
- Ou aumente TIMEOUT_COMPILACAO=1800 para 3600 (1 hora)

### Erro: "RAM insuficiente"
**Solução:**
- Feche todas as apps
- Use swap: `swapon /dev/sdX` (se tiver partição swap)
- Execute quando tiver > 1 GB RAM livre

### Erro: "node-llama-cpp não encontrado"
**Solução:**
- Instalação falhou parcialmente
- Execute `npm uninstall -g openclaw` novamente
- Tente novamente

---

## 📊 MONITORAMENTO

Durante compilação, execute em outro terminal:
```bash
watch -n 5 './status-compilacao.sh'
```

Isso mostra:
- CPU/RAM usage
- Disk space
- Progresso atual
- Logs recentes

---

*Versão otimizada baseada em revisão técnica*
*Data: 2026-02-15*
*Script: compile-native-zf-optimized.sh (10965 bytes)*

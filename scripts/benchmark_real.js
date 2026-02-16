#!/usr/bin/env node

/**
 * benchmark_real.js - Projeto 7: Benchmark Real de Modelos
 * Mede o tempo de resposta REAL via chamadas HTTP para as APIs.
 */

const { spawnSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// Carregar configuração do openclaw.json
const configPath = '/home/moltuser/.openclaw/openclaw.json';
const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
const providers = config.models.providers;

const TEST_PROMPT = 'Responda apenas: OK';
const LOG_FILE = '/home/moltuser/.openclaw/logs/model_performance.jsonl';
const timestamp = new Date().toISOString();

console.log('⏱️ ================================================');
console.log('   BENCHMARK REAL DE MODELOS - Projeto 7');
console.log('⏱️ ================================================\n');
console.log('📋 Testando com prompt: "' + TEST_PROMPT + '"\n');

const results = [];

// ==================== FUNÇÃO DE TESTE NVIDIA ====================
function testNvidiaModel(modelId, label) {
  const apiKey = providers.nvidia.apiKey;
  const baseUrl = providers.nvidia.baseUrl;
  
  const payload = JSON.stringify({
    model: modelId,
    messages: [{ role: 'user', content: TEST_PROMPT }],
    max_tokens: 10,
    temperature: 0.1
  });
  
  const startTime = Date.now();
  
  const result = spawnSync('curl', [
    '-s', '-w', '\n%{http_code}',
    '-X', 'POST',
    `${baseUrl}/chat/completions`,
    '-H', 'Content-Type: application/json',
    '-H', `Authorization: Bearer ${apiKey}`,
    '-d', payload,
    '--max-time', '30'
  ], { encoding: 'utf8' });
  
  const endTime = Date.now();
  const latency = endTime - startTime;
  
  const output = result.stdout.trim();
  const lines = output.split('\n');
  const httpCode = lines[lines.length - 1];
  const responseBody = lines.slice(0, -1).join('\n');
  
  let status = '❌';
  let errorMsg = '';
  
  if (httpCode === '200') {
    status = '✅';
  } else if (httpCode === '000' || result.error) {
    status = '⏱️';
    errorMsg = 'timeout';
  } else {
    try {
      const errorJson = JSON.parse(responseBody);
      errorMsg = errorJson.error?.message || httpCode;
    } catch (e) {
      errorMsg = `HTTP ${httpCode}`;
    }
  }
  
  return { latency, status, errorMsg };
}

// ==================== FUNÇÃO DE TESTE GOOGLE API ====================
function testGoogleApiModel(modelId, label) {
  const apiKey = providers.google.apiKey;
  const baseUrl = providers.google.baseUrl;
  
  const payload = JSON.stringify({
    contents: [{
      parts: [{ text: TEST_PROMPT }]
    }],
    generationConfig: {
      maxOutputTokens: 10,
      temperature: 0.1
    }
  });
  
  const startTime = Date.now();
  
  const result = spawnSync('curl', [
    '-s', '-w', '\n%{http_code}',
    '-X', 'POST',
    `${baseUrl}models/${modelId}:generateContent?key=${apiKey}`,
    '-H', 'Content-Type: application/json',
    '-d', payload,
    '--max-time', '30'
  ], { encoding: 'utf8' });
  
  const endTime = Date.now();
  const latency = endTime - startTime;
  
  const output = result.stdout.trim();
  const lines = output.split('\n');
  const httpCode = lines[lines.length - 1];
  const responseBody = lines.slice(0, -1).join('\n');
  
  let status = '❌';
  let errorMsg = '';
  
  if (httpCode === '200') {
    status = '✅';
  } else if (httpCode === '000' || result.error) {
    status = '⏱️';
    errorMsg = 'timeout';
  } else {
    try {
      const errorJson = JSON.parse(responseBody);
      errorMsg = errorJson.error?.message || httpCode;
    } catch (e) {
      errorMsg = `HTTP ${httpCode}`;
    }
  }
  
  return { latency, status, errorMsg };
}

// ==================== LISTA DE MODELOS ====================
const models = [
  // NVIDIA
  { id: 'moonshotai/kimi-k2.5', label: 'Kimi K2.5', provider: 'NVIDIA', test: testNvidiaModel },
  { id: 'nvidia/nemotron-nano-12b-v2-vl', label: 'Nemotron Nano', provider: 'NVIDIA', test: testNvidiaModel },
  { id: 'nvidia/cosmos-reason2-8b', label: 'Cosmos Reason2', provider: 'NVIDIA', test: testNvidiaModel },
  { id: 'deepseek-ai/deepseek-v3.2', label: 'DeepSeek V3.2', provider: 'NVIDIA', test: testNvidiaModel },
  { id: 'meta/llama-3.1-405b-instruct', label: 'Llama 3.1 405B', provider: 'NVIDIA', test: testNvidiaModel },
  { id: 'z-ai/glm4.7', label: 'GLM4.7', provider: 'NVIDIA', test: testNvidiaModel },
  { id: 'minimaxai/minimax-m2.1', label: 'MiniMax M2.1', provider: 'NVIDIA', test: testNvidiaModel },
  { id: 'meta/llama-3.3-70b-instruct', label: 'Llama 3.3 70B', provider: 'NVIDIA', test: testNvidiaModel },
  { id: 'z-ai/glm5', label: 'GLM5', provider: 'NVIDIA', test: testNvidiaModel },
  
  // Google API
  { id: 'gemma-3-27b-it', label: 'Gemma 3 27B', provider: 'Google API', test: testGoogleApiModel }
];

console.log('| # | Modelo | Provedor | Latência | Status |');
console.log('|---:|:---|:---|:---:|:---:|');

// ==================== EXECUTAR TESTES ====================
models.forEach((model, index) => {
  console.log(`\n🔄 Testando ${model.label}...`);
  
  const result = model.test(model.id, model.label);
  
  const statusText = result.errorMsg ? `${result.status} ${result.errorMsg}` : result.status;
  console.log(`| ${index + 1} | ${model.label} | ${model.provider} | ${result.latency}ms | ${statusText} |`);
  
  results.push({
    timestamp,
    model: model.id,
    label: model.label,
    provider: model.provider,
    latency_ms: result.latency,
    status: result.status === '✅' ? 'success' : 'error',
    error: result.errorMsg || null
  });
});

// ==================== ESTATÍSTICAS ====================
const successResults = results.filter(r => r.status === 'success');

console.log('\n\n📊 ================================================');
console.log('   RESULTADOS DO BENCHMARK REAL');
console.log('📊 ================================================\n');

if (successResults.length > 0) {
  const avgLatency = Math.round(successResults.reduce((sum, r) => sum + r.latency_ms, 0) / successResults.length);
  const minLatency = Math.min(...successResults.map(r => r.latency_ms));
  const maxLatency = Math.max(...successResults.map(r => r.latency_ms));
  
  console.log(`✅ Sucessos: ${successResults.length}/${results.length}`);
  console.log(`📈 Latência média: ${avgLatency}ms`);
  console.log(`⚡ Latência mínima: ${minLatency}ms`);
  console.log(`🐢 Latência máxima: ${maxLatency}ms`);
  
  const sorted = [...successResults].sort((a, b) => a.latency_ms - b.latency_ms);
  console.log('\n🏆 TOP 3 Mais Rápidos:');
  sorted.slice(0, 3).forEach((r, i) => {
    console.log(`  ${i + 1}. ${r.label} (${r.provider}) - ${r.latency_ms}ms`);
  });
} else {
  console.log('❌ Nenhum modelo respondeu com sucesso.');
}

// Salvar resultados
const logDir = path.dirname(LOG_FILE);
if (!fs.existsSync(logDir)) {
  fs.mkdirSync(logDir, { recursive: true });
}

results.forEach(result => {
  fs.appendFileSync(LOG_FILE, JSON.stringify(result) + '\n');
});

console.log(`\n💾 Resultados salvos em: ${LOG_FILE}`);
console.log('✅ Benchmark finalizado.\n');

#!/bin/bash
# GIT PUSH TO FORK - Execute no PC Windows via PowerShell

# Configurações do fork
REPO="git@github.com:luanvha2550-hash/openclaw-arm64-musl.git"
BRANCH="main"

echo "🔧 Clonando fork do Luan..."
git clone $REPO /tmp/openclaw-fork || cd /tmp/openclaw-fork && git pull

cd /tmp/openclaw-fork

echo "📦 Extraindo arquivos preparados..."
tar xzf /tmp/openclaw-arm64-musl-FINAL.tar.gz
cp -r fork-openclaw/* .

echo "📋 Adicionando ao git..."
git add .
git status

echo "💾 Commitando..."
git commit -m "feat: add ARM64 musl native prebuilt binaries

- Add Llama.node (840 KB) NATIVE ARM64 musl
- Add libllama.b7836.so (2.8 MB)
- Add libggml-cpu.so (829 KB)
- Add libggml-base.so (699 KB)
- Add preinstall-fix.sh (fix 'spawn sh ENOENT')
- Add install-with-prebuilt.sh (use prebuilt, skip build)
- Add postinstall-verify.sh (verify installation)

Install time: 15-30 min → 30 seconds ⚡

Target: PostmarketOS / Alpine (musl libc)
Arch: ARM64 aarch64"

echo "🚀 Pushando para GitHub..."
git push origin $BRANCH

echo "✨ FORK DO LUAN ATUALIZADO! ✨"

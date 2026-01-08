#!/bin/bash

# Verifica se o comando backlog existe
if ! command -v backlog &> /dev/null; then
    echo "Backlog.md não encontrado. Instalando globalmente via npm..."
    npm install -g backlog.md

    if [ $? -ne 0 ]; then
        echo "Erro ao instalar Backlog.md. Por favor, instale manualmente com 'npm install -g backlog.md'."
        exit 1
    fi
    echo "Backlog.md instalado com sucesso."
else
    echo "Backlog.md já está instalado."
fi

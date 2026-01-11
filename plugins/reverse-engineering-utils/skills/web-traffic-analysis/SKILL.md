---
name: web-traffic-analysis
description: This skill should be used when the user asks about "HAR analysis", "API extraction", "reverse engineering websites", "traffic analysis", "how to analyze HAR files", "extract API from website", "clean HAR file", or needs tools to analyze web traffic and reverse engineer undocumented APIs.
version: 0.1.0
---

# Web Traffic Analysis & Reverse Engineering

## Overview

This skill provides methodologies and tools for general web reverse engineering, focusing on extracting semantic structure from HTTP Archive (HAR) files and analyzing web traffic to reconstruct API clients.

## Purpose

To assist in transforming raw network logs (HAR files) into clean, structured API definitions that can be easily consumed by LLMs or used to generate client code. It also covers dynamic analysis techniques.

## Knowledge Domains

### 1. HAR Processing (`har-processing.md`)
**When to consult**: User needs to clean, simplify, or reduce the size of a HAR file, or asks about the Python script for HAR analysis.

Contains:
- Python script to filter HAR files.
- Strategy for reducing 50MB+ logs to lightweight JSON.
- Logic for extracting JSON keys and structures.

### 2. Agent Prompts (`agent-prompts.md`)
**When to consult**: User asks for prompts to analyze APIs, or how to ask an AI to reverse engineer an API from logs.

Contains:
- Optimized system prompts for LLMs (Gemini/Claude) to analyze processed HAR data.
- Instructions for identifying authentication patterns and CRUD endpoints.

### 3. JavaScript Deobfuscation (`javascript-deobfuscation.md`)
**When to consult**: User asks about analyzing obfuscated JS, finding hidden keys in code, or tools like de4js and JSimplifier.

Contains:
- Tools for beautifying and deobfuscating JavaScript.
- Python script to extract API keys and endpoints from JS files.
- Manual reverse engineering tips using DevTools.

### 4. Chrome Extensions (`chrome-extensions.md`)
**When to consult**: User asks about recommended browser extensions for traffic analysis (Requestly, ModHeader, etc).

Contains:
- List of top extensions for intercepting and modifying traffic.
- Setup recommendations for preparing data for AI agents.

### 5. Dynamic Analysis (`dynamic-analysis.md`)
**When to consult**: User asks about Mitmproxy, Playwright, handling dynamic tokens, or tools like `har2requests`.

Contains:
- Techniques for intercepting traffic in real-time.
- Browser automation strategies for encrypted payloads.
- Tools for direct conversion (HAR to Python).

## How to Use This Skill

1. **Static Analysis**: If the user has a HAR file, guide them to use the script in `har-processing.md` to clean it.
2. **AI Analysis**: Use the prompt in `agent-prompts.md` to analyze the cleaned output.
3. **Dynamic Analysis**: If static analysis fails (e.g., encryption, rotation), consult `dynamic-analysis.md` for advanced tools.

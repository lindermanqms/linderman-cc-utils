---
name: pje-reverse-engineering
description: This skill should be used when the user asks about "PJe internal structure", "PJe endpoints", "PJe API", "PJe authentication", "PJe download", "PJe automation", "PJe scraping", "how PJe works internally", "reverse engineering PJe", "Chrome extension for PJe", "automating PJe", or needs to consult technical knowledge about the Brazilian court system PJe (TRF5).
version: 0.2.0
---

# PJe Reverse Engineering Knowledge Base

## Overview

This skill provides comprehensive reverse engineering knowledge about the PJe (Processo Judicial Eletrônico) system used by TRF5 (Tribunal Regional Federal da 5ª Região). Use this skill to consult detailed technical information for developing Chrome extensions, automation scripts, and integrations with the PJe system.

## Purpose

The skill consolidates findings from three production projects (3vDash, Assessor Aider, Secretaria Aider) that successfully automated and extended PJe functionality. It serves as an authoritative technical knowledge repository for developers building:

- Chrome extensions for PJe workflow automation
- PDF download mechanisms
- Process management tools
- Task automation systems
- Data extraction pipelines

## Knowledge Domains

### 1. API Endpoints (`api-endpoints.md`)
**When to consult**: User asks about REST endpoints, API requests, process listing, tag management, task operations

Complete catalog of PJe's REST API including:
- Process retrieval and search endpoints
- Tag/label management (create, add, remove, list)
- Task listing and navigation
- Critical quirks (type inconsistencies, required headers)
- Request/response examples in JavaScript and Python

### 2. Authentication (`authentication.md`)
**When to consult**: User asks about login, cookies, sessions, headers, authorization

Authentication mechanisms and session management:
- Cookie-based session authentication
- Custom header requirements (X-pje-usuario-localizacao, etc.)
- Header construction for API calls
- Authentication in different contexts (Chrome extension, Python scripts)
- Session validation and renewal

### 3. Download Mechanisms (`download-mechanisms.md`)
**When to consult**: User asks about downloading PDFs, process files, chunking, ViewState

Techniques for downloading process PDFs:
- JSF ViewState extraction and usage
- 3-step download flow (navigate → extract → POST)
- Complete payload structure (critical: do not simplify!)
- Chunking technique for large files (5MB chunks)
- Implementation in JavaScript and Python/Selenium

### 4. Automation Workflow (`automation-workflow.md`)
**When to consult**: User asks about task automation, process movement, workflow automation, deep linking

Strategies for automating process movement through tasks:
- Deep linking with `iframe=false`
- Interface patterns (Pattern A: Select+Confirm, Pattern B: Direct Button)
- Parameterized executor architecture
- Dynamic control mapping
- JSON dumps of task flows and transitions

### 5. HTML Scraping (`html-scraping.md`)
**When to consult**: User asks about extracting data from HTML, expedientes, parsing PJe pages

Techniques for extracting data from non-JSON responses:
- Expedientes (communications) extraction from RichFaces tables
- CSS selector strategies for robustness
- Regex extraction from unstructured text
- BeautifulSoup and DOM API examples
- Handling dynamic IDs and element variations

### 6. Data Structures (`data-structures.md`)
**When to consult**: User asks about JSON structures, dumps, task mappings, data models

Reference dumps and data structures:
- `fluxo_processual.json`: Task-transition mappings
- `pje_mapa_tarefas.json`: Detailed HTML structure snapshots
- Process entity structure from API responses
- Field descriptions and type conversions

## How to Use This Skill

1. **Start with Overview**: This SKILL.md provides context
2. **Identify Domain**: Determine which reference file(s) contain relevant information
3. **Read Specific Reference**: Consult the appropriate file from `references/` directory
4. **Cross-Reference**: Many topics span multiple files - follow cross-references

## Key Principles from Production Experience

### Critical Headers
All write operations REQUIRE:
- `X-pje-usuario-localizacao: 25555`
- Absence causes silent failures

### Type Inconsistencies
- Adding tag: `idProcesso` must be STRING
- Removing tag: `idProcesso` must be NUMBER
- Always check API documentation in `api-endpoints.md`

### ViewState is Sacred
- Never hardcode `javax.faces.ViewState`
- Always extract from current page
- Required for all form submissions

### Don't Simplify Payloads
- Download form data includes seemingly empty fields
- All fields are necessary (discovered through trial and error)
- Removing fields causes silent failures or HTML error pages

## Language Note

All reference documentation is in **Portuguese** (maintainer's preference). Code examples include English comments where helpful.

## Version History

- **0.1.0**: Initial scaffold
- **0.2.0**: Full consolidation from 3 production projects (3vDash, Assessor Aider, Secretaria Aider)

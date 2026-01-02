# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a **Claude Code plugin marketplace** that hosts custom plugins for Claude Code. The marketplace enables distribution of specialized skills and tools to enhance Claude Code's capabilities.

Currently contains:
- **pje-extensions**: Plugin providing skills for developing Chrome extensions for PJe (Processo Judicial Eletrônico - Brazilian court system, specifically TRF5)

## Architecture

### Marketplace Structure

```
linderman-cc-utils/
├── .claude-plugin/
│   └── marketplace.json          # Marketplace manifest
└── plugins/
    └── {plugin-name}/
        ├── .claude-plugin/
        │   └── plugin.json        # Plugin manifest
        └── skills/
            └── {skill-name}/
                ├── SKILL.md       # Skill definition and metadata
                └── references/    # Progressive disclosure documentation
```

### Plugin System

**Marketplace manifest** (`.claude-plugin/marketplace.json`):
- Defines marketplace owner and registered plugins
- Each plugin entry specifies name, source path, and description

**Plugin manifest** (`plugins/{name}/.claude-plugin/plugin.json`):
- Contains plugin metadata (name, description, version, author)
- Points to skills directory location

### Skills Architecture

Skills use **progressive disclosure** pattern for documentation:

1. **SKILL.md**: Lightweight skill definition (~600 words)
   - Frontmatter with name, description, version, trigger phrases
   - Overview and usage guidance
   - Points to reference documentation

2. **references/**: Detailed domain-specific documentation
   - Only loaded when specific information is needed
   - Each file focuses on a single topic
   - Enables unlimited documentation without context bloat

**Example**: The `pje-reverse-engineering` skill:
- SKILL.md loads initially with overview
- When user asks about "PJe API endpoints", reads `references/api-endpoints.md`
- When user asks about "PJe authentication", reads `references/authentication.md`

## Working with Plugins

### Adding a New Plugin

1. Create directory structure:
   ```bash
   mkdir -p plugins/{plugin-name}/.claude-plugin
   mkdir -p plugins/{plugin-name}/skills
   ```

2. Create plugin manifest at `plugins/{plugin-name}/.claude-plugin/plugin.json`:
   ```json
   {
     "name": "plugin-name",
     "description": "Plugin description",
     "version": "0.1.0",
     "author": {
       "name": "Author Name",
       "email": "email@example.com"
     },
     "skills": "./skills/"
   }
   ```

3. Register plugin in `.claude-plugin/marketplace.json`:
   ```json
   {
     "plugins": [
       {
         "name": "plugin-name",
         "source": "./plugins/plugin-name",
         "description": "Plugin description"
       }
     ]
   }
   ```

### Creating a Skill

1. Create skill directory: `plugins/{plugin-name}/skills/{skill-name}/`

2. Create `SKILL.md` with frontmatter:
   ```yaml
   ---
   name: skill-name
   description: Trigger phrases and when to use this skill
   version: 0.1.0
   ---
   ```

3. Add skill documentation following progressive disclosure:
   - Keep SKILL.md focused on overview and usage
   - Place detailed documentation in `references/` subdirectory
   - Create topic-focused reference files (api-endpoints.md, authentication.md, etc.)

### Skill Trigger Patterns

The `description` field in SKILL.md frontmatter should specify:
- Exact phrases that trigger the skill
- Conceptual questions the skill handles
- Domain knowledge the skill provides

**Example from pje-reverse-engineering**:
```
description: This skill should be used when the user asks about "PJe internal structure", "PJe endpoints", "PJe API", "how PJe works internally", "reverse engineering PJe", or needs to consult technical knowledge about the Brazilian court system PJe (TRF5).
```

## PJe Extensions Plugin

Focused on developing Chrome extensions for the PJe (Processo Judicial Eletrônico) system used by TRF5 (Tribunal Regional Federal da 5ª Região).

### Current Skills

**pje-reverse-engineering**: Knowledge base for PJe's internal architecture
- API endpoint structures and authentication
- Frontend architecture and JavaScript patterns
- Data models and entity relationships
- DOM structure and selectors for extension development

### Reference Documentation Pattern

The skill uses `references/` directory for modular documentation:
- `api-endpoints.md`: REST API catalog, parameters, examples
- `authentication.md`: Auth mechanisms, session management
- `data-models.md`: Entity structures, relationships, validation
- `frontend-architecture.md`: Framework analysis, state management
- `dom-structure.md`: Selectors, form structures, dynamic content
- `network-patterns.md`: AJAX patterns, error handling
- `extension-integration.md`: Best practices for Chrome extensions

As knowledge is gathered through reverse engineering, add focused reference files following this structure.

## Development Workflow

### Modifying Skills

1. Update SKILL.md if changing overview, triggers, or usage patterns
2. Add/update reference files in `references/` for specific documentation
3. Keep reference files focused on single topics for modularity

### Testing Skills

Skills are loaded by Claude Code when:
- The marketplace is active in user's environment
- Trigger phrases from skill descriptions are matched
- User explicitly invokes the skill

### Version Management

When updating:
- Increment skill version in SKILL.md frontmatter
- Increment plugin version in plugin.json if adding/removing skills
- No need to increment marketplace.json version (it's a registry)

## Key Principles

1. **Progressive Disclosure**: Keep initial context lean, load details on-demand
2. **Modular Documentation**: One reference file per topic
3. **Trigger Clarity**: Explicitly define when skills should activate
4. **Domain Focus**: Each skill serves a specific domain or use case

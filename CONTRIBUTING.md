# Contribuindo para PHP Docker Base Images

Obrigado por considerar contribuir para este projeto! Este documento fornece diretrizes para contribuir com o repositório de imagens Docker PHP.

## 🚀 Como Contribuir

### 1. Fork e Clone

```bash
# Fork o repositório no GitHub
git clone https://github.com/SEU_USUARIO/php-docker.git
cd php-docker
```

### 2. Configuração do Ambiente

```bash
# Instale as dependências necessárias
make dev-setup

# Teste o ambiente
make test VERSION=8.3 VARIANT=fpm
```

### 3. Faça suas Mudanças

- Crie uma branch para sua feature: `git checkout -b feature/nova-feature`
- Faça suas modificações seguindo os padrões do projeto
- Teste suas mudanças localmente

### 4. Testes

```bash
# Teste uma imagem específica
make test VERSION=8.3 VARIANT=swoole

# Teste todas as imagens
make test-all

# Build e teste
make build VERSION=8.3 VARIANT=nginx
make test VERSION=8.3 VARIANT=nginx
```

### 5. Commit e Push

```bash
git add .
git commit -m "feat: adiciona suporte para extensão X"
git push origin feature/nova-feature
```

### 6. Pull Request

- Abra um Pull Request no GitHub
- Descreva suas mudanças detalhadamente
- Aguarde a revisão

## 📋 Padrões de Código

### Dockerfile

- Use multi-stage builds quando apropriado
- Ordene comandos RUN do menos para mais frequente
- Use `.dockerignore` para exclusões
- Comente seções complexas
- Mantenha imagens leves

```dockerfile
# ✅ Bom
RUN apk add --no-cache \
    bash \
    curl \
    git \
    && rm -rf /var/cache/apk/*

# ❌ Ruim
RUN apk add bash
RUN apk add curl
RUN apk add git
```

### Scripts Shell

- Use `#!/bin/bash` ou `#!/bin/sh`
- Set `set -e` para parar em erros
- Use variáveis para configurações
- Adicione help/usage functions
- Teste em Alpine Linux

```bash
#!/bin/bash
set -e

# Good
show_help() {
    cat << EOF
Usage: $0 <version> <variant>
...
EOF
}
```

### Configurações

- Use arquivos de configuração separados
- Documente parâmetros importantes
- Mantenha compatibilidade com versões anteriores
- Teste em diferentes cenários

## 🔍 Checklist de PR

Antes de abrir um Pull Request, verifique:

- [ ] **Build**: Todas as imagens fazem build sem erros
- [ ] **Testes**: Todos os testes passam
- [ ] **Documentação**: README e docs atualizados
- [ ] **Versionamento**: Versões adequadas
- [ ] **Security**: Escaneamento de vulnerabilidades
- [ ] **Performance**: Imagens otimizadas
- [ ] **Compatibilidade**: Funciona em AMD64 e ARM64

### Build Local

```bash
# Build específico
make build VERSION=8.3 VARIANT=fpm

# Build all
make build-all

# Test
make test-all
```

### Documentação

- Atualize o README.md se necessário
- Adicione exemplos de uso
- Documente breaking changes
- Mantenha CHANGELOG.md atualizado

## 🏗 Estrutura do Projeto

```
php-docker/
├── fpm/               # Imagens FPM PHP-FPM
├── swoole/            # Variantes Swoole
├── nginx/             # Variantes Nginx
├── frankenphp/        # Variantes FrankenPHP
├── configs/           # Configurações compartilhadas
├── scripts/           # Scripts de build e teste
├── examples/          # Exemplos docker-compose
├── .github/           # GitHub Actions
└── docs/              # Documentação adicional
```

## 🐛 Reportando Bugs

### Antes de Reportar

1. Verifique issues existentes
2. Teste na versão mais recente
3. Reproduza o problema

### Template de Bug Report

```markdown
**Descrição do Bug**
Descrição clara do problema.

**Como Reproduzir**
1. Execute comando X
2. Configure Y
3. Observe erro Z

**Comportamento Esperado**
O que deveria acontecer.

**Ambiente**
- OS: [ex: Ubuntu 20.04]
- Docker: [ex: 24.0.6]
- Versão da Imagem: [ex: php-fpm:8.3-alpine]

**Logs**
```
Cole logs relevantes aqui
```
```

## 💡 Sugestões de Features

### Template de Feature Request

```markdown
**Feature Solicitada**
Descrição clara da feature.

**Motivação**
Por que esta feature é útil?

**Solução Proposta**
Como implementar a feature.

**Alternativas Consideradas**
Outras abordagens possíveis.

**Contexto Adicional**
Screenshots, links, etc.
```

## 🔒 Segurança

### Vulnerabilidades

Para reportar vulnerabilidades de segurança:

1. **NÃO** abra issue público
2. Envie email para: security@lrconsultoria.com.br
3. Inclua detalhes da vulnerabilidade
4. Aguarde resposta em até 48h

### Melhores Práticas

- Use sempre versões estáveis
- Mantenha dependências atualizadas
- Escaneie imagens regularmente
- Use secrets para credenciais

## 📝 Tipos de Commit

Use conventional commits:

- `feat:` Nova feature
- `fix:` Correção de bug
- `docs:` Mudanças na documentação
- `style:` Formatação, ponto e vírgula, etc
- `refactor:` Refatoração de código
- `test:` Adição ou correção de testes
- `chore:` Manutenção, build, etc

### Exemplos

```bash
feat: adiciona suporte para PHP 8.4
fix: corrige configuração nginx para grandes uploads
docs: atualiza README com novos exemplos
chore: atualiza dependências do build
```

## 🏷 Versionamento

Seguimos [Semantic Versioning](https://semver.org/):

- **MAJOR**: Mudanças incompatíveis
- **MINOR**: Novas features compatíveis
- **PATCH**: Correções compatíveis

### Tags de Imagem

- `8.3-alpine` - Versão específica
- `8.3` - Alias para alpine
- `latest` - Versão mais recente estável

## 🤝 Código de Conduta

### Nosso Compromisso

Comprometemo-nos a fazer da participação em nosso projeto uma experiência livre de assédio para todos.

### Comportamentos Esperados

- Usar linguagem acolhedora e inclusiva
- Respeitar diferentes pontos de vista
- Aceitar críticas construtivas
- Focar no que é melhor para a comunidade

### Comportamentos Inaceitáveis

- Linguagem ou imagens sexualizadas
- Trolling, comentários ofensivos
- Assédio público ou privado
- Publicar informações privadas

### Enforcement

Casos de comportamento inaceitável podem ser reportados para moderation@lrconsultoria.com.br.

## 📞 Suporte

- **Issues**: Para bugs e features
- **Discussions**: Para perguntas gerais
- **Email**: devops@lrconsultoria.com.br
- **Discord**: [Link do servidor]

## 📄 Licença

Ao contribuir, você concorda que suas contribuições serão licenciadas sob a mesma licença MIT do projeto.

---

**Obrigado por contribuir! 🚀**

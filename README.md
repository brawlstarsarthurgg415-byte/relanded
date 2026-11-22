# RELANDED

Projeto de jogo de sobrevivência 3D em mundo aberto, preparado como projeto **C++ para Unreal Engine 5**.

> A estrutura inicial Unreal já foi adicionada. O jogo ainda está em fase de fundação: não há mapa jogável, personagens, modelos 3D, animações ou APK Unreal prontos. O projeto web/Capacitor antigo em `www/` foi preservado.

## Visão do jogo

- Sobrevivência e exploração em uma ilha tropical.
- Perspectivas alternáveis: primeira pessoa, terceira pessoa e um modo experimental de câmera frontal.
- Campanha principal planejada para pelo menos 2 horas de conteúdo jogável.
- Coleta, crafting, construção, combate, veículos e eventos ambientais.
- Cinco peças de avião como objetivo central da história.

## Estrutura Unreal

```text
Relanded/
├── Relanded.uproject
├── Config/
├── Content/
│   ├── Characters/
│   ├── Environment/
│   ├── Props/
│   ├── Weapons/
│   ├── Vehicles/
│   ├── Animations/
│   ├── Materials/
│   ├── Audio/
│   └── UI/
├── Plugins/
├── Source/
│   ├── Relanded/
│   ├── Relanded.Target.cs
│   └── RelandedEditor.Target.cs
└── .github/workflows/
```

O módulo C++ inicial contém o ponto de entrada do jogo e uma classe GameMode básica. É apenas o esqueleto inicial, não a implementação dos sistemas de sobrevivência.

## Abrir no Unreal Editor

1. Baixe ou clone o repositório em um computador com Unreal Engine 5 instalada.
2. Abra `Relanded.uproject` com a Unreal Engine instalada. Como a associação da versão está em branco, selecione a versão instalada quando o Launcher/Editor solicitar.
3. Se solicitado, gere os arquivos do projeto C++ e compile o módulo `Relanded`.
4. Abra o projeto no Editor.

A estrutura C++ foi escrita para a linha Unreal Engine 5.5 ou mais recente. Se estiver usando uma versão diferente, os arquivos Target.cs podem precisar de ajuste.

## Verificação automática

O workflow **Unreal project structure check** valida o JSON do `.uproject` e a presença dos arquivos essenciais do módulo C++. Ele não compila o jogo nem substitui o Unreal Build Tool.

## Git LFS

Assets binários grandes do Unreal (por exemplo `.uasset`, `.umap`, modelos e áudio) devem ser versionados com Git LFS. Depois de instalar Git LFS, execute:

```bash
git lfs install
git lfs pull
```

Confira a cota e o armazenamento LFS disponíveis na conta GitHub antes de enviar muitos assets.

## Compilação Android

O GitHub Actions padrão não inclui Unreal Engine 5 pré-instalada. A compilação automatizada do jogo exigirá um runner Windows self-hosted com uma versão compatível da Unreal Engine, Android SDK/NDK e configuração de build Android.

**Ainda não existe APK Unreal compilado.** O workflow antigo de APK pertence à versão web empacotada com Capacitor e não compila o projeto Unreal.

## Estado atual

- [x] Repositório existente preservado.
- [x] Regras iniciais de Git ignore e Git LFS adicionadas.
- [x] Descritor `.uproject` e módulo C++ inicial adicionados.
- [x] Workflow de validação estrutural adicionado.
- [ ] Abrir e compilar o projeto no Unreal Editor.
- [ ] Criar o mapa inicial e os sistemas jogáveis.
- [ ] Integrar assets 3D com licenças compatíveis.
- [ ] Configurar e validar a compilação Android.
- [ ] Compilar e testar o primeiro APK em dispositivo.

Recursos como ray tracing e frame generation dependerão do hardware e das APIs suportadas. O projeto deverá oferecer configurações alternativas para Android sem suporte a esses recursos.

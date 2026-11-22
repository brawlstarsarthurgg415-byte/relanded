# RELANDED

Projeto de jogo de sobrevivência 3D em mundo aberto, desenvolvido com **Unreal Engine 5**, com foco em Android.

> Este repositório está sendo preparado para receber o projeto Unreal. O conteúdo web/Capacitor existente em `www/` será preservado durante a migração até que a nova versão seja validada.

## Visão do jogo

- Sobrevivência e exploração em uma ilha tropical.
- Perspectivas alternáveis: primeira pessoa, terceira pessoa e um modo experimental de câmera frontal (segunda pessoa).
- Campanha principal planejada para pelo menos 2 horas de conteúdo jogável.
- Coleta, crafting, construção, combate, veículos e eventos ambientais.
- Cinco peças de avião como objetivo central da história.

## Estrutura planejada do projeto

Quando o projeto Unreal for criado, o arquivo `Relanded.uproject` ficará na raiz:

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
├── .gitattributes
└── .gitignore
```

## Git LFS

Assets binários grandes do Unreal (por exemplo `.uasset`, `.umap`, modelos e áudio) devem ser versionados com Git LFS. Depois de instalar Git LFS, execute:

```bash
git lfs install
git lfs pull
```

Confira a cota e o armazenamento LFS disponíveis na conta GitHub antes de enviar muitos assets.

## Compilação

O GitHub Actions não inclui Unreal Engine 5 pré-instalado. A compilação automatizada do jogo exigirá um runner Windows self-hosted com uma versão compatível da Unreal Engine, Android SDK/NDK e configuração de build Android.

**Não há APK Unreal configurado neste momento.** O workflow antigo de APK pertence à versão web empacotada com Capacitor e não compila um projeto Unreal.

## Requisitos de desenvolvimento

- Unreal Engine 5 instalada localmente.
- Android Studio/SDK e NDK compatíveis com a versão da Unreal.
- Git e Git LFS.
- Espaço em disco para engine, projeto, Derived Data Cache e assets.

## Estado atual

- [x] Repositório existente identificado e preservado.
- [x] Regras iniciais de Git ignore e Git LFS adicionadas.
- [ ] Projeto Unreal (.uproject) criado e enviado.
- [ ] Configuração Android da Unreal validada.
- [ ] Runner de build Unreal configurado.
- [ ] Primeiro APK compilado e testado em dispositivo.

Recursos como ray tracing e frame generation dependerão do hardware e das APIs suportadas. O projeto deverá oferecer configurações alternativas para Android sem suporte a esses recursos.

# Compilação do Relanded na nuvem

Este repositório tem um workflow manual preparado para compilar o projeto Unreal para Android. Ele **não cria uma máquina na nuvem**: primeiro é necessário configurar uma VM Windows compatível e instalar nela o Unreal Engine e as ferramentas Android.

## Requisitos da máquina remota

- Windows 10/11 64-bit.
- Unreal Engine 5.5 (a estrutura C++ atual foi preparada para UE 5.5).
- Git e Git LFS.
- Android SDK, Android NDK e JDK em versões suportadas pela versão do Unreal instalada.
- Espaço livre suficiente para o Engine, o projeto e os arquivos intermediários.
- GPU compatível com o Unreal Editor; para trabalhar visualmente pelo celular, também será necessário acesso remoto à área de trabalho.
- Conexão de rede estável.

A máquina deve ser configurada por um adulto responsável quando houver contratação, cartão ou dados de pagamento envolvidos. Não compartilhe senhas, tokens ou chaves no chat.

## Configuração do GitHub Actions runner

1. No GitHub, abra Settings → Actions → Runners → New self-hosted runner.
2. Selecione Windows x64 e siga as instruções oficiais exibidas pelo GitHub para registrar o runner.
3. Configure as etiquetas adicionais: `unreal` e `android`.
4. Configure a variável de ambiente de sistema `UE_ROOT` apontando para a instalação do Unreal, por exemplo `C:\Program Files\Epic Games\UE_5.5`.
5. Configure `ANDROID_HOME` ou `ANDROID_SDK_ROOT` para a pasta do Android SDK.
6. Reinicie o serviço do runner depois de alterar variáveis de ambiente.

**Importante:** use um runner dedicado e privado para este repositório. Não execute trabalhos de pull requests de pessoas desconhecidas nessa máquina.

## Como iniciar

Depois que o runner estiver online no GitHub:

1. Abra Actions → Build Relanded for Android (cloud runner).
2. Toque em Run workflow.
3. Escolha Development para a primeira compilação.
4. Quando terminar, baixe o artefato `relanded-android`.

## Limitações atuais

- O workflow não instala Unreal Engine automaticamente.
- O workflow não cria nem paga a VM.
- O primeiro build pode falhar até o SDK/NDK/JDK e as configurações Android estarem corretos.
- O projeto ainda é apenas o esqueleto C++ inicial; não é um jogo completo.
- Este workflow não foi executado porque ainda não existe um runner Unreal/Android conectado.

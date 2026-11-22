# Relanded — sobrevivência 3D para Android

Projeto Godot 4.5.1, renderizador Compatibility, exportação Android ARM64.

## Sistemas implementados

- Ilha 3D construída com tiles de areia e modelos GLB externos de vegetação, dunas, formações rochosas e caverna, baixados durante a compilação (ver `ASSET_SOURCES.md`).
- Personagem 3D, câmera em terceira pessoa e controles por toque: lado esquerdo para mover e lado direito para olhar.
- Sobrevivência: vida, fome, sede, fôlego, temperatura corporal e oxigênio ao mergulhar.
- Ciclo de dia/noite com iluminação solar dinâmica e alternância de clima.
- Exploração e coleta de água, cocos, madeira, fibras, ervas, conchas, pedras e sucata.
- Mochila com limite de carga, evolução de nível e experiência.
- Fabricação de abrigo, fogueira, roupa térmica, ataduras, vara de pesca e mochila ampliada.
- Pesca na costa, cozinha quando há fogueira e recuperação de necessidades com comida/água.
- Diário com sequência de objetivos: suprimentos iniciais, abrigo e investigação dos destroços.
- Recursos reaparecem com a passagem dos dias.
- Salvamento local no Android, botão SALVAR e salvamento automático ao voltar ao menu/sair.
- Opções de qualidade gráfica e escala 3D.

## Controles no celular

- Arraste no lado esquerdo: movimentar.
- Arraste no lado direito: girar a câmera.
- MOCHILA: ver itens, comer coco e beber água.
- CRIAR: fabricar equipamentos e estruturas.
- CORRER: alternar corrida (consome fôlego).
- PESCAR: pescar quando estiver perto da água e possuir vara.
- MERGULHAR: mergulho enquanto estiver nadando.
- SALVAR: gravar progresso no aparelho.
- MISSÃO: consultar o diário.

## Compilar

O workflow `.github/workflows/godot-android.yml` baixa o Godot, os templates Android e os modelos licenciados, importa os recursos e exporta o APK ARM64. O APK também é publicado como arquivo direto na Release `android-latest`.

## Estado do projeto

A campanha principal tem uma sequência inicial de objetivos e o modo solo já possui progressão/salvamento. Multiplayer com sincronização de jogadores, fauna com IA, combate, missões secundárias, áudio e polimento final ainda são etapas futuras; a tela de rede não representa multiplayer completo.

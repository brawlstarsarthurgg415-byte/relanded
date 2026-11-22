# RELANDED

Jogo de sobrevivência 3D para Android. **Engine principal: Godot 4.5.1 (GDScript).**

## Por que Godot
Godot é gratuito, open source, leve e exporta diretamente para Android. Ao contrário do projeto Unreal anterior, a compilação pode rodar em um runner Linux padrão do GitHub Actions, sem exigir um computador Windows com Unreal Engine instalado.

## Projeto atual
O projeto jogável está em `godot/`. A primeira fundação inclui:
- cenário 3D de ilha tropical, oceano, árvores e destroços;
- personagem 3D com câmera em terceira pessoa;
- controles básicos de teclado e toque;
- renderizador Compatibility para melhor alcance em celulares Android.

O objetivo é evoluir a partir dessa base para exploração, coleta, crafting, construção, eventos e a campanha de fuga da ilha.

## Gerar APK
O workflow **Build Relanded Android APK (Godot)** roda automaticamente quando arquivos em `godot/` mudam e também pode ser iniciado manualmente em GitHub Actions.

1. Abra a aba **Actions** do repositório.
2. Selecione **Build Relanded Android APK (Godot)**.
3. Toque em **Run workflow**.
4. Quando terminar, abra a execução e baixe o artefato **Relanded-Android-APK**.

O workflow instala Godot 4.5.1, templates Android, Java 17 e Android SDK no runner hospedado pelo GitHub. O APK só estará pronto depois que uma execução terminar com sucesso.

## Projeto Unreal antigo
Os arquivos Unreal anteriores foram mantidos como referência, mas não são mais a engine principal nem são usados pelo workflow Android.

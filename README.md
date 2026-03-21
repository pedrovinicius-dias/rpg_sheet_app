# 🐉 D&D Sheet App

Aplicativo cross-platform para gerenciamento de fichas de D&D 5e.  
Funciona 100% offline. Dados salvos no próprio dispositivo.

**Plataformas:** Android · iOS · Windows · macOS · Linux

---

## 📦 Como rodar o projeto

### Passo 1 — Instalar o Flutter

1. Acesse: https://docs.flutter.dev/get-started/install
2. Escolha seu sistema operacional e siga o guia oficial
3. Ao final, rode no terminal:
   ```
   flutter doctor
   ```
   Todos os itens devem estar ✅ (exceto itens que não se aplicam)

> **Dica para Windows:** Instale o Flutter via Chocolatey ou faça o download direto do .zip  
> **Dica para macOS:** Use o Homebrew: `brew install flutter`

---

### Passo 2 — Abrir o projeto no VS Code

1. Instale o VS Code: https://code.visualstudio.com
2. No VS Code, instale as extensões:
   - **Flutter** (by Dart Code)
   - **Dart** (by Dart Code)
3. Abra a pasta do projeto:
   - `File > Open Folder` → selecione a pasta `dnd_sheet_app`

---

### Passo 3 — Instalar as dependências

No terminal (dentro da pasta `dnd_sheet_app`):
```bash
flutter pub get
```

---

### Passo 4 — Rodar o app

#### No celular Android (recomendado para testar)
1. Ative o **Modo Desenvolvedor** no Android:
   - Configurações → Sobre o telefone → Toque 7x em "Número da versão"
2. Ative a **Depuração USB**:
   - Configurações → Opções do desenvolvedor → Depuração USB ✅
3. Conecte o celular ao PC via USB
4. No terminal:
   ```bash
   flutter run
   ```

#### No Windows (desktop)
```bash
flutter run -d windows
```

#### No Linux (desktop)
```bash
flutter run -d linux
```

#### No macOS (desktop)
```bash
flutter run -d macos
```

#### No emulador Android (Android Studio)
1. Instale o Android Studio: https://developer.android.com/studio
2. Crie um emulador em: Tools → AVD Manager
3. Inicie o emulador, depois:
   ```bash
   flutter run
   ```

---

### Passo 5 (opcional) — Gerar APK para instalar no celular

```bash
flutter build apk --release
```

O APK será gerado em:
```
build/app/outputs/flutter-apk/app-release.apk
```

Copie para o celular e instale. Pode ser necessário permitir "Instalar de fontes desconhecidas" nas configurações do Android.

---

## 🗂️ Estrutura do Projeto

```
lib/
├── main.dart                    # Ponto de entrada
├── app.dart                     # MaterialApp + tema
├── core/
│   ├── constants/               # Cores, constantes D&D
│   ├── theme/                   # Tema escuro (estilo pergaminho)
│   └── utils/stat_calculator.dart  # Fórmulas D&D 5e
├── database/
│   └── database_helper.dart     # SQLite local
├── models/
│   └── character.dart           # Character, Attack, Spell, SpellSlot
├── repositories/
│   └── character_repository.dart
├── providers/
│   └── character_provider.dart  # Riverpod state management
└── screens/
    ├── home_screen.dart          # Lista de personagens
    ├── character_screen.dart     # Ficha com 3 abas
    ├── create_character_screen.dart
    └── character/tabs/
        ├── sheet_tab.dart        # Ficha (Pág. 1)
        ├── details_tab.dart      # Detalhes/Lore (Pág. 2)
        └── spells_tab.dart       # Grimório (Pág. 3)
```

---

## 🎮 Como usar o app

1. **Tela inicial** — mostra todos os seus personagens em grid
2. **Nova Ficha** — botão + abre o wizard de criação
3. **Ficha Principal (aba FICHA)**
   - Toque nos atributos (FOR, DES...) para editar
   - Toque nas perícias para alternar: sem proficiência → proficiente → expertise
   - Toque nas salvaguardas para marcar proficiência
   - Botões +1/-1 no HP para combate rápido
   - Arraste ataques para a esquerda para deletar
4. **Aba DETALHES** — aparência, história, aliados
5. **Aba MAGIAS** — grimório com todos os círculos
   - Toque nos círculos vermelhos para marcar espaços usados
   - Toque no número para editar total de espaços
6. **Salvar** — botão 💾 no canto superior direito
7. **Deletar personagem** — pressione e segure o card na tela inicial

---

## ❓ Perguntas frequentes

**O app precisa de internet?**  
Não. É 100% offline. Todos os dados ficam no seu dispositivo.

**Onde ficam os dados salvos?**  
- Banco de dados: pasta de documentos do app (gerenciado automaticamente)
- Imagens: `Documentos/dnd_sheet_app/characters/<id>/`

**Posso usar no iOS?**  
Sim, mas precisa de um Mac com Xcode para compilar.

**Tem backup?**  
Ainda não. É uma funcionalidade planejada para a próxima versão.

---

## 🔧 Dependências principais

| Pacote | Uso |
|---|---|
| `sqflite` | Banco de dados SQLite local |
| `flutter_riverpod` | Gerenciamento de estado |
| `image_picker` | Selecionar fotos da galeria |
| `google_fonts` | Fontes temáticas (Cinzel, Crimson Text) |
| `uuid` | IDs únicos para personagens e magias |
| `path_provider` | Localização de diretórios no dispositivo |

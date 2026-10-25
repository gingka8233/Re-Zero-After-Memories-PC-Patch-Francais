# Re:Zero – After Memories | Patch français 🇫🇷

**Traduction française non officielle du visual novel fangame _Re:Zero – After Memories_.**

Ce projet permet de jouer au fangame en français, avec des dialogues adaptés à l'univers de *Re:Zero*, les caractères accentués et l'écran des commandes traduit.

> [!IMPORTANT]
> Ce dépôt distribue **uniquement un patch de traduction**, pas le jeu original. Il faut posséder l'exécutable anglais compatible pour l'appliquer.

## ✨ Contenu du patch

- **204 répliques** traduites et revérifiées ;
- Traduction contextualisée : noms, surnoms et façon de parler des personnages.
- Prise en charge des **accents français** et de la ponctuation.
- Menus et **écran des commandes en français**.
- Patch qui crée une version française séparée, **sans modifier l'EXE anglais**.
- Tableau `dialogues_fr_v5_comparaison.csv` pour faciliter les corrections.

## 📥 Installation

### Prérequis

- Un PC sous **Windows** (le jeu et le patch sont conçus pour Windows).
- Le jeu anglais original :
  - `Re Zero After Memories.exe` (**archive auto-extractible d'origine**) ; **ou**
  - `Re_Zero_After_Memories.exe` (**exécutable anglais déjà extrait**).
- L'archive du patch `Patch_FR_ReZero_After_Memories_v5_depuis_anglais.zip`, à récupérer dans les **Releases** de ce dépôt.

### Étapes

1. **Décompressez entièrement** l'archive du patch dans un dossier.
2. Glissez-déposez le fichier `.exe` anglais original sur **`Appliquer_patch_FR_V5.cmd`**.
3. Le script vérifie la version du jeu, applique la traduction et affiche le résultat.
4. Ouvrez le dossier **`ReZero_After_Memories_FR_v5`** créé à côté de votre EXE anglais.
5. Lancez **`Re_Zero_After_Memories_FR_v5.exe`** pour jouer en français.

Le fichier anglais d'origine est conservé. Si un dossier de sortie existe déjà, le patch crée un nouveau dossier avec un suffixe numérique.

**À noter :** si vous partez de l'EXE anglais *déjà extrait*, conservez dans le même dossier `D3DX9_43.dll`, `options.ini` et les musiques `.ogg`. Si vous partez de l'archive auto-extractible originale, le script récupère automatiquement ces ressources.

## 🔧 Problèmes fréquents

| Problème | Solution |
| --- | --- |
| « EXE non reconnu » | Le patch accepte seulement la version anglaise d'origine prise en charge, pas un EXE français ou modifié. |
| Musique absente | Si vous patchez l'EXE anglais extrait, vérifiez que les fichiers `.ogg` sont présents à côté de celui-ci. |
| DLL manquante | Vérifiez la présence de `D3DX9_43.dll` dans le dossier du jeu. |
| Accents ou caractères incorrects | Utilisez la **V5** du patch, sans mélanger les fichiers avec d'anciennes versions. |
| Le script ne se lance pas | Vérifiez que le ZIP a été entièrement décompressé et que les fichiers `.cmd` et `.ps1` se trouvent ensemble. |

Le patch utilise **PowerShell et les outils intégrés à Windows** ; aucun installateur supplémentaire n'est nécessaire.

## ✅ Compatibilité et vérification

Le patch contrôle l'empreinte **SHA-256** de l'EXE anglais avant de le modifier. Versions sources acceptées :

| Fichier | SHA-256 |
| --- | --- |
| `Re Zero After Memories.exe` | `5f0b155751723ae0bc1525e7f927f5d58583ce62439837db14b607bbcad0d148` |
| `Re_Zero_After_Memories.exe` (anglais extrait) | `dbf2308c35634a844aeba1bd713a9b1b1cdff57977b78cc48412f2412e3a8456` |

L'exécutable FR V5 généré doit avoir cette empreinte :

```text
5559ada92117146ef1b1b8f8873036177c44b0ec53d349d0e796c232f69cec49
```

Pour vérifier un fichier sous PowerShell :

```powershell
Get-FileHash -Algorithm SHA256 "C:\chemin\vers\votre\fichier.exe"
```

## 📝 Historique des versions

| Version | Modifications principales |
| --- | --- |
| **V5** | Relecture finale et 36 répliques affinées ; patch applicable directement sur l'EXE anglais. |
| **V4** | Dialogues rendus plus naturels et mieux adaptés aux personnages de *Re:Zero*. |
| **V3** | Correction de la table des glyphes : accents, lettres et ponctuation fonctionnels. |
| **V1** | Première traduction française des dialogues et de l'interface. |

## 🐛 Signaler une erreur

Si vous trouvez une faute, une réplique étrange, un problème d'affichage ou un texte qui dépasse, ouvrez une **Issue** et indiquez, si possible :

- La scène et le personnage concernés.
- La phrase affichée et la correction proposée.
- Une capture d'écran (facultative).
- La version du patch utilisée.

Le fichier `dialogues_fr_v5_comparaison.csv` fournit une correspondance entre l'anglais, la V4 et la V5.

## ❤️ Crédits et mentions

Ce projet est une **traduction de fans non officielle**. Il n'est affilié ni aux créateurs du fangame, ni aux ayants droit de *Re:Zero*.

Le jeu, les illustrations, les musiques, les personnages, les marques et les œuvres d'origine restent la propriété de leurs auteurs et ayants droit respectifs. Les crédits originaux doivent être conservés.

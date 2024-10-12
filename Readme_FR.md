<div align="center">
  <img alt="logo" height="200px" src="assets/maid.png">
</div>

# Maid - Distribution Mobile de l'Intelligence Artificielle

<div align="center">

[![Build Android](https://github.com/Mobile-Artificial-Intelligence/maid/actions/workflows/build-android.yml/badge.svg)](https://github.com/Mobile-Artificial-Intelligence/maid/actions/workflows/build-android.yml)
[![Build Linux](https://github.com/Mobile-Artificial-Intelligence/maid/actions/workflows/build-linux.yml/badge.svg)](https://github.com/Mobile-Artificial-Intelligence/maid/actions/workflows/build-linux.yml)
[![Build MacOS](https://github.com/Mobile-Artificial-Intelligence/maid/actions/workflows/build-macos.yml/badge.svg)](https://github.com/Mobile-Artificial-Intelligence/maid/actions/workflows/build-macos.yml)
[![Build Windows](https://github.com/Mobile-Artificial-Intelligence/maid/actions/workflows/build-windows.yml/badge.svg)](https://github.com/Mobile-Artificial-Intelligence/maid/actions/workflows/build-windows.yml)

</div>

<div align="center">
<a href="https://f-droid.org/packages/com.danemadsen.maid/">
  <img 
    src="https://fdroid.gitlab.io/artwork/badge/get-it-on.png"
    alt="Disponible sur F-Droid"
    height="80"
  >
</a>
<a href='https://play.google.com/store/apps/details?id=com.danemadsen.maid&pcampaignid=pcampaignidMKT-Other-global-all-co-prtnr-py-PartBadge-Mar2515-1'>
  <img 
    src='https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png'
    alt='Disponible sur Google Play'
    height="80"
  />
</a>
</div>

Maid est une application multiplateforme, gratuite et open-source pour interfacer avec les modèles de **llama.cpp** localement, et à distance avec Ollama, Mistral, Google Gemini et OpenAI. Maid supporte les cartes de personnages **sillytavern** pour interagir avec tous vos personnages favoris. Maid permet de télécharger une liste de modèles soigneusement sélectionnés directement depuis Huggingface.

[![](https://dcbadge.limes.pink/api/server/https://discord.com/invite/yEQ6SJny)](https://discord.com/invite/yEQ6SJny)

<div align="center">
  <table>
    <tr>
      <td><img src="media/mobile_demo_1.jpg" width="200" /></td>
      <td><img src="media/mobile_demo_2.jpg" width="200" /></td>
      <td><img src="media/mobile_demo_3.jpg" width="200" /></td>
    </tr>
    <tr>
      <td><img src="media/mobile_demo_4.jpg" width="200" /></td>
      <td><img src="media/mobile_demo_5.jpg" width="200" /></td>
      <td><img src="media/mobile_demo_6.jpg" width="200" /></td>
    </tr>
  </table>
  <img src="media/desktop_demo_1.png" width="800" />
  <img src="media/desktop_demo_2.png" width="800" />
  <img src="media/desktop_demo_3.png" width="800" />
</div>

## Clonage
Maid utilise des sous-modules Git de manière intensive. Pour cloner le dépôt, utilisez la commande suivante :

```bash
git clone --recursive https://github.com/Mobile-Artificial-Intelligence/maid.git
```

Maid utilise Flutter comme sous-module Git. Cela est nécessaire pour des builds reproductibles sur F-Droid. Cependant, pour le développement, vous pouvez utiliser une installation locale de Flutter. Retirez le sous-module Flutter en exécutant la commande Git suivante :

```bash
git submodule deinit -f packages/flutter
```
## Installation des dépendances de build

Pour installer les dépendances sur les systèmes basés sur Fedora, utilisez la commande suivante :

```bash
sudo dnf install -y cmake ninja-build pkg-config gtk3-devel vulkan-devel
```
Pour installer les dépendances sur les systèmes basés sur Debian, utilisez la commande suivante :

```
sudo apt-get install -y cmake ninja-build pkg-config libgtk-3-dev libvulkan-dev
```
## Support des plateformes
Windows, MacOS, Linux, Android.  
[Page des versions.](https://github.com/Mobile-Artificial-Intelligence/maid/releases)  
Les versions iOS ne sont pas disponibles pour le moment.

## Aide demandée
- Écrire des commentaires de code
- Documentation
- Tests et builds sur iOS
- Faire connaître le projet
- [Tests Google Play](https://github.com/Mobile-Artificial-Intelligence/maid/discussions/499)

## Remerciements spéciaux et projets connexes
- [ggerganov/llama.cpp](https://github.com/ggerganov/llama.cpp)
- [ollama/ollama](https://github.com/ollama/ollama)
- [davidmigloz/langchain_dart](https://github.com/davidmigloz/langchain_dart)
- [Mobile-Artificial-Intelligence/maid_llm](https://github.com/Mobile-Artificial-Intelligence/maid_llm)
- [Mobile-Artificial-Intelligence/babylon_tts](https://github.com/Mobile-Artificial-Intelligence/babylon_tts)
- [Mobile-Artificial-Intelligence/babylon.cpp](https://github.com/Mobile-Artificial-Intelligence/babylon.cpp)

## Historique des étoiles

[![Graphique de l'historique des étoiles](https://api.star-history.com/svg?repos=Mobile-Artificial-Intelligence/maid&type=Date)](https://star-history.com/#Mobile-Artificial-Intelligence/maid&Date)

## Contributeurs

<a href="https://github.com/Mobile-Artificial-Intelligence/maid/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=Mobile-Artificial-Intelligence/maid&max=500&columns=20&anon=1" />
</a>

## Tests
Version MacOS testée sur un  
Version Android testée sur un téléphone Oneplus 10 Pro 11Go.  
Également testée sur Fedora Linux, Windows 11.  
Testée avec calypso 3b, orcamini 3b, minyllama 1.1b, phi 3, mistral 7b, mixtral 8x7b, llama 2 7B-Chat, llama 7B et bien d'autres.

## Avertissement

Maid est distribué sous la licence MIT et est fourni sans aucune garantie, explicite ou implicite. Maid n'est affilié à aucune entreprise, y compris Huggingface, Meta (Facebook), MistralAi, OpenAI, Google, Microsoft ou toute autre entreprise fournissant un modèle compatible avec cette application.

## 📜 Licence

Ce projet est sous licence [MIT](LICENSE).

<p align="right">
  <a href="#top">Retour en haut ⬆️</a>
</p>

# Guide d'Installation

## Téléchargement et Installation d'Android Studio et du SDK Flutter

Avant de pouvoir utiliser cette application, vous devez configurer votre environnement de développement en installant Android Studio et le SDK Flutter. Suivez les étapes ci-dessous pour télécharger et installer ces outils sur votre système :

### 1. Téléchargement d'Android Studio

- Rendez-vous sur le site officiel d'Android Studio : [https://developer.android.com/studio](https://developer.android.com/studio)
- Cliquez sur le bouton de téléchargement pour votre système d'exploitation (Windows, macOS, ou Linux).
- Une fois le téléchargement terminé, exécutez le fichier d'installation et suivez les instructions à l'écran pour installer Android Studio sur votre machine.

### 2. Configuration d'Android Studio

- Lancez Android Studio après l'installation.
- Suivez le processus de configuration initial pour installer les composants nécessaires, y compris les dernières versions du SDK Android et de l'émulateur Android.
- Assurez-vous que votre installation Android Studio est correctement configurée en suivant les directives fournies par l'assistant de configuration.

### 3. Installation du SDK Flutter

- Une fois Android Studio configuré, ouvrez-le et accédez au menu `File > Settings` (ou `Android Studio > Préférences` sur macOS).
- Dans la fenêtre des paramètres, recherchez "Plugins" dans la barre de recherche.
- Cliquez sur "Plugins" dans la liste des résultats.
- Recherchez le plugin "Flutter" et cliquez sur le bouton "Install" pour l'installer.
- Après l'installation, redémarrez Android Studio pour appliquer les modifications.

### 4. Configuration de Flutter

- Ouvrez un terminal et exécutez la commande suivante pour vérifier si Flutter est correctement installé :

```bash
flutter doctor
```

- Suivez les instructions fournies par la commande `flutter doctor` pour résoudre tout problème éventuel, tel que l'installation de dépendances manquantes ou la configuration des variables d'environnement.

Une fois ces étapes terminées, vous aurez correctement configuré votre environnement de développement pour commencer à travailler sur l'application avec Flutter et Android Studio.


### 5. Installation de Dart

Une fois que Flutter est installé, Dart est automatiquement installé avec lui. Dart est le langage de programmation utilisé pour développer des applications Flutter. Vous n'avez pas besoin d'installer Dart séparément, car il est inclus dans l'installation de Flutter.

Assurez-vous simplement que Flutter est correctement configuré, comme mentionné dans les étapes précédentes, et Dart sera prêt à être utilisé dans votre projet Flutter.


---




---

## Clonage du Projet Git sur Android Studio

Si le code source de l'application est hébergé sur un dépôt Git, suivez ces étapes pour cloner le projet dans Android Studio :

### 1. Ouvrir Android Studio et Accéder à la Fenêtre d'Accueil

- Lancez Android Studio sur votre système.
- Si un projet est déjà ouvert, fermez-le en sélectionnant `File > Close Project` dans le menu principal. Cela vous amènera à la fenêtre d'accueil.

### 2. Cloner le Projet depuis Git

- Sur la fenêtre d'accueil d'Android Studio, sélectionnez "Check out project from Version Control" (ou une option similaire).
- Dans le menu déroulant, choisissez "Git" comme système de contrôle de version.
- Dans la zone de texte "URL", collez l'URL du dépôt Git où le projet est hébergé.
- Spécifiez le répertoire de destination où vous souhaitez cloner le projet localement sur votre machine.
- Cliquez sur le bouton "Clone" pour démarrer le processus de clonage.

### 3. Importer le Projet Cloné dans Android Studio

- Une fois le clonage terminé, Android Studio détectera automatiquement le projet cloné dans le répertoire spécifié.
- Suivez les instructions à l'écran pour ouvrir le projet dans Android Studio.
- Si Android Studio vous demande de choisir une version de Gradle lors de l'ouverture du projet, choisissez une version compatible ou laissez-la par défaut.

Après avoir suivi ces étapes, le projet Git sera cloné avec succès sur votre système et importé dans Android Studio, prêt à être exploré et développé.

---



---

## Lancement du Projet dans Android Studio

Avant de lancer le projet pour la première fois, assurez-vous de récupérer les dépendances nécessaires et de configurer correctement votre environnement. Suivez les étapes ci-dessous pour vous assurer que tout est prêt :

### 1. Récupérer les Dépendances du Projet

- Assurez-vous que le projet est ouvert dans Android Studio.
- Si ce n'est pas déjà fait, exécutez la commande suivante dans un terminal à la racine du projet pour récupérer les dépendances définies dans le fichier `pubspec.yaml` :

```bash
flutter pub get
```

Cela téléchargera et installera toutes les dépendances déclarées dans votre projet Flutter.

### 2. Vérifier les Configurations

- Assurez-vous que votre émulateur Android est configuré et fonctionnel, ou que vous avez un appareil Android connecté à votre machine.
- Vérifiez que les configurations de lancement dans Android Studio sont correctement définies. Vous pouvez accéder à ces configurations en cliquant sur le menu déroulant près du bouton de lecture dans la barre d'outils.

### 3. Lancer le Projet

- Une fois que toutes les dépendances sont récupérées et que les configurations sont vérifiées, vous êtes prêt à lancer le projet.
- Cliquez sur le bouton de lecture dans la barre d'outils d'Android Studio pour lancer l'application sur votre émulateur ou appareil connecté.

### 4. Vérifier les Erreurs

- Si des erreurs surviennent pendant le processus de compilation ou de lancement, consultez la console de sortie dans Android Studio pour identifier et résoudre les problèmes.
- Assurez-vous que toutes les étapes précédentes ont été suivies correctement et que toutes les dépendances requises sont correctement installées.

Une fois ces étapes terminées, votre projet devrait être lancé avec succès dans Android Studio, prêt à être testé et développé davantage.

---


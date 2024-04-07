Guide d'Installation
Téléchargement et Installation d'Android Studio et du SDK Flutter
Avant de pouvoir utiliser cette application, vous devez configurer votre environnement de développement en installant Android Studio et le SDK Flutter. Suivez les étapes ci-dessous pour télécharger et installer ces outils sur votre système :
1. Téléchargement d'Android Studio
-	Rendez-vous sur le site officiel d'Android Studio : https://developer.android.com/studio
2. Configuration d'Android Studio
-	Lancez Android Studio après l'installation.
-	Suivez le processus de configuration initial pour installer les composants nécessaires, y compris les dernières versions du SDK Android et de l'émulateur Android.
-	Assurez-vous que votre installation Android Studio est correctement configurée en suivant les directives fournies par l'assistant de configuration.
3. Installation du SDK Flutter
-	Une fois Android Studio configuré, ouvrez-le et accédez au menu File > Settings.
-	Dans la fenêtre des paramètres, recherchez "Plugins" dans la barre de recherche.
-	Cliquez sur "Plugins" dans la liste des résultats.
-	Recherchez le plugin "Flutter" et cliquez sur le bouton "Install" pour l'installer.
-	Après l'installation, redémarrez Android Studio pour appliquer les modifications.
4. Configuration de Flutter
-	Ouvrez un terminal et exécutez la commande suivante pour vérifier si Flutter est correctement installé :
flutter doctor
-	Suivez les instructions fournies par la commande flutter doctor pour résoudre tout problème éventuel, tel que l'installation de dépendances manquantes ou la configuration des variables d'environnement.
Une fois ces étapes terminées, vous pourrez lancer des projets Android studio

Clonage du Projet via git

Vous retrouverez le projet sur le repo GitHub suivant https://github.com/Kyky30/HideAndStreet
Vous pourrez le cloner via la commande 
git clone https://github.com/Kyky30/HideAndStreet
Ensuite ouvrez le repo fraichement cloné depuis GitHub dans Android studio
________________________________________
Lancement du Projet dans Android Studio
Avant de lancer le projet pour la première fois, assurez-vous de récupérer les dépendances nécessaires et de configurer correctement votre environnement. Suivez les étapes ci-dessous pour vous assurer que tout est prêt :
1. Récupérer les Dépendances du Projet
-	Si ce n'est pas déjà fait, exécutez la commande suivante dans un terminal à la racine du projet pour récupérer les dépendances définies dans le fichier pubspec.yaml :
flutter pub get
Cela téléchargera et installera toutes les dépendances du projet.
2. Vérifier les Configurations
-	Assurez-vous que votre émulateur Android est configuré et fonctionnel, ou que vous avez un appareil Android connecté à votre machine.
3. Lancer le Projet
-	Cliquez sur le bouton de lecture dans la barre d'outils d'Android Studio pour lancer l'application sur votre émulateur ou appareil connecté. Ou faites F5

Si vous rencontrez un problème n’hésitez pas à nous contacter.

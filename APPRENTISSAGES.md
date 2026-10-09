# Apprentissages

## 1. Conteneuriser l'application guestbook

Objectif : lancer le guestbook (serveur HTTP Go sur le port 3000) en local, puis
le packager dans une image Docker d'une vingtaine de Mo, et enfin la lancer
avec docker compose up

### Commandes utilisées

```bash
sudo go run main.go

docker build -t guestbook:v0.1.0 .

docker images guestbook

docker run --publish 3000:3000 guestbook:v0.1.0

#commande similaire
docker compose up
docker compose down
```

Petit changement implémenté, ajout d'une route GET /version dans main.go
qui renvoie : guestbook v0.1.0 - TP2 DevOps

### Problème rencontré et pourquoi il est survenu

Image trop lourde avec une seule étape

### Solution appliquée et pourquoi cette solution fonctionne

faire un build multi-étapes, ca fonctionne car la première étape (FROM golang:1.27-alpine AS
builder) compile, la seconde (FROM scratch) ne récupère que le binaire via (COPY --from=builder) et le dossier (public).
Tout le toolkit Go reste dans l'étape intermédiaire et n'est pas dans l'image finale.

Ainsi l'image finale de 23 Mo (contre des centaines de Mo avant).

### Ce que j'ai appris

chaque instruction crée une couche mise en cache, et l'ordre des instructions compte pour la vitesse de build
Aussi le build multi-étapes sépare l'environnement de compilation de l'environnement d'exécution, ce qui réduit la taille et la surface
d'attaque (pas de shell ni d'outils dans l'image finale)

docker compose est la version déclarative de docker build et docker run, la configuration est versionnée avec le code

## 2. Ajouter une base de données à votre service

Objectif : brancher un Redis au guestbook via docker compose pour que les
messages soient enregistrés

### Commandes utilisées

```bash
curl localhost:3000/healthz

docker compose up
docker compose down
```

Modification du docker-compose.yaml, ajout d'un service redis avec l'image publique redis:7
et le port 6379, et la variable d'environnement REDIS_HOST=redis sur le service guestbook

### Problème rencontré et pourquoi il est survenu

problème dial tcp :6379: connection refused sur /healthz (hôte vide car REDIS_HOST non défini, et aucun Redis)

### Solution appliquée et pourquoi cette solution fonctionne

ajouter un service redis dans le compose et passer REDIS_HOST=redis au guestbook, cette solution permet que dans
docker compose chaque service est joignable par son nom (redis devient le nom d'hôte), main.go construit
l'adresse redis:6379 et les messages sont stockés dans Redis

### Ce que j'ai appris

l'application se configure avec des variables d'environnement, ce qui permet de changer l'hôte sans toucher au code

## 3. Ajouter de la persistance et du hot-reloading au guestbook

Objectif : garder les messages Redis après un docker compose down, et voir les
modifications de main.go prises en compte sans reconstruire l'image


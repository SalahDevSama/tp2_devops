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

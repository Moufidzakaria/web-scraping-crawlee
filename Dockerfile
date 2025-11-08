# ==========================
# Étape 1 : Builder
# ==========================
FROM apify/actor-node-playwright-chrome:20 AS builder

# Définir le répertoire de travail
WORKDIR /app

# Donner les permissions d'écriture à l'utilisateur courant
USER root
RUN mkdir -p /app && chmod -R 777 /app

# Copier les fichiers package
COPY package*.json ./

# Installer les dépendances
RUN npm install --include=dev --audit=false --unsafe-perm=true

# Copier le reste du code
COPY . .

# Compiler TypeScript (si présent)
RUN npm run build || echo "Pas de build TypeScript"

# ==========================
# Étape 2 : Image finale
# ==========================
FROM apify/actor-node-playwright-chrome:20

WORKDIR /app
USER root
RUN mkdir -p /app && chmod -R 777 /app

# Copier le build du builder
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package*.json ./

# Installer seulement les dépendances de prod
RUN npm install --omit=dev --omit=optional --unsafe-perm=true

# Copier tout le code
COPY --from=builder /app ./

# Variables d'environnement
ENV MONGO_URI="mongodb://127.0.0.1:27017/myshopifydb"
ENV OPENAI_API_KEY="TA_CLE_VALIDE_ICI"

# Commande de démarrage
CMD ["npx", "tsx", "src/main.ts"]

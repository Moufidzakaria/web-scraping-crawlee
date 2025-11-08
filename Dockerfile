# ==========================
# Étape 1 : Builder
# ==========================
FROM apify/actor-node-playwright-chrome:20 AS builder

# Définir le répertoire de travail
WORKDIR /app

# Copier juste package.json et package-lock.json pour profiter du cache Docker
COPY package*.json ./

# Installer les dépendances
RUN npm install --include=dev --audit=false

# Copier le reste des fichiers sources
COPY . .

# Compiler le projet TypeScript (si tu utilises tsconfig.json)
RUN npm run build

# ==========================
# Étape 2 : Image finale
# ==========================
FROM apify/actor-node-playwright-chrome:20

WORKDIR /app

# Copier les fichiers buildés depuis le builder
COPY --from=builder /app/dist ./dist

# Copier package.json pour installer les packages nécessaires
COPY --from=builder /app/package*.json ./

# Installer seulement les dépendances de production
RUN npm install --omit=dev --omit=optional

# Copier le reste du projet
COPY --from=builder /app ./

# Définir les variables d'environnement (optionnel, tu peux aussi utiliser .env)
ENV MONGO_URI="mongodb://127.0.0.1:27017/myshopifydb"
ENV OPENAI_API_KEY="TA_CLE_VALIDE_ICI"

# Commande pour lancer le crawler
CMD ["npx", "tsx", "src/main.ts"]

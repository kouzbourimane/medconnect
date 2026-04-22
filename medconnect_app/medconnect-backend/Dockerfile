# Utiliser une image Python légère
FROM python:3.10-slim

# Définir le répertoire de travail dans le conteneur
WORKDIR /app

# Empêcher Python d'écrire des fichiers .pyc et envoyer les logs en direct
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Installez les dépendances système pour psycopg2 (Pour PostgreSQL si utilisé)
RUN apt-get update && apt-get install -y \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copier les configurations
COPY requirements.txt /app/

# Installer les dépendances python
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Copier le reste du code backend
COPY . /app/

# Exposer le port de base de Django
EXPOSE 8000

# Lancer le serveur Django 
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]

FROM node:14

# Imposta la directory di lavoro
WORKDIR /app

# Copia tutti i file html e json
COPY *.html ./
COPY *.json ./

# Installa un server HTTP semplice
RUN npm install -g http-server

# Espone la porta 8080
EXPOSE 8080

# Comando per avviare il server
CMD ["http-server", "-p", "7778"]
FROM python:3.11

WORKDIR /app

# 1. Instala dependências de compilação e pacotes do sistema
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    curl \
    gnupg \
    unixodbc \
    unixodbc-dev \
    apt-transport-https \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 2. Configura o repositório oficial da Microsoft e instala o Driver ODBC 18 para SQL Server (pyodbc)
RUN curl -sSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg \
    && install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/ \
    && rm microsoft.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/debian/12/prod bookworm main" > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql18

# 3. Copia e instala as dependências do Python
COPY requirements.txt .
RUN pip install --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# 4. Copia o resto dos arquivos do projeto para o container
COPY . .

# 5. Informa a porta padrão que o Render espera
ENV PORT=10000

# 6. COMANDO CRÍTICO: Garante que o Gunicorn vai gerenciar o app na porta correta
CMD ["gunicorn", "--bind", "0.0.0.0:10000", "app:app"]
FROM python:3.11

WORKDIR /app

# Instala as dependências do sistema necessárias para o SQL Server (pyodbc)
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

# Adiciona as chaves e repositório da Microsoft para o Driver ODBC
RUN curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg \
    && install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/ \
    && rm microsoft.gpg \
    && sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/debian/12/prod bookworm main" > /etc/apt/sources.list.d/mssql-release.list' \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql18

# Copia e instala os requerimentos do Python
COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copia o restante dos arquivos do projeto
COPY . .

# Expõe a variável de ambiente exigida pelo Render
ENV PORT=10000

# Executa a aplicação usando Gunicorn de forma limpa
CMD ["gunicorn", "--bind", "0.0.0.0:10000", "app:app"]
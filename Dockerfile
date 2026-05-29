FROM python:3.11-slim

# Instalar dependências do sistema e drivers ODBC da Microsoft
RUN apt-get update && apt-get install -y \
    curl \
    gnupg2 \
    unixodbc \
    unixodbc-dev \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql17 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copiar arquivos de dependências
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar o restante do código
COPY . .

# Expor a porta que o Flask/Gunicorn usará
EXPOSE 8080

# Comando para rodar com Gunicorn (melhor para produção no Render)
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "app:app"]

FROM python:3.11

WORKDIR /app

RUN apt-get update && apt-get install -y 
gcc 
g++ 
curl 
gnupg 
unixodbc 
unixodbc-dev 
apt-transport-https 
ca-certificates

RUN curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg 
&& install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/ 
&& rm microsoft.gpg

RUN sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/debian/12/prod bookworm main" > /etc/apt/sources.list.d/mssql-release.list'

RUN apt-get update 
&& ACCEPT_EULA=Y apt-get install -y msodbcsql18

COPY requirements.txt .

RUN pip install --upgrade pip

RUN pip install -r requirements.txt

COPY . .

ENV PORT=10000

CMD ["gunicorn", "--bind", "0.0.0.0:10000", "app:app"]

WORKDIR /app

# Dependências do sistema
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    unixodbc \
    unixodbc-dev \
    apt-transport-https \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Adicionar chave Microsoft
RUN mkdir -p /etc/apt/keyrings \
    && curl -sSL https://packages.microsoft.com/keys/microsoft.asc \
    | gpg --dearmor -o /etc/apt/keyrings/microsoft.gpg

# Repositório Microsoft
RUN echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/debian/12/prod bookworm main" \
    > /etc/apt/sources.list.d/mssql-release.list

# Instalar ODBC SQL Server
RUN apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql18 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Dependências Python
COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

# Copiar projeto
COPY . .

# Porta Render
ENV PORT=10000

# Inicialização
CMD ["gunicorn", "--bind", "0.0.0.0:10000", "app:app"]
```

#!/bin/bash

# Colores para mensajes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para mostrar mensajes
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Función para preguntar sí/no
ask_yes_no() {
    while true; do
        read -p "$1 (s/n): " yn
        case $yn in
            [Ss]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Por favor responda s o n.";;
        esac
    done
}

# Función para esperar que el usuario presione Enter
press_enter() {
    read -p "Presione Enter para continuar..."
}

clear
print_message "=== INSTALADOR DE PAYMENTER ==="
print_message "Este script instalará y configurará Paymenter en tu servidor"
press_enter

# Paso 1: Instalar dependencias
print_message "Instalando dependencias necesarias..."
apt -y install software-properties-common curl apt-transport-https ca-certificates gnupg

# Paso 2: Agregar repositorio PHP
print_message "Agregando repositorio PHP de Ondrej..."
LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php

# Paso 3: Configurar repositorio MariaDB
print_message "Configurando repositorio de MariaDB..."
curl -sSL https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash -s -- --mariadb-server-version="mariadb-10.11"

# Paso 4: Actualizar e instalar paquetes
print_message "Actualizando repositorios e instalando paquetes..."
apt update
apt -y install php8.3 php8.3-{common,cli,gd,mysql,mbstring,bcmath,xml,fpm,curl,zip,intl,redis} mariadb-server nginx tar unzip git redis-server

# Paso 5: Crear directorio y descargar Paymenter
print_message "Descargando Paymenter..."
mkdir -p /var/www/paymenter
cd /var/www/paymenter
curl -Lo paymenter.tar.gz https://github.com/paymenter/paymenter/releases/latest/download/paymenter.tar.gz
tar -xzvf paymenter.tar.gz
chmod -R 755 storage/* bootstrap/cache/

# Paso 6: Configurar base de datos
print_message "Configuración de la base de datos MariaDB"
print_warning "Vamos a configurar la base de datos de Paymenter"
press_enter

# Solicitar contraseña
while true; do
    read -s -p "Ingrese la contraseña para el usuario 'paymenter' de la base de datos: " DB_PASSWORD
    echo
    read -s -p "Confirme la contraseña: " DB_PASSWORD_CONFIRM
    echo
    if [ "$DB_PASSWORD" = "$DB_PASSWORD_CONFIRM" ]; then
        break
    else
        print_error "Las contraseñas no coinciden. Intente nuevamente."
    fi
done

# Crear base de datos y usuario
print_message "Creando base de datos y usuario..."
mysql -u root <<EOF
CREATE USER IF NOT EXISTS 'paymenter'@'127.0.0.1' IDENTIFIED BY '$DB_PASSWORD';
CREATE DATABASE IF NOT EXISTS paymenter;
GRANT ALL PRIVILEGES ON paymenter.* TO 'paymenter'@'127.0.0.1' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

if [ $? -eq 0 ]; then
    print_message "Base de datos creada exitosamente"
else
    print_error "Error al crear la base de datos"
    exit 1
fi

# Paso 7: Configurar archivo .env
print_message "Configurando archivo .env..."
cp .env.example .env
php artisan key:generate --force
php artisan storage:link

print_warning "Ahora vamos a editar el archivo .env"
print_warning "Por favor, configure los siguientes campos:"
print_warning "DB_PASSWORD=$DB_PASSWORD"
print_warning "APP_URL=http://tu-dominio.com (cámbialo después)"
press_enter

nano .env

# Verificar que el usuario haya guardado los cambios
print_message "Confirmando configuración del archivo .env..."
if ask_yes_no "¿Ha guardado y cerrado el archivo .env correctamente?"; then
    print_message "Continuando..."
else
    print_warning "Por favor, edite el archivo .env nuevamente"
    nano .env
fi

# Paso 8: Migraciones
print_message "Ejecutando migraciones..."
php artisan migrate --force --seed
php artisan db:seed --class=CustomPropertySeeder

# Paso 9: Configurar dominio
print_message "Configuración del dominio"
print_warning "Ingrese el dominio completo (ejemplo: https://quintillisas.com)"
read -p "Dominio: " DOMAIN

print_message "Inicializando Paymenter..."
php artisan app:init

# Paso 10: Crear usuario administrador
print_message "Creando usuario administrador..."
php artisan app:user:create

# Paso 11: Configurar crontab
print_message "Configurando crontab para www-data..."
echo "* * * * * php /var/www/paymenter/artisan schedule:run >> /dev/null 2>&1" | sudo crontab -u www-data -

# Paso 12: Configurar servicio systemd
print_message "Configurando servicio de Paymenter..."
cat > /etc/systemd/system/paymenter.service <<EOF
[Unit]
Description=Paymenter Queue Worker

[Service]
User=www-data
Group=www-data
Restart=always
ExecStart=/usr/bin/php /var/www/paymenter/artisan queue:work
StartLimitInterval=180
StartLimitBurst=30
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable --now paymenter.service
sudo systemctl enable --now redis-server

# Paso 13: Instalar certbot y SSL
print_message "Instalando Certbot para SSL..."
apt update -y
apt install certbot python3-certbot-nginx -y

# Configurar SSL
print_message "Configuración SSL"
if ask_yes_no "¿Desea usar el dominio $DOMAIN para SSL o desea cambiarlo?"; then
    print_message "Usando dominio: $DOMAIN"
else
    read -p "Ingrese el nuevo dominio (ejemplo: example.com): " DOMAIN
fi

print_message "Ejecutando Certbot para obtener certificado SSL..."
certbot certonly --nginx -d $DOMAIN

# Paso 14: Configurar Nginx
print_message "Configurando Nginx..."
cat > /etc/nginx/sites-available/paymenter.conf <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name $DOMAIN;
    root /var/www/paymenter/public;
    
    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ ^/index\.php(/|\$) {
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_hide_header X-Powered-By;
    }
}
EOF

# Activar sitio
sudo ln -sf /etc/nginx/sites-available/paymenter.conf /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo systemctl restart nginx

# Paso 15: Configurar permisos
print_message "Configurando permisos finales..."
chown -R www-data:www-data /var/www/paymenter/*

# Paso 16: Mostrar información final
clear
print_message "=== INSTALACIÓN COMPLETADA ==="
print_message "Paymenter ha sido instalado exitosamente!"
echo ""
print_message "Información de acceso:"
echo "URL: https://$DOMAIN"
echo "Credenciales: Las que configuró durante la creación del usuario administrador"
echo ""
print_warning "IMPORTANTE:"
echo "1. Si tuvo problemas con el certificado SSL, ejecute: sudo certbot --nginx -d $DOMAIN"
echo "2. Para ver los logs: sudo journalctl -u paymenter.service -f"
echo "3. Para reiniciar el servicio: sudo systemctl restart paymenter.service"
echo ""
print_message "¡Gracias por usar este instalador!"

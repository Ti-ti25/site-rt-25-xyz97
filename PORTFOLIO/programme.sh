#!/bin/bash

# NOTE : Toutes les parties de ce projet ne peuvent pas être automatisées avec des scripts.
# Certaines étapes peuvent nécessiter une intervention manuelle.

####################################################
# VARIABLES GLOBALES
####################################################
# Configuration 1
declare bridge1_1_interface_name=""
declare bridge1_1_ip_address=""
declare bridge1_1_netmask="24"
declare bridge1_1_netmask_full="255.255.255.0"
declare bridge1_1_gateway="10.2.18.1"
declare bridge1_1_dns_preferred="194.167.156.13"
declare pass1_1_interface_name=""
declare pass1_1_ip_address="192.168.1.240"
declare pass1_1_netmask="24"
declare pass1_1_netmask_full="255.255.255.0"

# Configuration 2
declare bridge1_2_interface_name=""
declare bridge1_2_ip_address=""
declare bridge1_2_netmask="24"
declare bridge1_2_netmask_full="255.255.255.0"
declare bridge1_2_gateway="10.2.18.1"
declare bridge1_2_dns_preferred="194.167.156.13"
declare pass1_2_interface_name=""
declare pass1_2_ip_address="192.168.2.240"
declare pass1_2_netmask="24"
declare pass1_2_netmask_full="255.255.255.0"

####################################################
# Fonction de vérification des privilèges root
####################################################
root() {
    if [ "$EUID" -ne 0 ] ; then
        # Vérifie si le script est exécuté avec les droits root (UID 0)
        echo "Veuillez exécuter en tant que root (sudo)."
        exit
    fi
}



####################################################
# Fonction d'installation des dépendances
####################################################
install() {
    # Mise à jour de la liste des paquets disponibles
    echo "Mise à jour des listes de paquets..."
    apt-get update -y > /dev/null  # Sortie redirigée vers /dev/null pour masquer les détails
    echo ""
    
    # Installation de RPI Imager (outil pour créer des images SD pour Raspberry Pi)
    echo "Installation de RPI Imager..."
    apt-get install rpi-imager -y > /dev/null
    echo ""
    
    # Installation du serveur DHCP ISC (pour distribuer des adresses IP)
    echo "Installation du serveur DHCP ISC..."
    apt-get install isc-dhcp-server -y > /dev/null
    echo ""
    
    echo "Toutes les dépendances ont été installées."
    echo "Installation terminée."
    echo "Vous pouvez maintenant procéder aux étapes suivantes."

    sleep 5
}



####################################################
# Configuration des addresses IP statiques pour les interfaces réseau
####################################################

# Cette Fonction ne peut pas être automatisée entièrement car elle nécessite des informations spécifiques à l'environnement réseau de l'utilisateur.
# Par conséquent, des invites interactives sont utilisées pour collecter les informations nécessaires.

config_ip_all() {
    clear
    echo "=== Menu Config IP ==="
    echo ""
    echo "## Voici 2 configuration. Choisissez celle qui correspond le mieux à votre réseau. ##"
    echo ""
    echo "1. Lancer la configuration 1"
    echo "RZO Pass1 : 192.168.1.0/24"
    echo ""
    echo "2. Lancer la configuration 2"
    echo "RZO Pass1 :192.168.2.0/24"
    echo ""
    echo "3. Quitter"
    read -p "Choisissez une option (1-3) : " choix_ip

    # Vérification que $choix est un nombre
if ! [[ "$choix_ip" =~ ^[0-9]+$ ]]; then
    echo "Erreur : Veuillez entrer un nombre valide."
    sleep 2
    continue
fi

    if [ "$choix_ip" -eq 1 ]; then
        config_ip_1
    elif [ "$choix_ip" -eq 2 ]; then
        config_ip_2
    elif [ "$choix_ip" -eq 3 ]; then
        echo "Retour au menu principal..."
        sleep 5
    fi
}



config_ip_1() {
    read -p "Entrez le nom de l'interface réseau Bridge1 (ex. ens3) : " bridge1_1_interface_name
    read -p "Entrez l'adresse IP statique pour $bridge1_1_interface_name (ex. 10.2.18.x): " bridge1_1_ip_address

    read -p "Entrez le nom de l'interface réseau Raspberry Pi (ex. ens4) : " pass1_1_interface_name

    echo ""
    echo "Configuration en cours..."
    
    # Flush les anciennes configurations
    ip addr flush dev $bridge1_1_interface_name 2>/dev/null
    ip addr flush dev $pass1_1_interface_name 2>/dev/null
    
    # Supprime les anciennes routes par défaut
    ip route del default 2>/dev/null

    # Configure l'interface bridge (celle connectée au réseau principal)
    echo "Configuration de $bridge1_1_interface_name..."
    ip addr add $bridge1_1_ip_address/$bridge1_1_netmask dev $bridge1_1_interface_name
    ip link set $bridge1_1_interface_name up
    
    # Ajoute la route par défaut via la passerelle
    echo "Ajout de la route par défaut via $bridge1_1_gateway..."
    ip route add default via $bridge1_1_gateway dev $bridge1_1_interface_name
    
    # Configure le DNS
    echo "nameserver $bridge1_1_dns_preferred" | tee /etc/resolv.conf > /dev/null
    
    # Configure l'interface Raspberry Pi
    echo "Configuration de $pass1_1_interface_name..."
    ip addr add $pass1_1_ip_address/$pass1_1_netmask dev $pass1_1_interface_name
    ip link set $pass1_1_interface_name up
    
    echo ""
    echo "Configuration terminée !"
    echo "Vérification des interfaces..."
    ip addr show $bridge1_1_interface_name | grep "inet "
    ip addr show $pass1_1_interface_name | grep "inet "
    echo ""
    echo "Route par défaut :"
    ip route | grep default
    
    sleep 5
}

config_ip_2() {
    read -p "Entrez le nom de l'interface réseau Bridge1 (ex. ens3) : " bridge1_2_interface_name
    read -p "Entrez l'adresse IP statique pour $bridge1_2_interface_name (ex. 10.2.18.x): " bridge1_2_ip_address

    read -p "Entrez le nom de l'interface réseau Raspberry Pi (ex. ens4) : " pass1_2_interface_name

    echo ""
    echo "Configuration en cours..."
    
    # Flush les anciennes configurations
    ip addr flush dev $bridge1_2_interface_name 2>/dev/null
    ip addr flush dev $pass1_2_interface_name 2>/dev/null
    
    # Supprime les anciennes routes par défaut
    ip route del default 2>/dev/null

    # Configure l'interface bridge (celle connectée au réseau principal)
    echo "Configuration de $bridge1_2_interface_name..."
    ip addr add $bridge1_2_ip_address/$bridge1_2_netmask dev $bridge1_2_interface_name
    ip link set $bridge1_2_interface_name up
    
    # Ajoute la route par défaut via la passerelle
    echo "Ajout de la route par défaut via $bridge1_2_gateway..."
    ip route add default via $bridge1_2_gateway dev $bridge1_2_interface_name
    
    # Configure le DNS
    echo "nameserver $bridge1_2_dns_preferred" | tee /etc/resolv.conf > /dev/null
    
    # Configure l'interface Raspberry Pi
    echo "Configuration de $pass1_2_interface_name..."
    ip addr add $pass1_2_ip_address/$pass1_2_netmask dev $pass1_2_interface_name
    ip link set $pass1_2_interface_name up

    echo ""
    echo "Configuration terminée !"
    echo "Vérification des interfaces..."
    ip addr show $bridge1_2_interface_name | grep "inet "
    ip addr show $pass1_2_interface_name | grep "inet "
    echo ""
    echo "Route par défaut :"
    ip route | grep default
    
    sleep 5
}



####################################################
# Fonctions de configuration du serveur DHCP
####################################################

# Cette Fonction ne peut pas être automatisée entièrement car elle nécessite des informations spécifiques à l'environnement réseau de l'utilisateur.
# Par conséquent, des invites interactives sont utilisées pour collecter les informations nécessaires.

config_dhcp_all() {

    clear
    echo "=== Menu Config DHCP ==="
    echo ""
    echo "## Voici 2 configuration. Choisissez celle qui correspond le mieux à votre réseau. ##"
    echo ""
    echo "1. Lancer la configuration 1"
    echo "RZO Pass1 : 192.168.1.0/24"
    echo ""
    echo "2. Lancer la configuration 2"
    echo "RZO Pass1 :192.168.2.0/24"
    echo ""
    echo "3. Quitter"
    read -p "Choisissez une option (1-3) : " choix_dhcp
# Vérification que $choix est un nombre
if ! [[ "$choix_dhcp" =~ ^[0-9]+$ ]]; then
    echo "Erreur : Veuillez entrer un nombre valide."
    sleep 2
    continue
fi


    if [ "$choix_dhcp" -eq 1 ]; then
        config_dhcp_1
    elif [ "$choix_dhcp" -eq 2 ]; then
        config_dhcp_2
    elif [ "$choix_dhcp" -eq 3 ]; then
        echo "Retour au menu principal..."
        sleep 5
    fi


}


config_dhcp_1() {
    conf=/etc/dhcp/dhcpd.conf
    
    # Vérification que la configuration IP 1 a été faite
    if [ -z "$bridge1_1_ip_address" ]; then
        echo "ATTENTION : Vous devez d'abord configurer les IP (option 1 du menu principal)."
        echo "Les variables de configuration ne sont pas définies."
        sleep 3
        return 1
    fi
    
    echo "Écriture de la configuration dans $conf ..."
    echo "" > $conf  # Vide le fichier existant
    
    # Crée le répertoire si nécessaire
    mkdir -p "$(dirname "$conf")"
    
    echo "Configuration du serveur DHCP :"
    echo "Le DHCP est configuré dans votre réseau 'pass' (interface Raspberry Pi)."
    echo ""

    
    # Écrit la configuration DHCP
    {
        echo "default-lease-time 600;"
        echo "max-lease-time 7200;"
        echo "option subnet-mask $pass1_1_netmask_full;"
        echo "option broadcast-address 192.168.1.255;"
        echo "option routers $bridge1_1_ip_address;"
        echo "option domain-name-servers $bridge1_1_dns_preferred;"
        echo ""
        echo "subnet 192.168.1.0 netmask 255.255.255.0 {"
        echo "    range 192.168.1.10 192.168.1.100;"
        echo "}"
    } >> "$conf"
    
    echo "Configuration DHCP écrite dans $conf."
    echo ""
    
    # Configuration de l'interface
    interface_file=/etc/default/isc-dhcp-server
    echo "Modification des interfaces dans $interface_file ..."
    
    mkdir -p "$(dirname "$interface_file")"
    
    echo "INTERFACESv4=\"$pass1_1_interface_name\"" > "$interface_file"
    echo "INTERFACESv6=\"\"" >> "$interface_file"
    
    # Redémarre le service DHCP
    echo "Redémarrage du service DHCP..."
    systemctl restart isc-dhcp-server
    
    if systemctl is-active --quiet isc-dhcp-server; then
        echo "✓ Service DHCP démarré avec succès !"
    else
        echo "✗ Erreur : Le service DHCP n'a pas démarré correctement."
        echo "Consultez les logs avec : journalctl -xeu isc-dhcp-server"
    fi
    
    echo "Configuration terminée!"
    sleep 5
}

config_dhcp_2() {
    conf=/etc/dhcp/dhcpd.conf
    
    # Vérification que la configuration IP 2 a été faite
    if [ -z "$bridge1_2_ip_address" ]; then
        echo "ATTENTION : Vous devez d'abord configurer les IP (option 1 du menu principal)."
        echo "Les variables de configuration ne sont pas définies."
        sleep 3
        return 1
    fi
    
    echo "Écriture de la configuration dans $conf ..."
    echo "" > $conf  # Vide le fichier existant
    
    # Crée le répertoire si nécessaire
    mkdir -p "$(dirname "$conf")"
    
    echo "Configuration du serveur DHCP :"
    echo "Le DHCP est configuré dans votre réseau 'pass' (interface Raspberry Pi)."
    echo ""
    
    # Écrit la configuration DHCP
    {
        echo "default-lease-time 600;"
        echo "max-lease-time 7200;"
        echo "option subnet-mask $pass1_2_netmask_full;"
        echo "option broadcast-address 192.168.2.255;"
        echo "option routers $bridge1_2_ip_address;"
        echo "option domain-name-servers $bridge1_2_dns_preferred;"
        echo ""
        echo "subnet 192.168.2.0 netmask 255.255.255.0 {"
        echo "    range 192.168.2.10 192.168.2.100;"
        echo "}"
    } >> "$conf"
    
    echo "Configuration DHCP écrite dans $conf."
    echo ""
    
    # Configuration de l'interface
    interface_file=/etc/default/isc-dhcp-server
    echo "Modification des interfaces dans $interface_file ..."
    
    mkdir -p "$(dirname "$interface_file")"
    
   echo "INTERFACESv4=\"$pass1_2_interface_name\"" > "$interface_file"
   echo "INTERFACESv6=\"\"" >> "$interface_file"
    
    # Redémarre le service DHCP
    echo "Redémarrage du service DHCP..."
    systemctl restart isc-dhcp-server
    
    if systemctl is-active --quiet isc-dhcp-server; then
        echo "✓ Service DHCP démarré avec succès !"
    else
        echo "✗ Erreur : Le service DHCP n'a pas démarré correctement."
        echo "Consultez les logs avec : journalctl -xeu isc-dhcp-server"
    fi
    
    echo "Configuration terminée!"
    sleep 5
}



####################################################
# Fonction de configuration du NAT (Network Address Translation)
####################################################
config_nat_all() {
    clear
    echo "=== Menu Config NAT ==="
    echo ""
    echo "## Voici 2 configurations. Choisissez celle qui correspond à votre réseau. ##"
    echo ""
    echo "1. Configuration NAT 1 (Réseau 192.168.1.0/24)"
    echo "2. Configuration NAT 2 (Réseau 192.168.2.0/24)"
    echo "3. Quitter"
    read -p "Choisissez une option (1-3) : " choix_nat
    
# Vérification que $choix est un nombre
if ! [[ "$choix_nat" =~ ^[0-9]+$ ]]; then
    echo "Erreur : Veuillez entrer un nombre valide."
    sleep 2
    continue
fi

    
    if [ "$choix_nat" -eq 1 ]; then
        nat_config_1
    elif [ "$choix_nat" -eq 2 ]; then
        nat_config_2
    elif [ "$choix_nat" -eq 3 ]; then
        echo "Retour au menu principal..."
        sleep 2
    else
        echo "Option invalide."
        sleep 2
    fi
}

nat_config_1() {
    config_file=/etc/sysctl.conf
    
    # Vérification que la configuration IP 1 a été faite
    if [ -z "$bridge1_1_ip_address" ] || [ -z "$pass1_1_ip_address" ]; then
        echo "ATTENTION : Vous devez d'abord configurer les IP (option 1 - Config 1)."
        echo "Les variables de configuration ne sont pas définies."
        sleep 3
        return 1
    fi
    
    echo "=== Configuration NAT pour Réseau 1 (192.168.1.0/24) ==="
    echo ""
    echo "Activation du routage IP..."
    
    # Vérifie si déjà présent
    if grep -q "^net.ipv4.ip_forward=1" "$config_file"; then
        echo "✓ Le routage IP est déjà activé dans $config_file"
    else
        echo "net.ipv4.ip_forward=1" >> "$config_file"
        echo "✓ Routage IP ajouté à $config_file"
    fi
    
    sysctl -p > /dev/null 2>&1
    echo ""
    
    echo "Configuration NAT avec les paramètres suivants :"
    echo "  - Interface Bridge : $bridge1_1_interface_name ($bridge1_1_ip_address)"
    echo "  - Interface Raspberry : $pass1_1_interface_name ($pass1_1_ip_address)"
    echo "  - Gateway : $bridge1_1_gateway"
    echo ""
    
    # Vérifie si la règle existe déjà
    if iptables -t nat -C POSTROUTING -o "$bridge1_1_interface_name" -j MASQUERADE 2>/dev/null; then
        echo "✓ La règle MASQUERADE existe déjà pour $bridge1_1_interface_name"
    else
        iptables -t nat -A POSTROUTING -o "$bridge1_1_interface_name" -j MASQUERADE
        echo "✓ Règle MASQUERADE ajoutée pour $bridge1_1_interface_name"
    fi
    
    # Règles de forwarding pour le réseau 192.168.1.0/24
    echo "Ajout des règles de forwarding pour 192.168.1.0/24..."
    iptables -A FORWARD -i "$pass1_1_interface_name" -o "$bridge1_1_interface_name" -j ACCEPT
    iptables -A FORWARD -i "$bridge1_1_interface_name" -o "$pass1_1_interface_name" -m state --state RELATED,ESTABLISHED -j ACCEPT
    
    # Sauvegarde les règles
    iptables-save > /etc/iptables_rules_config1.save
    echo "✓ Règles iptables sauvegardées dans /etc/iptables_rules_config1.save"
    echo ""
    
    Network_file=/etc/network/interfaces
    
    # Écrit la configuration réseau
    {
        echo "# Configuration générée le $(date)"
        echo "# Configuration 1 : Réseau 192.168.1.0/24"
        echo ""
        echo "auto lo"
        echo "iface lo inet loopback"
        echo ""
        echo "# Interface Bridge (connexion Internet)"
        echo "auto $bridge1_1_interface_name"
        echo "iface $bridge1_1_interface_name inet static"
        echo "    address $bridge1_1_ip_address"
        echo "    netmask $bridge1_1_netmask_full"
        echo "    gateway $bridge1_1_gateway"
        echo "    dns-nameservers $bridge1_1_dns_preferred"
        echo "    post-up iptables-restore < /etc/iptables_rules_config1.save"
        echo ""
        echo "# Interface Raspberry Pi (réseau local)"
        echo "auto $pass1_1_interface_name"
        echo "iface $pass1_1_interface_name inet static"
        echo "    address $pass1_1_ip_address"
        echo "    netmask $pass1_1_netmask_full"
    } > "$Network_file"
    
    echo "✓ Configuration réseau écrite dans $Network_file"
    echo ""
    echo "ATTENTION : Le redémarrage du réseau peut couper la connexion actuelle."
    
    echo ""
    echo "=== Configuration NAT 1 terminée ==="
    sleep 5
}

nat_config_2() {
    config_file=/etc/sysctl.conf
    
    # Vérification que la configuration IP 2 a été faite
    if [ -z "$bridge1_2_ip_address" ] || [ -z "$pass1_2_ip_address" ]; then
        echo "ATTENTION : Vous devez d'abord configurer les IP (option 1 - Config 2)."
        echo "Les variables de configuration ne sont pas définies."
        sleep 3
        return 1
    fi
    
    echo "=== Configuration NAT pour Réseau 2 (192.168.2.0/24) ==="
    echo ""
    echo "Activation du routage IP..."
    
    # Vérifie si déjà présent
    if grep -q "^net.ipv4.ip_forward=1" "$config_file"; then
        echo "✓ Le routage IP est déjà activé dans $config_file"
    else
        echo "net.ipv4.ip_forward=1" >> "$config_file"
        echo "✓ Routage IP ajouté à $config_file"
    fi
    
    sysctl -p > /dev/null 2>&1
    echo ""
    
    echo "Configuration NAT avec les paramètres suivants :"
    echo "  - Interface Bridge : $bridge1_2_interface_name ($bridge1_2_ip_address)"
    echo "  - Interface Raspberry : $pass1_2_interface_name ($pass1_2_ip_address)"
    echo "  - Gateway : $bridge1_2_gateway"
    echo ""
    
    # Vérifie si la règle existe déjà
    if iptables -t nat -C POSTROUTING -o "$bridge1_2_interface_name" -j MASQUERADE 2>/dev/null; then
        echo "✓ La règle MASQUERADE existe déjà pour $bridge1_2_interface_name"
    else
        iptables -t nat -A POSTROUTING -o "$bridge1_2_interface_name" -j MASQUERADE
        echo "✓ Règle MASQUERADE ajoutée pour $bridge1_2_interface_name"
    fi
    
    # Règles de forwarding pour le réseau 192.168.2.0/24
    echo "Ajout des règles de forwarding pour 192.168.2.0/24..."
    iptables -A FORWARD -i "$pass1_2_interface_name" -o "$bridge1_2_interface_name" -j ACCEPT
    iptables -A FORWARD -i "$bridge1_2_interface_name" -o "$pass1_2_interface_name" -m state --state RELATED,ESTABLISHED -j ACCEPT
    
    # Sauvegarde les règles
    iptables-save > /etc/iptables_rules_config2.save
    echo "✓ Règles iptables sauvegardées dans /etc/iptables_rules_config2.save"
    echo ""
    
    Network_file=/etc/network/interfaces
    
    # Écrit la configuration réseau
    {
        echo "# Configuration générée le $(date)"
        echo "# Configuration 2 : Réseau 192.168.2.0/24"
        echo ""
        echo "auto lo"
        echo "iface lo inet loopback"
        echo ""
        echo "# Interface Bridge (connexion Internet)"
        echo "auto $bridge1_2_interface_name"
        echo "iface $bridge1_2_interface_name inet static"
        echo "    address $bridge1_2_ip_address"
        echo "    netmask $bridge1_2_netmask_full"
        echo "    gateway $bridge1_2_gateway"
        echo "    dns-nameservers $bridge1_2_dns_preferred"
        echo "    post-up iptables-restore < /etc/iptables_rules_config2.save"
        echo ""
        echo "# Interface Raspberry Pi (réseau local)"
        echo "auto $pass1_2_interface_name"
        echo "iface $pass1_2_interface_name inet static"
        echo "    address $pass1_2_ip_address"
        echo "    netmask $pass1_2_netmask_full"
    } > "$Network_file"
    
    echo "✓ Configuration réseau écrite dans $Network_file"
    echo ""
    echo "ATTENTION : Le redémarrage du réseau peut couper la connexion actuelle."
    echo ""
    echo "=== Configuration NAT 2 terminée ==="
    sleep 5
}
#####################
#   Démarage
#####################



root  # Vérifie les privilèges root avant de continuer
while true; do
    clear
    echo "=== Menu Principal ==="
    echo "1. Configuration des adresses IP statiques"
    echo "2. Installation des dépendances"
    echo "3. Configuration du serveur DHCP"
    echo "4. Configuration du NAT"
    echo "5. Quitter"
    read -p "Choisissez une option (1-5) : " choix

# Vérification que $choix est un nombre
if ! [[ "$choix" =~ ^[0-9]+$ ]]; then
    echo "Erreur : Veuillez entrer un nombre valide."
    sleep 2
    continue
fi



if [ "$choix" -eq 1 ]; then
    config_ip_all
elif [ "$choix" -eq 2 ]; then
    install
elif [ "$choix" -eq 3 ]; then
    config_dhcp_all
elif [ "$choix" -eq 4 ]; then
    config_nat_all
elif [ "$choix" -eq 5 ]; then
    echo "Quitter..."
    break
else
    echo "Option invalide. Veuillez réessayer."
    sleep 5
    continue
fi
done



echo "Configuration terminée. Au revoir!"
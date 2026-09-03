FROM myoung34/github-runner:ubuntu-jammy

USER root

# Outils système génériques
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl wget git jq unzip zip ca-certificates gnupg lsb-release \
    && rm -rf /var/lib/apt/lists/*

# GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update && apt-get install -y --no-install-recommends gh \
    && rm -rf /var/lib/apt/lists/*

# Node.js LTS
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# Python 3 + pip
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip python3-venv \
    && rm -rf /var/lib/apt/lists/*

# PHP CLI
#
# Ajouté le 2026-09-03 pour que les workflows de controle de syntaxe PHP (`php -l`) puissent
# tourner sur n'importe lequel des runners generiques bases sur cette image, et pas seulement
# sur `monminilab` qui est le seul a avoir PHP installe nativement (bare-metal).
#
# Le besoin est venu du lint pose sur les 9 depots PHP du parc : les 2 depots PRIVES doivent
# tourner en self-hosted (minutes facturees), et le job est tombe sur `unraid-bzhzion`, sans
# PHP. Le repli sur un conteneur `php:8.3-cli` a echoue lui aussi, le montage de volume ne
# fonctionnant pas depuis un runner lui-meme conteneurise : le chemin vu par le demon Docker
# n'est pas celui vu par le runner, et le conteneur ne voyait aucun fichier.
#
# Pourquoi ici plutot qu'un `apt install` a la main sur chaque machine : la doc du parc
# (admin/docs/github-runners.md) rappelle que tout ce qui est pose a la main ou via l'API se
# perd au re-enregistrement du runner. Ce qui est dans l'image survit.
#
# `php-cli` seul, sans serveur web ni extensions : `php -l` n'a besoin que du parseur, et
# alourdir cette image la rendrait plus lente a tirer sur les trois hotes qui l'utilisent.
RUN apt-get update && apt-get install -y --no-install-recommends \
    php-cli \
    && rm -rf /var/lib/apt/lists/*

# Répertoire de travail persistable
RUN mkdir -p /home/runner/.cache \
    && chown -R runner:runner /home/runner/.cache

#!/bin/sh
###################################################################
# Récuperer le token d'enregistrement du runner via ce lien:
# http://localhost:8080/root/${project}/settings/ci_cd
# Benoit Petit: https://github.com/benoitpetit
###################################################################

# modifier avec votre token
registration_token=GR1348941jxzG_S5iCL6UqAmpyP2c
url=http://gitlab.local.eno

docker exec -it gitlab-runner1 \
  gitlab-runner register \
    --non-interactive \
    --registration-token ${registration_token} \
    --locked=false \
    --description docker-stable \
    --url ${url} \
    --executor docker \
    --docker-image docker:stable \
    --docker-volumes "/var/run/docker.sock:/var/run/docker.sock" \
    --docker-network-mode gitlab-network
    
# executer le script pour inscrire le runner dans Gitlab
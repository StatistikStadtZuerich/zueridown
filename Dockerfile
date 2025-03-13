FROM cmp-registry.stzh.ch/docker-hub-proxy/library/nginx:alpine

# Uncomment to copy static website files
COPY docs /usr/share/nginx/html/

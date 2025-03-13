FROM cmp-registry.stzh.ch/docker-hub-proxy/library/nginx:alpine

# Uncomment to copy static website files
cp -r docs /usr/share/nginx/html



docker buildx create --bootstrap --use --name php-builder;

docker buildx build \
--platform linux/amd64 \
--tag grmvoid/php:8.3.16-fpm \
--tag grmvoid/php:8.3-fpm \
--push \
8.3/fpm/;

docker buildx build \
--platform linux/amd64 \
--tag grmvoid/php:8.3.16-cli \
--tag grmvoid/php:8.3-cli \
--tag grmvoid/php:8.3.16 \
--tag grmvoid/php:8.3 \
--push \
8.3/cli/;

docker buildx rm php-builder;

export COMPOSE_PROJECT_NAME=demo_laravel_docker
export WEB_PORT_HTTP=80
export WEB_PORT_SSL=443
export XDEBUG_CONFIG=vscode
export MYSQL_VERSION=8.1
export INNODB_USE_NATIVE_AIO=1
export SQL_MODE=ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION


# Determine if .env file exist
# the ABOVE ARGs could be overrided by .env file
ifneq ("$(wildcard .env)","")
	include .env
else 
    $(error .env not found.)
endif


HOST_UID := $(shell id -u)
HOST_GID := $(shell id -g)
PHP_USER := -u www-data
PROJECT_NAME := -p ${COMPOSE_PROJECT_NAME}-${ENV}
APP_NAME := ${COMPOSE_PROJECT_NAME}-${ENV}
INTERACTIVE := $(shell [ -t 0 ] && echo 1)
.DEFAULT_GOAL := help
ifneq ($(INTERACTIVE), 1)
	OPTION_T := -T
endif


COMPOSE_FILE := "docker-compose-${ENV}.yml"

help: ## Shows available commands with description
	@echo "\033[34mList of available commands:\033[39m"
	@grep -E '^[a-zA-Z-]+:.*?## .*$$' Makefile | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "[32m%-27s[0m %s\n", $$1, $$2}'

build: ## incremental build
	@HOST_UID=$(HOST_UID) HOST_GID=$(HOST_GID) WEB_PORT_HTTP=$(WEB_PORT_HTTP) WEB_PORT_SSL=$(WEB_PORT_SSL) XDEBUG_CONFIG=$(XDEBUG_CONFIG) MYSQL_VERSION=$(MYSQL_VERSION) INNODB_USE_NATIVE_AIO=$(INNODB_USE_NATIVE_AIO) SQL_MODE=$(SQL_MODE) docker-compose -f ${COMPOSE_FILE} build

rebuild: ## with --no-cache option
	@HOST_UID=$(HOST_UID) HOST_GID=$(HOST_GID) WEB_PORT_HTTP=$(WEB_PORT_HTTP) WEB_PORT_SSL=$(WEB_PORT_SSL) XDEBUG_CONFIG=$(XDEBUG_CONFIG) MYSQL_VERSION=$(MYSQL_VERSION) INNODB_USE_NATIVE_AIO=$(INNODB_USE_NATIVE_AIO) SQL_MODE=$(SQL_MODE) docker-compose -f ${COMPOSE_FILE} build --no-cache

rebuild-debug: ## with --no-cache --progress plain option
	@HOST_UID=$(HOST_UID) HOST_GID=$(HOST_GID) WEB_PORT_HTTP=$(WEB_PORT_HTTP) WEB_PORT_SSL=$(WEB_PORT_SSL) XDEBUG_CONFIG=$(XDEBUG_CONFIG) MYSQL_VERSION=$(MYSQL_VERSION) INNODB_USE_NATIVE_AIO=$(INNODB_USE_NATIVE_AIO) SQL_MODE=$(SQL_MODE) docker-compose -f ${COMPOSE_FILE} build --no-cache --progress plain

start: ## Start dev environment
	@HOST_UID=$(HOST_UID) HOST_GID=$(HOST_GID) WEB_PORT_HTTP=$(WEB_PORT_HTTP) WEB_PORT_SSL=$(WEB_PORT_SSL) XDEBUG_CONFIG=$(XDEBUG_CONFIG) MYSQL_VERSION=$(MYSQL_VERSION) INNODB_USE_NATIVE_AIO=$(INNODB_USE_NATIVE_AIO) SQL_MODE=$(SQL_MODE) docker-compose -f ${COMPOSE_FILE} $(PROJECT_NAME) up -d

init-ssl: ##setup the ssl for nginx
	@HOST_UID=$(HOST_UID) HOST_GID=$(HOST_GID) WEB_PORT_HTTP=$(WEB_PORT_HTTP) WEB_PORT_SSL=$(WEB_PORT_SSL) XDEBUG_CONFIG=$(XDEBUG_CONFIG) MYSQL_VERSION=$(MYSQL_VERSION) INNODB_USE_NATIVE_AIO=$(INNODB_USE_NATIVE_AIO) SQL_MODE=$(SQL_MODE) docker-compose $(PROJECT_NAME) exec nginx certbot --nginx -d ${MAIN_DOMAIN} -m ${ADMIN_EMAIL} --agree-tos --no-eff-email

stop: ## Stop dev environment containers
	@HOST_UID=$(HOST_UID) HOST_GID=$(HOST_GID) WEB_PORT_HTTP=$(WEB_PORT_HTTP) WEB_PORT_SSL=$(WEB_PORT_SSL) XDEBUG_CONFIG=$(XDEBUG_CONFIG) MYSQL_VERSION=$(MYSQL_VERSION) INNODB_USE_NATIVE_AIO=$(INNODB_USE_NATIVE_AIO) SQL_MODE=$(SQL_MODE) docker-compose -f ${COMPOSE_FILE} $(PROJECT_NAME) stop

down: ## Stop and remove dev environment containers, networks
	@HOST_UID=$(HOST_UID) HOST_GID=$(HOST_GID) WEB_PORT_HTTP=$(WEB_PORT_HTTP) WEB_PORT_SSL=$(WEB_PORT_SSL) XDEBUG_CONFIG=$(XDEBUG_CONFIG) MYSQL_VERSION=$(MYSQL_VERSION) INNODB_USE_NATIVE_AIO=$(INNODB_USE_NATIVE_AIO) SQL_MODE=$(SQL_MODE) docker-compose -f ${COMPOSE_FILE} $(PROJECT_NAME) down


restart: stop start ## Stop and start dev environment
restart-test: stop-test start-test ## Stop and start test or continuous integration environment
restart-staging: stop-staging start-staging ## Stop and start staging environment
restart-prod: stop-prod start-prod ## Stop and start prod environment

env-prod: ## Creates config for dev environment
	@make exec cmd="cp ./.env.prod ./.env"

env-staging: ## Creates config for dev environment
	@make exec cmd="cp ./.env.staging ./.env"

env-test: ## Creates config for dev environment
	@make exec cmd="cp ./.env.test ./.env"

env-dev: ## Creates config for dev environment
	@make exec cmd="cp ./.env.dev ./.env"

env-test-ci: ## Creates config for test/ci environment
	@make exec cmd="cp ./.env.test-ci ./.env"

ssh: ## Get bash inside laravel docker container
	@HOST_UID=$(HOST_UID) HOST_GID=$(HOST_GID) WEB_PORT_HTTP=$(WEB_PORT_HTTP) WEB_PORT_SSL=$(WEB_PORT_SSL) XDEBUG_CONFIG=$(XDEBUG_CONFIG) MYSQL_VERSION=$(MYSQL_VERSION) INNODB_USE_NATIVE_AIO=$(INNODB_USE_NATIVE_AIO) SQL_MODE=$(SQL_MODE) docker-compose $(PROJECT_NAME) exec $(OPTION_T) $(PHP_USER) laravel bash


ssh-root: ## Get bash as root user inside laravel docker container
	@HOST_UID=$(HOST_UID) HOST_GID=$(HOST_GID) WEB_PORT_HTTP=$(WEB_PORT_HTTP) WEB_PORT_SSL=$(WEB_PORT_SSL) XDEBUG_CONFIG=$(XDEBUG_CONFIG) MYSQL_VERSION=$(MYSQL_VERSION) INNODB_USE_NATIVE_AIO=$(INNODB_USE_NATIVE_AIO) SQL_MODE=$(SQL_MODE) docker-compose $(PROJECT_NAME) exec $(OPTION_T) laravel bash


ssh-nginx: ## Get bash inside nginx docker container
	@HOST_UID=$(HOST_UID) HOST_GID=$(HOST_GID) WEB_PORT_HTTP=$(WEB_PORT_HTTP) WEB_PORT_SSL=$(WEB_PORT_SSL) XDEBUG_CONFIG=$(XDEBUG_CONFIG) MYSQL_VERSION=$(MYSQL_VERSION) INNODB_USE_NATIVE_AIO=$(INNODB_USE_NATIVE_AIO) SQL_MODE=$(SQL_MODE) docker-compose $(PROJECT_NAME) exec nginx /bin/sh


ssh-supervisord: ## Get bash inside supervisord docker container (cron jobs running there, etc...)
	@HOST_UID=$(HOST_UID) HOST_GID=$(HOST_GID) WEB_PORT_HTTP=$(WEB_PORT_HTTP) WEB_PORT_SSL=$(WEB_PORT_SSL) XDEBUG_CONFIG=$(XDEBUG_CONFIG) MYSQL_VERSION=$(MYSQL_VERSION) INNODB_USE_NATIVE_AIO=$(INNODB_USE_NATIVE_AIO) SQL_MODE=$(SQL_MODE) docker-compose $(PROJECT_NAME) exec supervisord bash


ssh-mysql: ## Get bash inside mysql docker container
	@HOST_UID=$(HOST_UID) HOST_GID=$(HOST_GID) WEB_PORT_HTTP=$(WEB_PORT_HTTP) WEB_PORT_SSL=$(WEB_PORT_SSL) XDEBUG_CONFIG=$(XDEBUG_CONFIG) MYSQL_VERSION=$(MYSQL_VERSION) INNODB_USE_NATIVE_AIO=$(INNODB_USE_NATIVE_AIO) SQL_MODE=$(SQL_MODE) docker-compose $(PROJECT_NAME) exec mysql bash


ssh-redis: ## Get bash inside redis docker container
	@HOST_UID=$(HOST_UID) HOST_GID=$(HOST_GID) WEB_PORT_HTTP=$(WEB_PORT_HTTP) WEB_PORT_SSL=$(WEB_PORT_SSL) XDEBUG_CONFIG=$(XDEBUG_CONFIG) MYSQL_VERSION=$(MYSQL_VERSION) INNODB_USE_NATIVE_AIO=$(INNODB_USE_NATIVE_AIO) SQL_MODE=$(SQL_MODE) docker-compose $(PROJECT_NAME) exec redis bash

exec:
	@HOST_UID=$(HOST_UID) HOST_GID=$(HOST_GID) WEB_PORT_HTTP=$(WEB_PORT_HTTP) WEB_PORT_SSL=$(WEB_PORT_SSL) XDEBUG_CONFIG=$(XDEBUG_CONFIG) MYSQL_VERSION=$(MYSQL_VERSION) INNODB_USE_NATIVE_AIO=$(INNODB_USE_NATIVE_AIO) SQL_MODE=$(SQL_MODE) docker-compose $(PROJECT_NAME) exec $(OPTION_T) $(PHP_USER) laravel $$cmd

exec-bash:
	@HOST_UID=$(HOST_UID) HOST_GID=$(HOST_GID) WEB_PORT_HTTP=$(WEB_PORT_HTTP) WEB_PORT_SSL=$(WEB_PORT_SSL) XDEBUG_CONFIG=$(XDEBUG_CONFIG) MYSQL_VERSION=$(MYSQL_VERSION) INNODB_USE_NATIVE_AIO=$(INNODB_USE_NATIVE_AIO) SQL_MODE=$(SQL_MODE) docker-compose $(PROJECT_NAME) exec $(OPTION_T) $(PHP_USER) laravel bash -c "$(cmd)"

exec-by-root:
	@HOST_UID=$(HOST_UID) HOST_GID=$(HOST_GID) WEB_PORT_HTTP=$(WEB_PORT_HTTP) WEB_PORT_SSL=$(WEB_PORT_SSL) XDEBUG_CONFIG=$(XDEBUG_CONFIG) MYSQL_VERSION=$(MYSQL_VERSION) INNODB_USE_NATIVE_AIO=$(INNODB_USE_NATIVE_AIO) SQL_MODE=$(SQL_MODE) docker-compose $(PROJECT_NAME) exec $(OPTION_T) laravel $$cmd

report-prepare:
	@make exec cmd="mkdir -p reports/coverage"

report-clean:
	@make exec-by-root cmd="rm -rf reports/*"

wait-for-db:
	@make exec cmd="php artisan db:wait"

composer-install-no-dev: ## Installs composer no-dev dependencies
	@make exec-bash cmd="COMPOSER_MEMORY_LIMIT=-1 composer install --optimize-autoloader --no-dev"

composer-install: ## Installs composer dependencies
	@make exec-bash cmd="COMPOSER_MEMORY_LIMIT=-1 composer install --optimize-autoloader"

composer-update: ## Updates composer dependencies
	@make exec-bash cmd="COMPOSER_MEMORY_LIMIT=-1 composer update"

key-generate: ## Sets the application key
	@make exec cmd="php artisan key:generate"

info: ## Shows Php and Laravel version
	@make exec cmd="php artisan --version"
	@make exec cmd="php artisan env"
	@make exec cmd="php --version"
	@make exec cmd="composer --version"

logs: ## Shows logs from the laravel container. Use ctrl+c in order to exit
	@docker logs -f ${COMPOSE_PROJECT_NAME}-laravel


logs-nginx: ## Shows logs from the nginx container. Use ctrl+c in order to exit
	@docker logs -f ${COMPOSE_PROJECT_NAME}-nginx


logs-supervisord: ## Shows logs from the supervisord container. Use ctrl+c in order to exit
	@docker logs -f ${COMPOSE_PROJECT_NAME}-supervisord


logs-mysql: ## Shows logs from the mysql container. Use ctrl+c in order to exit
	@docker logs -f ${COMPOSE_PROJECT_NAME}-mysql


drop-migrate: ## Drops databases and runs all migrations for the main/test databases
	@make exec cmd="php artisan migrate:fresh"
	@make exec cmd="php artisan migrate:fresh --env=test"

migrate-no-test: ## Runs all migrations for main database
	@make exec cmd="php artisan migrate --force"

migrate: ## Runs all migrations for main/test databases
	@make exec cmd="php artisan migrate --force"
	@make exec cmd="php artisan migrate --force --env=test"

seed: ## Runs all seeds for test database
	@make exec cmd="php artisan db:seed --force"


report-code-coverage: ## Updates code coverage on coveralls.io. Note: COVERALLS_REPO_TOKEN should be set on CI side.
	@make exec-bash cmd="export COVERALLS_REPO_TOKEN=${COVERALLS_REPO_TOKEN} && php ./vendor/bin/php-coveralls -v --coverage_clover reports/clover.xml --json_path reports/coverals.json"

phpcs: ## Runs PHP CodeSniffer
	@make exec-bash cmd="./vendor/bin/phpcs --version && ./vendor/bin/phpcs --standard=PSR12 --colors -p app tests"

ecs: ## Runs Easy Coding Standard tool
	@make exec-bash cmd="./vendor/bin/ecs --version && ./vendor/bin/ecs --clear-cache check app tests"

ecs-fix: ## Runs Easy Coding Standard tool to fix issues
	@make exec-bash cmd="./vendor/bin/ecs --version && ./vendor/bin/ecs --clear-cache --fix check app tests"

composer-normalize: ## Normalizes composer.json file content
	@make exec cmd="composer normalize"

composer-validate: ## Validates composer.json file content
	@make exec cmd="composer validate --no-check-version"

composer-require-checker: ## Checks the defined dependencies against your code
	@make exec-bash cmd="XDEBUG_MODE=off php ./vendor/bin/composer-require-checker"

composer-unused: ## Shows unused packages by scanning and comparing package namespaces against your code
	@make exec-bash cmd="XDEBUG_MODE=off php ./vendor/bin/composer-unused"

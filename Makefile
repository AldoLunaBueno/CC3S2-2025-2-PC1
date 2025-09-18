.PHONY: all check clean help run test tools

.DEFAULT_GOAL := help
SHELL := /bin/bash
OUT_DIR := out
DIST_DIR := dist
TEST_DIR := tests

all: prepare tools test run

help: ## Mostrar los targets disponibles
	@echo "Make targets:"
	@grep -E '^[a-zA-Z0-9_\-]+:.*?##' $(MAKEFILE_LIST) | \
		awk 'BEGIN{FS=":.*?##"}{printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}'

run: ## Carga entorno y mostrar variables
	$(SHELL) -c "source src/cargar_env.sh && src/mostrar_env.sh"

prepare: ## Preparar variables de entorno e instalar dependencias
	@cp docs/.env.example .env
	@chmod +x src/*.sh
	@echo "Instalando dependencias..."
	@if ! command -v bats >/dev/null 2>&1; then \
		echo "Instalando bats-core localmente..."; \
		git clone --depth 1 https://github.com/bats-core/bats-core.git /tmp/bats-core; \
		mkdir -p $(HOME)/.local/bin; \
		/tmp/bats-core/install.sh $(HOME)/.local; \
		echo "Añade esto a tu PATH si aún no está:"; \
		echo "  export PATH=\$$HOME/.local/bin:\$$PATH"; \
	fi

test: ## Ejecuta pruebas con BATS y genera reportes en out/
	@echo "Ejecutando pruebas con BATS"
	@mkdir -p $(OUT_DIR)
	@bats --formatter pretty $(TEST_DIR)/*.bats | tee >(sed -r "s/\x1B\[[0-9;]*[A-Za-z]//g" > $(OUT_DIR)/bats-report.txt)
	@echo "Resultados guardados en $(OUT_DIR)/bats_report.txt"

tools: ## Verificar dependencias
	@command -v dig >/dev/null 2>&1 || { echo "Falta dig"; exit 1; }
	@command -v curl >/dev/null 2>&1 || { echo "Falta curl"; exit 1; }
	@command -v bats >/dev/null 2>&1 || { echo "Falta bats"; exit 1; }

check: ## Ejecuta scripts de verificación manual (HTTP/DNS)
	@echo "Ejecutando check_http.sh..."
	@./src/check_http.sh
	@echo "Ejecutando check_dns.sh..."
	@./src/check_dns.sh

clean: ## Limpiar archivos generados
	@rm -rf $(OUT_DIR) $(DIST_DIR)
.PHONY: all check clean help run test tools verify-repro build-dist service-start service-stop
.DEFAULT_GOAL := help
SHELL := /bin/bash
OUT_DIR := out
DIST_DIR := dist
TEST_DIR := tests
STAMP_DIR := .stamps

all: prepare tools test check build-dist
	@echo ""
	@echo "Pipeline completo ejecutado exitosamente"
	@echo "Resultados disponibles en $(OUT_DIR)/ y $(DIST_DIR)/"

help: ## Mostrar los targets disponibles
	@echo "Make targets:"
	@grep -E '^[a-zA-Z0-9_\-]+:.*?##' $(MAKEFILE_LIST) | \
		awk 'BEGIN{FS=":.*?##"}{printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}'

run: ## Carga entorno y mostrar variables
	@echo "Cargando variables de entorno..."
	$(SHELL) -c "source src/cargar_env.sh && src/mostrar_env.sh"

prepare: ## Preparar variables de entorno e instalar dependencias
	@echo "Configurando entorno de trabajo..."
	@cp docs/.env.example .env
	@chmod +x src/*.sh
	@echo "Verificando dependencias..."
	@if ! command -v bats >/dev/null 2>&1; then \
		echo "Instalando bats-core localmente..."; \
		git clone --depth 1 https://github.com/bats-core/bats-core.git /tmp/bats-core; \
		mkdir -p $(HOME)/.local/bin; \
		/tmp/bats-core/install.sh $(HOME)/.local; \
		echo "Añade esto a tu PATH si aún no está:"; \
		echo "  export PATH=\$$HOME/.local/bin:\$$PATH"; \
	fi
	@echo "Entorno preparado correctamente"

# Reglas caché
$(STAMP_DIR)/http.stamp: src/check_http.sh .env
	@echo "Ejecutando validaciones HTTP..."
	@mkdir -p $(STAMP_DIR) $(OUT_DIR)
	@./src/check_http.sh > $(OUT_DIR)/http.log
	@echo "Validaciones HTTP completadas"
	@touch $@

$(STAMP_DIR)/dns.stamp: src/check_dns.sh .env
	@echo "Ejecutando validaciones DNS..."
	@mkdir -p $(STAMP_DIR) $(OUT_DIR)
	@./src/check_dns.sh > $(OUT_DIR)/dns.log
	@echo "Validaciones DNS completadas"
	@touch $@

$(STAMP_DIR)/test.stamp: $(TEST_DIR)/*.bats .env
	@echo "Ejecutando tests con BATS..."
	@mkdir -p $(STAMP_DIR) $(OUT_DIR)
	@bats $(TEST_DIR)/*.bats > $(OUT_DIR)/test.log
	@echo "Tests ejecutados correctamente"
	@touch $@

test: $(STAMP_DIR)/test.stamp ## Ejecutar tests
	@echo "Todos los tests han pasado correctamente"

check: $(STAMP_DIR)/http.stamp $(STAMP_DIR)/dns.stamp ## Ejecutar validaciones
	@echo "Todas las validaciones completadas exitosamente"

tools: ## Verificar dependencias
	@echo "Verificando herramientas necesarias..."
	@command -v dig >/dev/null 2>&1 || { echo "Falta dig"; exit 1; }
	@command -v curl >/dev/null 2>&1 || { echo "Falta curl"; exit 1; }
	@command -v bats >/dev/null 2>&1 || { echo "Falta bats"; exit 1; }
	@echo "Todas las herramientas están disponibles"

build-dist: check test ## Generar distribución
	@echo "Construyendo distribución final..."
	@mkdir -p $(DIST_DIR)
	@echo "Copiando archivos fuente..."
	@cp -r src $(DIST_DIR)/
	@cp -r $(OUT_DIR) $(DIST_DIR)/
	@cp README.md $(DIST_DIR)/
	@echo "Generando checksums para verificación..."
	@find $(DIST_DIR) -type f -exec md5sum {} \; > $(DIST_DIR)/checksums.txt
	@echo "Distribución creada exitosamente en $(DIST_DIR)/"

verify-repro: ## Validar reproducibilidad
	@echo "Iniciando verificación de reproducibilidad..."
	@echo "Limpiando distribuciones anteriores..."
	@rm -rf $(DIST_DIR) $(DIST_DIR).old
	@echo "Generando primera distribución..."
	@$(MAKE) build-dist >/dev/null 2>&1
	@mv $(DIST_DIR) $(DIST_DIR).old
	@echo "Generando segunda distribución..."
	@$(MAKE) build-dist >/dev/null 2>&1
	@echo "Comparando checksums de ambas distribuciones..."
	@if diff $(DIST_DIR)/checksums.txt $(DIST_DIR).old/checksums.txt; then \
		echo "Verificación exitosa: El build es completamente reproducible"; \
		rm -rf $(DIST_DIR).old; \
	else \
		echo "ERROR: El build no es reproducible, se encontraron diferencias"; \
		exit 1; \
	fi

service-start: ## Iniciar servicio simulado
	@./src/run_service.sh &

service-stop: ## Parar servicio simulado con SIGTERM
	@kill -TERM $$(cat out/service.pid)

clean: ## Limpiar archivos generados
	@echo "Limpiando archivos generados..."
	@rm -rf $(OUT_DIR) $(DIST_DIR) $(STAMP_DIR) $(DIST_DIR).old
	@echo "Limpieza completada, todos los archivos generados han sido eliminados"
#!/bin/bash

# ToText - Scripts de Automatización
# Este archivo contiene scripts útiles para desarrollo y mantenimiento

set -e  # Salir en caso de error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para mostrar ayuda
show_help() {
    echo "ToText - Scripts de Automatización"
    echo ""
    echo "Uso: ./scripts.sh [comando]"
    echo ""
    echo "Comandos disponibles:"
    echo "  setup         - Configuración inicial del proyecto"
    echo "  clean         - Limpiar archivos generados"
    echo "  deps          - Instalar/actualizar dependencias"
    echo "  test          - Ejecutar todas las pruebas"
    echo "  test-unit     - Ejecutar solo pruebas unitarias"
    echo "  test-widget   - Ejecutar solo pruebas de widgets"
    echo "  test-integration - Ejecutar pruebas de integración"
    echo "  analyze       - Análisis estático del código"
    echo "  format        - Formatear código"
    echo "  build-debug   - Compilar versión debug"
    echo "  build-release - Compilar versión release"
    echo "  run           - Ejecutar la aplicación"
    echo "  coverage      - Generar reporte de cobertura"
    echo "  docs          - Generar documentación"
    echo "  help          - Mostrar esta ayuda"
    echo ""
}

# Función para log con colores
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Configuración inicial
setup() {
    log_info "Configurando proyecto ToText..."
    
    # Verificar Flutter
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter no está instalado. Instálalo desde https://flutter.dev"
        exit 1
    fi
    
    log_info "Verificando instalación de Flutter..."
    flutter doctor
    
    log_info "Instalando dependencias..."
    flutter pub get
    
    log_info "Generando archivos..."
    flutter packages pub run build_runner build
    
    log_info "¡Configuración completada!"
}

# Limpiar proyecto
clean() {
    log_info "Limpiando proyecto..."
    flutter clean
    flutter pub get
    log_info "Limpieza completada"
}

# Instalar dependencias
deps() {
    log_info "Actualizando dependencias..."
    flutter pub get
    flutter pub upgrade
    log_info "Dependencias actualizadas"
}

# Ejecutar pruebas
run_tests() {
    log_info "Ejecutando todas las pruebas..."
    flutter test
    log_info "Pruebas completadas"
}

# Pruebas unitarias
test_unit() {
    log_info "Ejecutando pruebas unitarias..."
    flutter test test/unit/
    log_info "Pruebas unitarias completadas"
}

# Pruebas de widgets
test_widget() {
    log_info "Ejecutando pruebas de widgets..."
    flutter test test/widget/
    log_info "Pruebas de widgets completadas"
}

# Pruebas de integración
test_integration() {
    log_info "Ejecutando pruebas de integración..."
    flutter test integration_test/
    log_info "Pruebas de integración completadas"
}

# Análisis estático
analyze() {
    log_info "Ejecutando análisis estático..."
    flutter analyze
    log_info "Análisis completado"
}

# Formatear código
format() {
    log_info "Formateando código..."
    flutter format .
    log_info "Formateo completado"
}

# Compilar debug
build_debug() {
    log_info "Compilando versión debug..."
    flutter build apk --debug
    log_info "Compilación debug completada"
}

# Compilar release
build_release() {
    log_info "Compilando versión release..."
    flutter build appbundle --release
    log_info "Compilación release completada"
}

# Ejecutar aplicación
run_app() {
    log_info "Ejecutando aplicación..."
    flutter run
}

# Generar cobertura
coverage() {
    log_info "Generando reporte de cobertura..."
    flutter test --coverage
    if command -v genhtml &> /dev/null; then
        genhtml coverage/lcov.info -o coverage/html
        log_info "Reporte HTML generado en coverage/html/"
    else
        log_warn "genhtml no encontrado. Solo archivo lcov.info generado"
    fi
    log_info "Cobertura generada"
}

# Generar documentación
docs() {
    log_info "Generando documentación..."
    dart doc .
    log_info "Documentación generada en doc/api/"
}

# Script principal
case "$1" in
    setup)
        setup
        ;;
    clean)
        clean
        ;;
    deps)
        deps
        ;;
    test)
        run_tests
        ;;
    test-unit)
        test_unit
        ;;
    test-widget)
        test_widget
        ;;
    test-integration)
        test_integration
        ;;
    analyze)
        analyze
        ;;
    format)
        format
        ;;
    build-debug)
        build_debug
        ;;
    build-release)
        build_release
        ;;
    run)
        run_app
        ;;
    coverage)
        coverage
        ;;
    docs)
        docs
        ;;
    help|*)
        show_help
        ;;
esac

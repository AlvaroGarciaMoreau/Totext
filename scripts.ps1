# ToText - Scripts de Automatización para Windows PowerShell
# Este archivo contiene scripts útiles para desarrollo y mantenimiento

param(
    [Parameter(Position=0)]
    [string]$Command = "help"
)

# Función para mostrar ayuda
function Show-Help {
    Write-Host "ToText - Scripts de Automatización" -ForegroundColor Green
    Write-Host ""
    Write-Host "Uso: .\scripts.ps1 [comando]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Comandos disponibles:" -ForegroundColor Cyan
    Write-Host "  setup         - Configuración inicial del proyecto"
    Write-Host "  clean         - Limpiar archivos generados"
    Write-Host "  deps          - Instalar/actualizar dependencias"
    Write-Host "  test          - Ejecutar todas las pruebas"
    Write-Host "  test-unit     - Ejecutar solo pruebas unitarias"
    Write-Host "  test-widget   - Ejecutar solo pruebas de widgets"
    Write-Host "  test-integration - Ejecutar pruebas de integración"
    Write-Host "  analyze       - Análisis estático del código"
    Write-Host "  format        - Formatear código"
    Write-Host "  build-debug   - Compilar versión debug"
    Write-Host "  build-release - Compilar versión release"
    Write-Host "  run           - Ejecutar la aplicación"
    Write-Host "  coverage      - Generar reporte de cobertura"
    Write-Host "  docs          - Generar documentación"
    Write-Host "  help          - Mostrar esta ayuda"
    Write-Host ""
}

# Funciones de logging
function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Configuración inicial
function Start-Setup {
    Write-Info "Configurando proyecto ToText..."
    
    # Verificar Flutter
    if (!(Get-Command flutter -ErrorAction SilentlyContinue)) {
        Write-Error "Flutter no está instalado. Instálalo desde https://flutter.dev"
        exit 1
    }
    
    Write-Info "Verificando instalación de Flutter..."
    flutter doctor
    
    Write-Info "Instalando dependencias..."
    flutter pub get
    
    Write-Info "Generando archivos..."
    flutter packages pub run build_runner build
    
    Write-Info "¡Configuración completada!"
}

# Limpiar proyecto
function Start-Clean {
    Write-Info "Limpiando proyecto..."
    flutter clean
    flutter pub get
    Write-Info "Limpieza completada"
}

# Instalar dependencias
function Update-Dependencies {
    Write-Info "Actualizando dependencias..."
    flutter pub get
    flutter pub upgrade
    Write-Info "Dependencias actualizadas"
}

# Ejecutar pruebas
function Start-Tests {
    Write-Info "Ejecutando todas las pruebas..."
    flutter test
    Write-Info "Pruebas completadas"
}

# Pruebas unitarias
function Start-UnitTests {
    Write-Info "Ejecutando pruebas unitarias..."
    flutter test test/unit/
    Write-Info "Pruebas unitarias completadas"
}

# Pruebas de widgets
function Start-WidgetTests {
    Write-Info "Ejecutando pruebas de widgets..."
    flutter test test/widget/
    Write-Info "Pruebas de widgets completadas"
}

# Pruebas de integración
function Start-IntegrationTests {
    Write-Info "Ejecutando pruebas de integración..."
    flutter test integration_test/
    Write-Info "Pruebas de integración completadas"
}

# Análisis estático
function Start-Analysis {
    Write-Info "Ejecutando análisis estático..."
    flutter analyze
    Write-Info "Análisis completado"
}

# Formatear código
function Start-Format {
    Write-Info "Formateando código..."
    flutter format .
    Write-Info "Formateo completado"
}

# Compilar debug
function New-DebugBuild {
    Write-Info "Compilando versión debug..."
    flutter build apk --debug
    Write-Info "Compilación debug completada"
}

# Compilar release
function New-ReleaseBuild {
    Write-Info "Compilando versión release..."
    flutter build appbundle --release
    Write-Info "Compilación release completada"
}

# Ejecutar aplicación
function Start-App {
    Write-Info "Ejecutando aplicación..."
    flutter run
}

# Generar cobertura
function New-CoverageReport {
    Write-Info "Generando reporte de cobertura..."
    flutter test --coverage
    
    if (Get-Command genhtml -ErrorAction SilentlyContinue) {
        genhtml coverage/lcov.info -o coverage/html
        Write-Info "Reporte HTML generado en coverage/html/"
    } else {
        Write-Warn "genhtml no encontrado. Solo archivo lcov.info generado"
    }
    Write-Info "Cobertura generada"
}

# Generar documentación
function New-Documentation {
    Write-Info "Generando documentación..."
    dart doc .
    Write-Info "Documentación generada en doc/api/"
}

# Switch principal
switch ($Command.ToLower()) {
    "setup" { Start-Setup }
    "clean" { Start-Clean }
    "deps" { Update-Dependencies }
    "test" { Start-Tests }
    "test-unit" { Start-UnitTests }
    "test-widget" { Start-WidgetTests }
    "test-integration" { Start-IntegrationTests }
    "analyze" { Start-Analysis }
    "format" { Start-Format }
    "build-debug" { New-DebugBuild }
    "build-release" { New-ReleaseBuild }
    "run" { Start-App }
    "coverage" { New-CoverageReport }
    "docs" { New-Documentation }
    "help" { Show-Help }
    default { Show-Help }
}

# Ejemplos de uso:
# .\scripts.ps1 setup
# .\scripts.ps1 test
# .\scripts.ps1 build-release
# .\scripts.ps1 help

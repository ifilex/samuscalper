# Samu Scalper AI

### Aprendizaje automático local y scalping multiactivo en MQL4

Samu Scalper AI es un Expert Advisor para **MetaTrader 4**, desarrollado íntegramente en **MQL4**.

Este repositorio comparte la **versión 9.0**, que combina una red neuronal, un ensemble evolutivo, memoria de experiencias y un motor de reglas denominado SAML.

Los cálculos y el aprendizaje se ejecutan localmente dentro de MetaTrader 4. El código no requiere servicios de IA externos.

## Contexto del proyecto

Como neuropsicólogo y desarrollador, me interesa explorar sistemas que combinan información, experiencia y reglas explícitas para tomar decisiones.

SAMU reúne estos mecanismos en una implementación que permite inspeccionar cómo se construye una señal y cómo se modifica la gestión ante resultados adversos.

La arquitectura utiliza aprendizaje automático y reglas programadas. No constituye una simulación validada del cerebro ni un modelo clínico neuropsicológico.

## Arquitectura

| Componente | Implementación |
|---|---|
| Red neuronal | 10 entradas, 10 neuronas ocultas y una salida |
| Activaciones | Tangente hiperbólica en la capa oculta y sigmoide en la salida |
| Entrenamiento | Backpropagation con tasa de aprendizaje y momentum configurables |
| Ensemble | Población de estrategias con pesos sobre las mismas 10 variables |
| Evolución | Selección, cruce y mutación de estrategias |
| Replay | Buffer de experiencias con contexto, acción y recompensa |
| SAML | Reglas que modifican puntuación, lotaje, SL, TP o bloquean entradas |
| Estados | Normal, Recovery y Protect |
| Persistencia | Archivos binarios, reglas exportadas y registros CSV |

## Variables de entrada

La red y el ensemble utilizan:

1. RSI normalizado.
2. MACD relativo al ATR.
3. Diferencia entre EMA20 y EMA50 normalizada por precio.
4. Posición del precio respecto de las bandas de Bollinger.
5. Relación entre ATR14 y ATR100.
6. Momentum de cinco barras relativo al ATR.
7. Estocástico normalizado.
8. CCI normalizado.
9. Componente cíclica de la hora.
10. Componente cíclica del día de la semana.

Las variables utilizan el período del gráfico. Varias incluyen la vela en formación.

La implementación multiactivo requiere revisar las referencias al gráfico principal descritas en las limitaciones.

## Construcción de la señal

La salida neuronal se transforma de `[0, 1]` a `[-1, 1]` y se combina con el voto del ensemble.

Los pesos predeterminados son:

- Red neuronal: **0.60**.
- Ensemble: **0.40**.

SAML puede agregar un ajuste a esa puntuación o bloquear la entrada.

El resultado se compara con un umbral direccional:

- Forex: **±0.30**.
- Instrumentos reconocidos como cripto: **±0.25**.

Después se aplican las comprobaciones de tendencia, exposición, margen, cantidad de operaciones y distancia entre entradas.

La salida de la red es una puntuación del modelo; no está validada como probabilidad calibrada de éxito.

## Aprendizaje

### Entrenamiento supervisado

Utiliza características históricas del símbolo del gráfico y una etiqueta basada en el signo del movimiento hacia la barra siguiente.

El entrenamiento se comprueba mediante un temporizador de 60 segundos y se ejecuta al detectar una nueva barra, si existen suficientes datos.

Aunque la ventana predeterminada es de 500 barras, cada pasada procesa como máximo 200 muestras válidas.

### Replay de experiencias

Registra el contexto de las operaciones y utiliza la dirección y el signo de la recompensa para construir objetivos de entrenamiento.

El replay comienza cuando existen al menos 100 experiencias.

Es una actualización supervisada a partir de resultados almacenados. No implementa un algoritmo de Q-learning ni una optimización explícita del retorno acumulado.

### Ensemble evolutivo

Cada estrategia contiene un vector de 10 pesos.

La evaluación utiliza aciertos direccionales sobre barras históricas. Conserva parte de las estrategias y genera nuevas combinaciones mediante cruce y mutación.

Esa evaluación no equivale a un backtest que incorpore costes, ejecución y gestión completa de posiciones.

## Motor SAML

SAML representa reglas mediante condiciones, prioridades y acciones.

Las condiciones pueden consultar indicadores, puntuaciones del modelo, drawdown y estadísticas de operaciones.

Las acciones disponibles permiten:

- Ajustar la puntuación direccional.
- Modificar el lote.
- Bloquear entradas.
- Modificar las distancias de SL y TP.

Incluye reglas iniciales, actualización de estadísticas, mutación y generación de reglas a partir de patrones del buffer.

En esta versión, el archivo `.saml` es una exportación legible. La carga de reglas se realiza desde el archivo binario; no incluye un intérprete que ejecute modificaciones del archivo de texto.

## Gestión de operaciones

Incluye:

- SL y TP basados en ATR.
- Salida rápida por beneficio alcanzado en pocos minutos.
- Cierre por tiempo máximo.
- Cierre parcial.
- Ajuste del stop hacia la entrada.
- Trailing basado en ATR.
- Cierre conjunto por retroceso desde un pico de beneficio flotante.
- Entradas adicionales condicionadas por señal y distancia adversa.

`R` representa la distancia inicial al stop registrada al abrir la operación.

Los añadidos requieren una nueva señal válida. El programa no utiliza una duplicación fija de lotes tras cada pérdida.

## Estados de recuperación

### Normal

Procesa señales y gestiona posiciones con la configuración habitual.

### Recovery

Se activa por pérdida flotante relativa al riesgo estimado o al balance.

Reevalúa régimen, puntuación del modelo, resultados recientes y sesgo de posiciones para seleccionar una táctica.

La táctica denominada `HEDGE` intenta cerrar posiciones contrarias a la tendencia detectada; no abre por sí misma una cobertura opuesta.

### Protect

Puede activarse al alcanzar el daño adicional configurado durante Recovery. Intenta cerrar posiciones y establece una pausa.

“Recuperación” describe la lógica del programa; no implica que las pérdidas puedan recuperarse.

## Configuración principal

| Parámetro | Valor predeterminado |
|---|---:|
| `RiesgoPorTrade` | `0.50%` |
| `RiesgoMaxAbsoluto` | `0.75%` |
| `RiesgoAgregadoMax` | `2.50%` |
| `FraccionKelly` | `0.20` |
| `MaxOrdenesSimbolo` | `2`, comprobado por dirección |
| `MaxParesSimultaneos` | `2` |
| `SL_BaseR` | `1.00` |
| `TP_BaseR` | `1.20` |
| `LearningRateNN` | `0.01` |
| `MomentumNN` | `0.90` |
| `TamanoPoolEstrategias` | `20` |
| `MaxExperiencia` | `5000` |
| `BatchReplay` | `32` |
| `ReplaysPorHora` | `4` |
| `Recov_TriggerR` | `−0.80` |
| `Recov_TriggerPct` | `1.00%` |
| `Recov_DamageCapPct` | `3.00%` |
| Niveles de drawdown | `4%, 8%, 12%` |
| `HorasPausaDD` | `24` |
| `ModoCripto` | `false` |
| Horario inicial | `08:00–20:00`, hora del servidor |

Los porcentajes expresan parámetros y comprobaciones del código. No garantizan pérdidas máximas efectivas.

## Instrumentos

Permite configurar hasta 30 símbolos.

La lista predeterminada incluye:

EURUSD, GBPUSD, USDJPY, AUDUSD, USDCAD, NZDUSD, USDCHF, EURJPY, GBPJPY y EURGBP.

El modo cripto reconoce nombres que contienen BTC, ETH, XRP, LTC, ADA o SOL cuando `ModoCripto=true`.

Su disponibilidad depende del bróker.

## Instalación para pruebas

1. Abrir MetaTrader 4 en una cuenta demo.
2. Seleccionar **Archivo → Abrir carpeta de datos**.
3. Copiar `SAMU_Scalper_AI.mq4` dentro de `MQL4/Experts`.
4. Abrir el archivo en MetaEditor y compilar.
5. Revisar errores y advertencias.
6. Actualizar la lista de Expert Advisors.
7. Cargar el EA y revisar símbolos, históricos, parámetros y permisos.
8. Comprobar los registros y archivos generados durante las pruebas.

No es necesario activar `ResetCerebroAlInicio` si no existen archivos anteriores: el código inicializa el modelo automáticamente.

Si se utiliza el reset, volver a desactivarlo antes de la siguiente inicialización para conservar el aprendizaje.

## Archivos generados

| Archivo | Contenido |
|---|---|
| `SAMU_v9_cerebro.bin` | Pesos neuronales, población y parte de las estadísticas |
| `SAMU_v9_experiencia.bin` | Buffer de experiencias |
| `SAMU_v9_script.bin` | Reglas SAML persistidas |
| `SAMU_v9_script.saml` | Exportación legible de reglas |
| `SAMU_v9_journal.csv` | Registro de operaciones procesadas |
| `SAMU_v9_stats.csv` | Estadísticas exportadas |
| `SAMU_v9_export.csv` | Exportación parcial de metadatos y pesos |

El código utiliza el espacio de archivos de MetaTrader 4. La ubicación efectiva depende de si se ejecuta en el terminal o en el probador.

Los nombres son fijos: varias instancias dentro del mismo espacio de archivos pueden sobrescribir sus datos.

## Estado y limitaciones conocidas

Puntos identificados por lectura del código:

- **Contexto multiactivo:** algunas características usan `Close`, `Time` y `Bars` del gráfico principal en lugar de series del símbolo procesado.
- **Entrenamiento:** utiliza el símbolo del gráfico para entrenar un modelo compartido entre instrumentos.
- **Etiquetas:** la muestra más reciente puede utilizar el cierre todavía variable de la barra actual.
- **Desactivación neuronal:** `ActivarRedNeural=false` detiene el entrenamiento del temporizador, pero no elimina la inferencia neuronal de la señal.
- **Historial duplicado:** los cierres sin contexto de ticket registrado pueden procesarse repetidamente e inflar estadísticas, experiencias y journal.
- **Evolución:** el contador del pool se incrementa por llamada a `ProcesarCierres`, incluso si no hubo nuevos cierres.
- **Capacidad de tickets:** el registro admite 200 entradas y no libera las ya procesadas. Tras alcanzar ese límite, nuevas órdenes pueden quedar sin contexto de aprendizaje y gestión individual.
- **Reinicio:** el contexto de tickets y la distancia R inicial no se reconstruyen desde las posiciones abiertas.
- **Cierres parciales:** requieren validar cómo conserva o modifica tickets el bróker y cómo se actualiza el contexto.
- **Recovery:** el contador de intentos se consulta, pero no se incrementa; el límite configurado no actúa como se espera.
- **Recovery multiactivo:** algunas decisiones utilizan el régimen del gráfico principal para actuar sobre posiciones de varios símbolos.
- **Daño en Recovery:** compara cambios del beneficio flotante; no contabiliza de forma completa el resultado realizado durante ese período.
- **Circuit breaker:** puede extender la pausa en cada tick mientras el drawdown siga por encima del nivel 3.
- **Riesgo estimado:** omite posiciones sin SL y utiliza la distancia absoluta entre entrada y stop, incluso si este ya asegura beneficio.
- **Redondeo:** el ajuste por decimales no garantiza compatibilidad con todos los pasos de lote ni exactitud de los topes anunciados.
- **Límite de símbolos:** el conteo no se actualiza después de cada apertura dentro del mismo recorrido.
- **Persistencia:** no conserva todo el estado de entrenamiento, gestión y evaluación; cambiar el tamaño del pool también requiere revisar la compatibilidad del archivo.
- **Parámetros:** faltan validaciones integrales de capacidades, períodos y límites antes de ejecutar.

La presencia de aprendizaje automático no acredita una ventaja estadística. Su evaluación requiere separar entrenamiento y prueba, contemplar costes y verificar estabilidad fuera de muestra.

## Resultados y validación

Este repositorio no incluye pesos preentrenados, un historial auditado ni una validación independiente de rendimiento.

La documentación se basa en la lectura del archivo fuente. No acredita compilación, ejecución ni resultados de backtesting.

## Autor

Desarrollado por **Emanuel**, neuropsicólogo y desarrollador del proyecto **WineBOX**.

- https://winebox.cloud
- https://wineboxtool.cloud

## Contribuciones

Se reciben reportes de errores y propuestas mediante Issues y Pull Requests.

Incluir versión de MetaTrader 4, símbolo, período del gráfico, parámetros y mensajes relevantes del registro. No compartir credenciales, datos de cuenta ni archivos personales de entrenamiento.

## Licencia

Este proyecto se distribuye bajo la licencia **Apache License 2.0**.

Consultar el archivo [LICENSE](LICENSE) para conocer los términos completos.

## Aviso

Material técnico y educativo. Operar con sistemas automáticos puede generar pérdidas. No constituye asesoramiento financiero ni una promesa de resultados.

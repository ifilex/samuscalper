//+------------------------------------------------------------------+
//|                                            SAMU AI v9.0          |
//|   Neural Net + Genetic Pool + Replay + SAML + Recovery Engine   |
//|   Diseñado para: scalp rápido con recuperación inteligente      |
//+------------------------------------------------------------------+
#property copyright "SAMU Quant Edition"
#property link      "www.wineboxtool.cloud"
#property version   "9.00"
#property strict

//====================================================================
//======================== PARÁMETROS ================================
//====================================================================
extern string  __SIZING__         = "--- GESTIÓN DE CAPITAL ---";
extern double  RiesgoPorTrade     = 0.50;   // % por trade (base)
extern double  RiesgoMaxAbsoluto  = 0.75;   // % tope DURO por trade
extern double  RiesgoAgregadoMax  = 2.50;   // % tope DURO suma de posiciones
extern double  FraccionKelly      = 0.20;
extern int     MaxOrdenesSimbolo  = 2;
extern double  DistanciaGridPips  = 30.0;

extern string  __SALIDA__         = "--- SALIDA / SCALP ---";
extern double  SL_BaseR           = 1.00;
extern double  TP_BaseR           = 1.20;
extern bool    ActivarFastExit    = true;
extern double  FastExit_R         = 0.50;
extern int     FastExit_Min       = 5;
extern int     Timeout_Scalp_Min  = 45;
extern bool    ActivarBreakEven   = true;
extern double  BreakEven_R        = 0.80;
extern double  BreakEven_LockPips = 2.0;
extern bool    ActivarTrailing    = true;
extern double  Trailing_StartR    = 1.20;
extern double  Trailing_ATRMult   = 1.00;
extern bool    ActivarParcial     = true;
extern double  Parcial_R          = 1.00;
extern double  Parcial_Pct        = 50.0;
extern bool    ActivarProfitLock  = true;
extern double  ProfitLock_MinUSD  = 20.0;
extern double  ProfitLock_Back    = 40.0;

extern string  __MAGIC__          = "--- IDs ---";
extern int     NumeroMagicoCompra = 99991;
extern int     NumeroMagicoVenta  = 99992;

extern string  __IA__             = "--- IA ---";
extern bool    ActivarRedNeural   = true;
extern double  LearningRateNN     = 0.01;
extern double  MomentumNN         = 0.90;
extern int     VentanaEntrenamiento = 500;
extern int     TamanoPoolEstrategias = 20;
extern int     FrecuenciaEvolucion  = 50;
extern int     MaxExperiencia       = 5000;
extern int     BatchReplay          = 32;
extern int     ReplaysPorHora       = 4;
extern double  PesoRedNeural        = 0.60;
extern double  PesoEnsemble         = 0.40;

extern string  __RECOVERY__       = "--- RECOVERY IA ---";
extern bool    ActivarRecovery    = true;
extern double  Recov_TriggerR     = -0.80;
extern double  Recov_TriggerPct   = 1.00;
extern int     Recov_TimeoutMin   = 15;
extern int     Recov_MaxIntentos  = 5;
extern double  Recov_LotMultMax   = 1.20;
extern double  Recov_DamageCapPct = 3.00;
extern int     Recov_PausaHoras   = 4;

extern string  __SAML__           = "--- SAML (auto-optimización) ---";
extern bool    ActivarSAML        = true;
extern int     SAML_EvolucionCada = 30;
extern double  SAML_TasaMutacion  = 0.20;
extern double  SAML_LotMultCap    = 1.30;
extern bool    SAML_AutoGenerar   = true;

extern string  __CRIPTO__         = "--- CRIPTO ---";
extern bool    ModoCripto         = false;
extern double  MultiplicadorATRCripto = 1.3;
extern double  SpreadMaxCripto    = 15.0;
extern bool    SinFiltroHorarioCripto = true;

extern string  __FILTROS__        = "--- FILTROS ---";
extern bool    FiltroRegimen      = true;
extern bool    FiltroTendencia    = true;
extern bool    FiltroSpread       = true;
extern double  SpreadMaxPips      = 3.0;
extern bool    FiltroHorario      = true;
extern string  HoraInicio         = "08:00";
extern string  HoraFin            = "20:00";

extern string  __CB__             = "--- CIRCUIT BREAKER ---";
extern bool    ActivarCircuitBreaker = true;
extern double  DD_Nivel1          = 4.0;
extern double  DD_Nivel2          = 8.0;
extern double  DD_Nivel3          = 12.0;
extern int     HorasPausaDD       = 24;

extern string  __SIMBOLOS__       = "--- SÍMBOLOS ---";
extern string Simbolo01="EURUSD"; extern string Simbolo02="GBPUSD";
extern string Simbolo03="USDJPY"; extern string Simbolo04="AUDUSD";
extern string Simbolo05="USDCAD"; extern string Simbolo06="NZDUSD";
extern string Simbolo07="USDCHF"; extern string Simbolo08="EURJPY";
extern string Simbolo09="GBPJPY"; extern string Simbolo10="EURGBP";
extern string Simbolo11="";       extern string Simbolo12="";
extern string Simbolo13="";       extern string Simbolo14="";
extern string Simbolo15="";       extern string Simbolo16="";
extern string Simbolo17="";       extern string Simbolo18="";
extern string Simbolo19="";       extern string Simbolo20="";
extern string Simbolo21="";       extern string Simbolo22="";
extern string Simbolo23="";       extern string Simbolo24="";
extern string Simbolo25="";       extern string Simbolo26="";
extern string Simbolo27="";       extern string Simbolo28="";
extern string Simbolo29="";       extern string Simbolo30="";

extern int     MaxParesSimultaneos = 2;
extern string  ComentarioOrden     = "SAMU AI v9";
extern bool    ResetCerebroAlInicio = false;   // ← poner true la PRIMERA vez

extern string  __VISUAL__         = "--- VISUAL ---";
extern bool    PintarVelas        = true;
extern bool    MostrarPisosTechos = true;

//====================================================================
//======================== CONSTANTES ================================
//====================================================================
#define NN_INPUTS      10
#define NN_HIDDEN      10
#define NN_OUTPUTS     1
#define NN_W1_SIZE     (NN_INPUTS * NN_HIDDEN)
#define NN_B1_SIZE     NN_HIDDEN
#define NN_W2_SIZE     (NN_HIDDEN * NN_OUTPUTS)
#define NN_B2_SIZE     NN_OUTPUTS
#define STRAT_FEATURES 10

#define MAX_EXP_HARD   20000
#define MAX_TICKETS    200

#define ARCHIVO_CEREBRO     "SAMU_v9_cerebro.bin"
#define ARCHIVO_EXPERIENCIA "SAMU_v9_experiencia.bin"
#define ARCHIVO_JOURNAL     "SAMU_v9_journal.csv"
#define ARCHIVO_STATS       "SAMU_v9_stats.csv"
#define ARCHIVO_EXPORT      "SAMU_v9_export.csv"
#define ARCHIVO_SAML        "SAMU_v9_script.saml"
#define ARCHIVO_SAML_BIN    "SAMU_v9_script.bin"

#define BALANCE_MINIMO  500.0

#define REG_RANGO  0
#define REG_ALZA   1
#define REG_BAJA   2
#define REG_CAOS   3

// Máquina de estados
#define MODE_NORMAL    0
#define MODE_RECOVERY  1
#define MODE_PROTECT   2

#define TAC_SCALP   0
#define TAC_HEDGE   1
#define TAC_FLAT    2

// SAML
#define SS_MAX_RULES  32
#define SS_MAX_COND   3
#define SS_FEAT_NN     -1
#define SS_FEAT_ENS    -2
#define SS_FEAT_SCORE  -3
#define SS_FEAT_WR     -4
#define SS_FEAT_DD     -5
#define SS_FEAT_CL     -6
#define SS_FEAT_CW     -7

#define SS_OP_GT  0
#define SS_OP_LT  1
#define SS_OP_GE  2
#define SS_OP_LE  3

#define SS_ACT_BOOST      0
#define SS_ACT_LOT_MULT   1
#define SS_ACT_BLOCK      2
#define SS_ACT_SL_MULT    3
#define SS_ACT_TP_MULT    4

//====================================================================
//======================== ESTRUCTURAS ===============================
//====================================================================
struct SSRule
  {
   int    id;
   int    priority;
   int    active;
   int    condCount;
   int    condIdx[SS_MAX_COND];
   int    condOp[SS_MAX_COND];
   double condVal[SS_MAX_COND];
   int    condLogic[SS_MAX_COND];
   int    actionType;
   double actionVal;
   int    hits;
   int    misses;
   double fitness;
   int    generation;
  };

//====================================================================
//======================== ESTADO GLOBAL =============================
//====================================================================
int      NumSimbolos = 0;
string   ListaSimbolos[30];
string   SufijoSimbolo = "";

// NN
double   g_W1[NN_W1_SIZE];
double   g_B1[NN_B1_SIZE];
double   g_W2[NN_W2_SIZE];
double   g_B2[NN_B2_SIZE];
double   g_vW1[NN_W1_SIZE];
double   g_vB1[NN_B1_SIZE];
double   g_vW2[NN_W2_SIZE];
double   g_vB2[NN_B2_SIZE];
double   g_input[NN_INPUTS];
double   g_hidden[NN_HIDDEN];
double   g_output[NN_OUTPUTS];

// Pool genético
double   g_Pool[64][STRAT_FEATURES];
double   g_Fitness[64];
int      g_EdadEstrategia[64];
int      g_Generacion = 0;

// Replay
double   g_exp_feat[MAX_EXP_HARD][NN_INPUTS];
double   g_exp_acc[MAX_EXP_HARD];
double   g_exp_rew[MAX_EXP_HARD];
datetime g_exp_tim[MAX_EXP_HARD];
int      g_exp_count = 0;
int      g_exp_pos   = 0;
int      g_exp_entrenamientos = 0;

// Tickets (contexto de aprendizaje)
int      g_ticketPendiente[MAX_TICKETS];
double   g_ticketFeat[MAX_TICKETS][NN_INPUTS];
double   g_ticketAccion[MAX_TICKETS];
double   g_ticketPredNN[MAX_TICKETS];
double   g_ticketVotoEns[MAX_TICKETS];
double   g_ticketScore[MAX_TICKETS];
datetime g_ticketHora[MAX_TICKETS];
int      g_ticketSAMLFire[MAX_TICKETS][SS_MAX_RULES];
int      g_ticketCount = 0;

// Gestión de salida por ticket
double   g_mgmtR[MAX_TICKETS];         // 1R en precio
bool     g_mgmtBE[MAX_TICKETS];        // BE aplicado
bool     g_mgmtParcial[MAX_TICKETS];   // parcial aplicado

// Stats por símbolo
int      g_trades[30];
int      g_wins[30];
int      g_losses[30];
double   g_pnl[30];
int      g_consecWin[30];
int      g_consecLoss[30];

// Meta
double   g_pesoNN  = 0.60;
double   g_pesoEns = 0.40;

// Estado global
int      g_tradesDesdeEvolucion = 0;
double   g_peakEquity = 0;
datetime g_PausaHasta = 0;
int      g_NivelDD = 0;
datetime g_UltimaBarraEntren = 0;
datetime g_UltimaBarraNiv = 0;
datetime g_UltimoReplay = 0;
bool     g_VisInit = false;
string   g_estadoIA = "INICIANDO";
int      Magic1 = 0, Magic2 = 0;

// Stats globales
int      g_totalTrades = 0;
int      g_totalWins   = 0;
int      g_totalLosses = 0;
double   g_totalPnL    = 0;
double   g_maxDDHist   = 0;

// Máquina de estados
int      g_modoActual        = MODE_NORMAL;
int      g_tacticaActual     = TAC_SCALP;
double   g_agresividad       = 1.0;
datetime g_inicioRecovery    = 0;
datetime g_ultimaReevaluacion= 0;
int      g_intentosRecovery  = 0;
double   g_pnlInicioRecovery = 0;

// Profit lock
double   g_floatingPeak = 0;
double   g_floatingNow  = 0;

// SAML
SSRule   g_SSRules[SS_MAX_RULES];
int      g_SSRuleCount  = 0;
int      g_SSNextId     = 1;
int      g_SSGeneration = 0;
int      g_SSTradesEvo  = 0;
double   g_SSUltBoost   = 0;
double   g_SSUltLotMult = 1.0;
bool     g_SSUltBlocked = false;
int      g_SSUltFired   = 0;

// Panel
int      OrdenesCompra = 0, OrdenesVenta = 0;
double   ProfitCompra = 0, ProfitVenta = 0;
double   UlimoPredNN = 0, UltimoVotoEns = 0, UltimoScore = 0;

//====================================================================
//======================== INIT / DEINIT =============================
//====================================================================
int OnInit()
  {
   SufijoSimbolo = StringSubstr(Symbol(), 6, StringLen(Symbol()) - 6);
   Magic1 = NumeroMagicoCompra;
   Magic2 = NumeroMagicoVenta;

   string cfg[30];
   cfg[0]=Simbolo01; cfg[1]=Simbolo02; cfg[2]=Simbolo03;
   cfg[3]=Simbolo04; cfg[4]=Simbolo05; cfg[5]=Simbolo06;
   cfg[6]=Simbolo07; cfg[7]=Simbolo08; cfg[8]=Simbolo09;
   cfg[9]=Simbolo10; cfg[10]=Simbolo11;cfg[11]=Simbolo12;
   cfg[12]=Simbolo13;cfg[13]=Simbolo14;cfg[14]=Simbolo15;
   cfg[15]=Simbolo16;cfg[16]=Simbolo17;cfg[17]=Simbolo18;
   cfg[18]=Simbolo19;cfg[19]=Simbolo20;cfg[20]=Simbolo21;
   cfg[21]=Simbolo22;cfg[22]=Simbolo23;cfg[23]=Simbolo24;
   cfg[24]=Simbolo25;cfg[25]=Simbolo26;cfg[26]=Simbolo27;
   cfg[27]=Simbolo28;cfg[28]=Simbolo29;cfg[29]=Simbolo30;

   NumSimbolos = 0;
   for(int k = 0; k < 30; k++)
      if(cfg[k] != "") { ListaSimbolos[NumSimbolos] = cfg[k] + SufijoSimbolo; NumSimbolos++; }

   for(int i = 0; i < NumSimbolos; i++)
     {
      g_trades[i]=0; g_wins[i]=0; g_losses[i]=0; g_pnl[i]=0;
      g_consecWin[i]=0; g_consecLoss[i]=0;
     }

   // Reset opcional
   if(ResetCerebroAlInicio)
     {
      if(FileIsExist(ARCHIVO_CEREBRO))      FileDelete(ARCHIVO_CEREBRO);
      if(FileIsExist(ARCHIVO_EXPERIENCIA))  FileDelete(ARCHIVO_EXPERIENCIA);
      if(FileIsExist(ARCHIVO_SAML_BIN))     FileDelete(ARCHIVO_SAML_BIN);
      Print(">>> Cerebro reseteado desde cero (ResetCerebroAlInicio=true)");
     }

   if(!CargarCerebro())
     {
      InicializarRedNeural();
      InicializarPool();
      Print("Cerebro inicializado");
     }
   CargarExperiencia();

   if(ActivarSAML)
     {
      if(!SS_Load())
        {
         SS_InitSemilla();
         Print("SAML: reglas semilla creadas");
        }
     }

   InicializarJournal();
   g_pesoNN  = PesoRedNeural;
   g_pesoEns = PesoEnsemble;
   g_peakEquity = AccountEquity();

   if(AccountBalance() < BALANCE_MINIMO)
      Print("AVISO: balance < $", BALANCE_MINIMO);

   EventSetTimer(60);

   Print("===== SAMU AI v9.0 =====");
   Print("Simbolos: ", NumSimbolos);
   Print("Riesgo: ", RiesgoPorTrade, "% (max ", RiesgoMaxAbsoluto, "%, agregado ",
         RiesgoAgregadoMax, "%)");
   Print("Scalp: TP=", TP_BaseR, "R SL=", SL_BaseR, "R");
   Print("Recovery: trigger=", Recov_TriggerR, "R / ", Recov_TriggerPct, "%, cap=",
         Recov_DamageCapPct, "%");
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   GuardarCerebro();
   GuardarExperiencia();
   GuardarStatsCSV();
   ExportarParaIAExterna();
   if(ActivarSAML) SS_Save();
   EventKillTimer();

   for(int i = ObjectsTotal() - 1; i >= 0; i--)
     {
      string nm = ObjectName(i);
      if(StringFind(nm, "P_") == 0 ||
         StringFind(nm, "SR_") == 0 ||
         StringFind(nm, "CANAL_") == 0)
         ObjectDelete(nm);
     }
   ChartRedraw();
   Print("SAMU AI v9.0 detenido");
  }

//====================================================================
//======================== ONTICK ====================================
//====================================================================
void OnTick()
  {
   if(!g_VisInit) { InicializarVisuales(); g_VisInit = true; }

   // 1) Actualizar flotante + máquina de estados
   ActualizarFlotante();
   ActualizarModo();

   // 2) Gestión de posiciones (BE, trailing, parcial, fast exit, timeout, lock)
   GestionarPosiciones();

   // 3) Procesar cierres (aprendizaje + stats)
   ProcesarCierres();

   // 4) Circuit breaker
   ActualizarCircuitBreaker();
   if(TimeCurrent() < g_PausaHasta) { ActualizarPanel(); return; }

   // 5) Recovery decide nueva táctica cada N min
   if(g_modoActual == MODE_RECOVERY) RecoveryDecide();

   // 6) Niveles visuales
   if(MostrarPisosTechos && Bars > 150) ActualizarNiveles();

   // 7) Símbolos ocupados
   string ocupados[];
   int numOcupados = 0;
   ArrayResize(ocupados, 0);
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderMagicNumber() != Magic1 && OrderMagicNumber() != Magic2) continue;
      bool dup = false;
      for(int j = 0; j < numOcupados; j++)
         if(ocupados[j] == OrderSymbol()) { dup = true; break; }
      if(!dup)
        {
         numOcupados++;
         ArrayResize(ocupados, numOcupados, 0);
         ocupados[numOcupados-1] = OrderSymbol();
        }
     }

   // 8) Procesar cada símbolo
   for(int s = 0; s < NumSimbolos; s++)
      ProcesarSimbolo(s, numOcupados, ocupados);

   ActualizarPanel();
  }

void OnTimer()
  {
   if(!ActivarRedNeural) return;
   if(Bars < VentanaEntrenamiento + 50) return;

   if(Time[0] != g_UltimaBarraEntren)
     {
      g_UltimaBarraEntren = Time[0];
      EntrenarRedSupervisado();
     }

   int minReplay = (int)((TimeCurrent() - g_UltimoReplay) / 60);
   if(minReplay >= (60 / MathMax(1, ReplaysPorHora)))
     {
      g_UltimoReplay = TimeCurrent();
      EntrenarConReplay(BatchReplay);
     }
  }

//====================================================================
//=================== FLOTANTE Y MODO ================================
//====================================================================
void ActualizarFlotante()
  {
   g_floatingNow = 0;
   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderMagicNumber() != Magic1 && OrderMagicNumber() != Magic2) continue;
      g_floatingNow += OrderProfit() + OrderSwap() + OrderCommission();
     }
   if(g_floatingNow > g_floatingPeak)
      g_floatingPeak = g_floatingNow;
  }

void ActualizarModo()
  {
   int abiertas = ContarAbiertas();
   if(abiertas == 0 && g_floatingNow == 0)
     {
      // Reset pico si no hay nada
      static int tickVacio = 0;
      tickVacio++;
      if(tickVacio > 5)
        {
         g_floatingPeak = 0;
         tickVacio = 0;
        }
     }
   else
     {
      // Reset del contador si hay actividad
     }

   // Calcular R acumulada
   double riesgoTotal = CalcularRiesgoAbiertoUSD();
   double rAcum = (riesgoTotal > 0) ? g_floatingNow / riesgoTotal : 0;
   double pctBal = (AccountBalance() > 0) ? (g_floatingNow / AccountBalance()) * 100.0 : 0;

   bool triggerRecovery = (rAcum <= Recov_TriggerR) || (pctBal <= -Recov_TriggerPct);

   if(g_modoActual == MODE_NORMAL)
     {
      if(triggerRecovery && ActivarRecovery && abiertas > 0)
        {
         g_modoActual        = MODE_RECOVERY;
         g_inicioRecovery    = TimeCurrent();
         g_ultimaReevaluacion= 0;
         g_intentosRecovery  = 0;
         g_pnlInicioRecovery = g_floatingNow;
         g_tacticaActual     = TAC_SCALP;
         g_agresividad       = 1.0;
         Print(">>> RECOVERY: flotante=", DoubleToString(g_floatingNow,2),
               " R=", DoubleToString(rAcum,2));
        }
     }
   else if(g_modoActual == MODE_RECOVERY)
     {
      // Damage cap absoluto
      double dano = g_floatingNow - g_pnlInicioRecovery;
      double danoMax = AccountBalance() * (Recov_DamageCapPct / 100.0);
      if(dano <= -danoMax)
        {
         Print(">>> RECOVERY ABORTADO — daño máximo alcanzado ($",
               DoubleToString(dano,2), ")");
         CerrarTodo();
         g_modoActual = MODE_PROTECT;
         g_PausaHasta = TimeCurrent() + Recov_PausaHoras * 3600;
         return;
        }

      // Recuperado
      if(g_floatingNow >= 0 && abiertas == 0)
        {
         Print(">>> RECUPERADO — volviendo a NORMAL");
         g_modoActual = MODE_NORMAL;
         g_intentosRecovery = 0;
         g_agresividad = 1.0;
         g_tacticaActual = TAC_SCALP;
        }
      // Demasiados intentos
      else if(g_intentosRecovery >= Recov_MaxIntentos)
        {
         Print(">>> PROTECT — ", g_intentosRecovery, " intentos");
         CerrarTodo();
         g_modoActual = MODE_PROTECT;
         g_PausaHasta = TimeCurrent() + Recov_PausaHoras * 3600;
        }
     }
   else if(g_modoActual == MODE_PROTECT)
     {
      if(TimeCurrent() >= g_PausaHasta)
        {
         g_modoActual = MODE_NORMAL;
         g_intentosRecovery = 0;
         g_agresividad = 1.0;
         g_tacticaActual = TAC_SCALP;
         Print(">>> PROTECT finalizado");
        }
     }
  }

int ContarAbiertas()
  {
   int c = 0;
   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderMagicNumber() != Magic1 && OrderMagicNumber() != Magic2) continue;
      c++;
     }
   return c;
  }

double CalcularRiesgoAbiertoUSD()
  {
   double total = 0;
   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderMagicNumber() != Magic1 && OrderMagicNumber() != Magic2) continue;
      string s = OrderSymbol();
      double sl = OrderStopLoss();
      double op = OrderOpenPrice();
      if(sl <= 0) continue;
      double dist = MathAbs(op - sl);
      double tv = MarketInfo(s, MODE_TICKVALUE);
      double ts = MarketInfo(s, MODE_TICKSIZE);
      if(tv <= 0 || ts <= 0) continue;
      total += (dist / ts) * tv * OrderLots();
     }
   return total;
  }

//====================================================================
//=================== RECOVERY ENGINE ================================
//====================================================================
void RecoveryDecide()
  {
   if(TimeCurrent() - g_ultimaReevaluacion < Recov_TimeoutMin * 60) return;
   g_ultimaReevaluacion = TimeCurrent();

   string sym = Symbol();
   int regimen = DetectarRegimen(sym);

   double atr   = iATR(sym, PERIOD_CURRENT, 14, 0);
   double atr100= iATR(sym, PERIOD_CURRENT, 100, 0);
   double volat = (atr100 > 0) ? atr/atr100 : 1.0;

   double ema50  = iMA(sym, PERIOD_CURRENT, 50, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ema200 = iMA(sym, PERIOD_CURRENT, 200, 0, MODE_EMA, PRICE_CLOSE, 0);
   double pendiente = (ema200 != 0) ? (ema50 - ema200) / ema200 * 100 : 0;

   // Features + IA
   double features[NN_INPUTS];
   ExtraerFeatures(sym, features);
   double predNN  = ForwardPass(features);
   double votoNN  = (predNN - 0.5) * 2.0;
   double votoEns = VotarEstrategias(features);
   double scoreIA = g_pesoNN * votoNN + g_pesoEns * votoEns;

   // WR reciente
   int wins5 = 0, tot5 = 0;
   for(int h = OrdersHistoryTotal() - 1; h >= 0 && tot5 < 10; h--)
     {
      if(!OrderSelect(h, SELECT_BY_POS, MODE_HISTORY)) continue;
      if(OrderMagicNumber() != Magic1 && OrderMagicNumber() != Magic2) continue;
      tot5++;
      if(OrderProfit() + OrderSwap() + OrderCommission() > 0) wins5++;
     }
   double wrReciente = (tot5 > 0) ? (double)wins5 / tot5 : 0.5;

   // Sesgo actual
   double netoLargo = 0, netoCorto = 0;
   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderMagicNumber() != Magic1 && OrderMagicNumber() != Magic2) continue;
      if(OrderType() == OP_BUY)  netoLargo += OrderLots();
      if(OrderType() == OP_SELL) netoCorto += OrderLots();
     }
   double sesgo = netoLargo - netoCorto;

   // ===== DECISIÓN =====
   int nuevaTac = TAC_SCALP;
   double nuevaAgr = 1.0;
   string razon = "";

   if(wrReciente < 0.30 && tot5 >= 5)
     {
      nuevaTac = TAC_FLAT;
      razon = "WR critico (" + DoubleToString(wrReciente*100,0) + "%)";
     }
   else if((regimen == REG_ALZA && sesgo < 0) ||
           (regimen == REG_BAJA && sesgo > 0))
     {
      nuevaTac = TAC_HEDGE;
      nuevaAgr = 1.1;
      razon = "Contra-tendencia → HEDGE";
     }
   else if(scoreIA * sesgo < -0.1)
     {
      nuevaTac = TAC_HEDGE;
      nuevaAgr = 1.15;
      razon = "IA contradice posiciones";
     }
   else if(volat > 1.4)
     {
      nuevaTac = TAC_SCALP;
      nuevaAgr = 1.15;
      razon = "Alta volatilidad → SCALP agresivo";
     }
   else
     {
      nuevaTac = TAC_SCALP;
      nuevaAgr = 1.05;
      razon = "Default → SCALP";
     }

   if(nuevaTac != g_tacticaActual || MathAbs(nuevaAgr - g_agresividad) > 0.05)
     {
      Print(">>> RECOVERY TACTICA: ", NombreTactica(g_tacticaActual), " → ",
            NombreTactica(nuevaTac), " | agr=", DoubleToString(nuevaAgr,2),
            " | ", razon);
      g_tacticaActual = nuevaTac;
      g_agresividad = MathMin(nuevaAgr, Recov_LotMultMax);
      AplicarTactica();
     }
  }

string NombreTactica(int t)
  {
   switch(t)
     {
      case TAC_SCALP: return "SCALP";
      case TAC_HEDGE: return "HEDGE";
      case TAC_FLAT:  return "FLAT";
     }
   return "?";
  }

void AplicarTactica()
  {
   if(g_tacticaActual == TAC_FLAT)
     {
      CerrarTodo();
      Print("RECOVERY: FLAT aplicado");
      return;
     }

   if(g_tacticaActual == TAC_HEDGE)
     {
      string sym = Symbol();
      int regimen = DetectarRegimen(sym);
      int dirObj = 0;
      if(regimen == REG_ALZA) dirObj =  1;
      if(regimen == REG_BAJA) dirObj = -1;

      for(int i = OrdersTotal() - 1; i >= 0; i--)
        {
         if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
         if(OrderMagicNumber() != Magic1 && OrderMagicNumber() != Magic2) continue;
         bool contra = (dirObj > 0 && OrderType() == OP_SELL) ||
                       (dirObj < 0 && OrderType() == OP_BUY);
         if(contra)
           {
            double p = (OrderType() == OP_BUY) ? MarketInfo(OrderSymbol(), MODE_BID)
                                               : MarketInfo(OrderSymbol(), MODE_ASK);
            OrderClose(OrderTicket(), OrderLots(), p, 20, clrOrange);
           }
        }
      Print("RECOVERY: HEDGE — contra-tendencia cerradas");
     }
  }

//====================================================================
//=================== GESTIÓN DE POSICIONES ==========================
//====================================================================
void GestionarPosiciones()
  {
   // ---- 1) PROFIT LOCK ----
   if(ActivarProfitLock && g_floatingPeak >= ProfitLock_MinUSD && g_floatingNow < g_floatingPeak)
     {
      double back = (g_floatingPeak - g_floatingNow) / g_floatingPeak * 100.0;
      if(back >= ProfitLock_Back)
        {
         Print(">>> PROFIT LOCK: pico=$", DoubleToString(g_floatingPeak,2),
               " actual=$", DoubleToString(g_floatingNow,2),
               " (−", DoubleToString(back,1), "%) → CERRAR TODO");
         CerrarTodo();
         g_floatingPeak = 0;
         return;
        }
     }

   // ---- 2) Gestión por orden ----
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderMagicNumber() != Magic1 && OrderMagicNumber() != Magic2) continue;
      if(OrderType() != OP_BUY && OrderType() != OP_SELL) continue;
      GestionarOrden();
     }
  }

void GestionarOrden()
  {
   int tk = OrderTicket();
   int idxM = BuscarIdxTicket(tk);
   if(idxM < 0) return;

   double R = g_mgmtR[idxM];
   if(R <= 0) return;

   string sym = OrderSymbol();
   int dg = (int)MarketInfo(sym, MODE_DIGITS);
   double tick = MarketInfo(sym, MODE_TICKSIZE);
   double lMin = MarketInfo(sym, MODE_MINLOT);
   double lStep = MarketInfo(sym, MODE_LOTSTEP);
   int dLote = 2;
   if(lStep == 0.1) dLote = 1; else if(lStep == 1.0) dLote = 0;

   double op  = OrderOpenPrice();
   double sl  = OrderStopLoss();
   double bid = MarketInfo(sym, MODE_BID);
   double ask = MarketInfo(sym, MODE_ASK);
   bool esBuy = (OrderType() == OP_BUY);

   double ganancia = esBuy ? (bid - op) : (op - ask);
   double Rmult = ganancia / R;

   int minutos = (int)((TimeCurrent() - OrderOpenTime()) / 60);

   // ---- FAST EXIT: ganancia rápida ----
   if(ActivarFastExit && Rmult >= FastExit_R && minutos <= FastExit_Min)
     {
      double p = esBuy ? bid : ask;
      if(OrderClose(tk, OrderLots(), p, 20, clrLime))
        {
         Print("FAST EXIT: ", sym, " ", DoubleToString(Rmult,2), "R en ", minutos, " min");
         return;
        }
     }

   // ---- TIMEOUT ----
   if(minutos >= Timeout_Scalp_Min)
     {
      double p = esBuy ? bid : ask;
      if(OrderClose(tk, OrderLots(), p, 20, clrGray))
        {
         Print("TIMEOUT: ", sym, " tras ", minutos, " min");
         return;
        }
     }

   // ---- PARCIAL ----
   if(ActivarParcial && !g_mgmtParcial[idxM] && Rmult >= Parcial_R)
     {
      double loteOrig = OrderLots();
      double loteCerrar = NormalizeDouble(loteOrig * Parcial_Pct / 100.0, dLote);
      double loteDejar  = NormalizeDouble(loteOrig - loteCerrar, dLote);
      if(loteCerrar >= lMin && loteDejar >= lMin)
        {
         double p = esBuy ? bid : ask;
         if(OrderClose(tk, loteCerrar, p, 20, clrGold))
           {
            g_mgmtParcial[idxM] = true;
            Print("PARCIAL 50%: ", sym, " @ ", DoubleToString(Rmult,2), "R");
           }
        }
     }

   // ---- BREAK EVEN ----
   if(ActivarBreakEven && !g_mgmtBE[idxM] && Rmult >= BreakEven_R)
     {
      double lockPips = BreakEven_LockPips;
      double pipSize = tick;
      if(dg == 3 || dg == 5 || StringFind(sym, "JPY") >= 0) pipSize = tick * 10;
      double lockDist = lockPips * pipSize;

      double beSL = esBuy ? NormalizeDouble(op + lockDist, dg)
                          : NormalizeDouble(op - lockDist, dg);

      bool mejora = esBuy ? (beSL > sl) : (beSL < sl);
      if(mejora)
        {
         if(OrderModify(tk, op, beSL, OrderTakeProfit(), 0, clrAqua))
           {
            g_mgmtBE[idxM] = true;
            Print("BE: ", sym, " @ ", DoubleToString(Rmult,2), "R");
           }
        }
     }

   // ---- TRAILING ----
   if(ActivarTrailing && Rmult >= Trailing_StartR)
     {
      double atr = iATR(sym, PERIOD_CURRENT, 14, 0);
      if(atr <= 0) atr = R;
      double dist = atr * Trailing_ATRMult;
      double nuevoSL = esBuy ? NormalizeDouble(bid - dist, dg)
                             : NormalizeDouble(ask + dist, dg);
      bool mejora = esBuy ? (nuevoSL > sl) : (nuevoSL < sl);
      if(mejora && MathAbs(nuevoSL - sl) >= tick * 5)
         OrderModify(tk, op, nuevoSL, OrderTakeProfit(), 0, clrAqua);
     }
  }

int BuscarIdxTicket(int tk)
  {
   for(int k = 0; k < g_ticketCount; k++)
      if(g_ticketPendiente[k] == tk) return k;
   return -1;
  }

//====================================================================
//=================== PROCESAR SÍMBOLO ===============================
//====================================================================
void ProcesarSimbolo(int idx, int numOcupados, string &ocupados[])
  {
   string sym = ListaSimbolos[idx];

   // ¿Puede operar?
   bool puedeOperar = false;
   if(numOcupados < MaxParesSimultaneos) puedeOperar = true;
   else
      for(int k = 0; k < numOcupados && k < MaxParesSimultaneos; k++)
         if(sym == ocupados[k]) { puedeOperar = true; break; }

   int dg    = (int)MarketInfo(sym, MODE_DIGITS);
   double tick= MarketInfo(sym, MODE_TICKSIZE);
   double lMin= MarketInfo(sym, MODE_MINLOT);
   double lMax= MarketInfo(sym, MODE_MAXLOT);
   double lStep=MarketInfo(sym, MODE_LOTSTEP);
   if(tick <= 0 || dg <= 0) return;

   int dLote = 2;
   if(lStep == 0.1) dLote = 1; else if(lStep == 1.0) dLote = 0;

   bool esCripto = EsCripto(sym);
   double fPip = 10;
   if(dg == 3 && StringFind(sym, "JPY") > 0) fPip = 100;
   if(esCripto && dg <= 2) fPip = 1;
   if(esCripto && dg == 3) fPip = 10;

   // Contar órdenes
   int oC = 0, oV = 0;
   double uPC = 0, uPV = 0;
   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderSymbol() != sym) continue;
      if(OrderMagicNumber() == Magic1 && OrderType() == OP_BUY)
        { oC++; uPC = OrderOpenPrice(); }
      if(OrderMagicNumber() == Magic2 && OrderType() == OP_SELL)
        { oV++; uPV = OrderOpenPrice(); }
     }

   if(sym == Symbol())
     {
      OrdenesCompra = oC; OrdenesVenta = oV;
      ProfitCompra = 0; ProfitVenta = 0;
      for(int i = 0; i < OrdersTotal(); i++)
        {
         if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
         if(OrderSymbol() != sym) continue;
         if(OrderMagicNumber() == Magic1) ProfitCompra += OrderProfit();
         if(OrderMagicNumber() == Magic2) ProfitVenta  += OrderProfit();
        }
     }

   // Filtros
   int regimen = DetectarRegimen(sym);
   if(FiltroRegimen && regimen == REG_CAOS) return;

   if(FiltroSpread)
     {
      double spr = (MarketInfo(sym, MODE_ASK) - MarketInfo(sym, MODE_BID)) / tick / fPip;
      double maxSpr = esCripto ? SpreadMaxCripto : SpreadMaxPips;
      if(spr > maxSpr) return;
     }

   bool aplicarHora = FiltroHorario;
   if(esCripto && SinFiltroHorarioCripto) aplicarHora = false;
   if(aplicarHora)
      if(!(TimeCurrent() >= StringToTime(HoraInicio) && TimeCurrent() < StringToTime(HoraFin)))
         return;

   // Features + IA
   double features[NN_INPUTS];
   ExtraerFeatures(sym, features);
   double predNN  = ForwardPass(features);
   double votoNN  = (predNN - 0.5) * 2.0;
   double votoEns = VotarEstrategias(features);
   double scoreBase = g_pesoNN * votoNN + g_pesoEns * votoEns;

   // SAML
   double samlBoost = 0, samlLotMult = 1.0, samlSL = 1.0, samlTP = 1.0;
   bool samlBlocked = false;
   int fired[SS_MAX_RULES], nFired = 0;
   if(ActivarSAML && g_SSRuleCount > 0)
      SS_Evaluate(idx, sym, features, predNN, votoEns, scoreBase,
                  samlBoost, samlLotMult, samlBlocked, samlSL, samlTP, fired, nFired);

   double scoreFinal = scoreBase + samlBoost;

   if(sym == Symbol())
     {
      UlimoPredNN = predNN;
      UltimoVotoEns = votoEns;
      UltimoScore = scoreFinal;
      g_SSUltBoost = samlBoost;
      g_SSUltLotMult = samlLotMult;
      g_SSUltBlocked = samlBlocked;
      g_SSUltFired = nFired;
     }

   if(samlBlocked) return;

   // Dirección
   int direccion = 0;
   double umbral = esCripto ? 0.25 : 0.30;
   if(scoreFinal >  umbral) direccion =  1;
   if(scoreFinal < -umbral) direccion = -1;
   if(direccion == 0) return;

   // Tendencia
   if(FiltroTendencia)
     {
      double e50 = iMA(sym, PERIOD_CURRENT, 50, 0, MODE_EMA, PRICE_CLOSE, 0);
      double e200= iMA(sym, PERIOD_CURRENT, 200, 0, MODE_EMA, PRICE_CLOSE, 0);
      if(direccion > 0 && e50 < e200) return;
      if(direccion < 0 && e50 > e200) return;
     }

   // SL/TP
   double atr = iATR(sym, PERIOD_CURRENT, 14, 0);
   if(atr <= 0) return;
   double multATR = esCripto ? MultiplicadorATRCripto : 1.0;

   double slDist = atr * SL_BaseR * multATR * samlSL;
   double tpDist = atr * TP_BaseR * multATR * samlTP;

   // Recovery: SL/TP reducidos si SCALP agresivo
   if(g_modoActual == MODE_RECOVERY && g_tacticaActual == TAC_SCALP)
     {
      slDist = atr * 0.7 * multATR * samlSL;
      tpDist = atr * 0.9 * multATR * samlTP;
     }

   double ask = MarketInfo(sym, MODE_ASK);
   double bid = MarketInfo(sym, MODE_BID);
   double sl, tp;

   if(direccion > 0)
     { sl = NormalizeDouble(ask - slDist, dg); tp = NormalizeDouble(ask + tpDist, dg); }
   else
     { sl = NormalizeDouble(bid + slDist, dg); tp = NormalizeDouble(bid - tpDist, dg); }

   // ---- SIZING con topes DUROS ----
   double lote = CalcularLote(idx, slDist, lMin, lMax, dLote);

   // Recovery agresividad (cap 1.2)
   if(g_modoActual == MODE_RECOVERY)
      lote = NormalizeDouble(lote * MathMin(g_agresividad, Recov_LotMultMax), dLote);

   // SAML lotMult (cap 1.3)
   double sm = samlLotMult;
   if(sm > SAML_LotMultCap) sm = SAML_LotMultCap;
   if(sm < 0.4) sm = 0.4;
   lote = NormalizeDouble(lote * sm, dLote);

   // Caps DD
   if(g_NivelDD >= 1) lote = NormalizeDouble(lote * 0.5, dLote);
   if(g_NivelDD >= 2) lote = NormalizeDouble(lMin, dLote);
   if(lote < lMin) lote = lMin;
   if(lote > lMax) lote = lMax;

   // ---- VERIFICACIÓN DE RIESGO FINAL (duro) ----
   double riesgoUSD = (slDist / tick) * MarketInfo(sym, MODE_TICKVALUE) * lote;
   double riesgoPct = (riesgoUSD / AccountBalance()) * 100.0;

   // Aplicar tope absoluto por trade
   if(riesgoPct > RiesgoMaxAbsoluto)
     {
      double factor = RiesgoMaxAbsoluto / riesgoPct;
      lote = NormalizeDouble(lote * factor, dLote);
      if(lote < lMin) return;   // ni con lMin cabe → no operar
      riesgoUSD = (slDist / tick) * MarketInfo(sym, MODE_TICKVALUE) * lote;
      riesgoPct = (riesgoUSD / AccountBalance()) * 100.0;
     }

   // Tope agregado
   double riesgoAgregadoPct = (CalcularRiesgoAbiertoUSD() / AccountBalance()) * 100.0;
   if(riesgoAgregadoPct + riesgoPct > RiesgoAgregadoMax) return;

   // Límite de órdenes por símbolo
   if(direccion > 0 && oC >= MaxOrdenesSimbolo) return;
   if(direccion < 0 && oV >= MaxOrdenesSimbolo) return;

   // Distancia grid
   if(direccion > 0 && oC > 0)
     {
      double next = uPC - DistanciaGridPips * fPip * tick;
      if(ask > next) return;
     }
   if(direccion < 0 && oV > 0)
     {
      double next = uPV + DistanciaGridPips * fPip * tick;
      if(bid < next) return;
     }

   if(!puedeOperar) return;
   if(AccountFreeMargin() < MarketInfo(sym, MODE_MARGINREQUIRED) * lote) return;

   // ---- EJECUCIÓN ----
   int tk = -1;
   if(direccion > 0)
      tk = OrderSend(sym, OP_BUY, lote, ask, 20, sl, tp, ComentarioOrden, Magic1, 0, clrLime);
   else
      tk = OrderSend(sym, OP_SELL, lote, bid, 20, sl, tp, ComentarioOrden, Magic2, 0, clrRed);

   if(tk > 0)
     {
      RegistrarApertura(tk, features, (double)direccion, predNN, votoEns, scoreFinal, slDist);
      for(int kk = 0; kk < g_ticketCount; kk++)
         if(g_ticketPendiente[kk] == tk)
           {
            for(int r = 0; r < SS_MAX_RULES; r++) g_ticketSAMLFire[kk][r] = 0;
            for(int f = 0; f < nFired; f++)
               if(fired[f] >= 0 && fired[f] < SS_MAX_RULES) g_ticketSAMLFire[kk][fired[f]] = 1;
            break;
           }
     }
   else
      Print("OrderSend falló [", sym, "]: ", GetLastError());
  }

//====================================================================
//=================== SIZING BLINDADO ================================
//====================================================================
double CalcularLote(int idx, double slDist, double lMin, double lMax, int dLote)
  {
   string sym = ListaSimbolos[idx];
   double tv = MarketInfo(sym, MODE_TICKVALUE);
   double ts = MarketInfo(sym, MODE_TICKSIZE);
   if(tv <= 0 || slDist <= 0 || ts <= 0) return lMin;

   // Kelly conservador
   double wr = 0.45;   // default conservador
   double payoff = 1.6;
   if(g_trades[idx] >= 30)
     {
      wr = (double)g_wins[idx] / g_trades[idx];
      if(wr < 0.30) wr = 0.30;
      if(wr > 0.70) wr = 0.70;
     }
   double kelly = (wr * payoff - (1.0 - wr)) / payoff;
   if(kelly < 0) kelly = 0;

   double fraccKelly = kelly * FraccionKelly;
   double fraccMax   = RiesgoPorTrade / 100.0;
   double fracc      = MathMin(fraccKelly, fraccMax);

   // Anti-martingala (suave)
   double multRacha = 1.0;
   if(g_consecLoss[idx] == 1) multRacha = 0.75;
   else if(g_consecLoss[idx] >= 2) multRacha = 0.50;
   if(g_consecWin[idx] == 2) multRacha = 1.10;
   else if(g_consecWin[idx] >= 3) multRacha = 1.15;

   double riesgo = AccountBalance() * fracc * multRacha;

   double pipsRiesgo = slDist / ts;
   if(pipsRiesgo < 3.0) pipsRiesgo = 3.0;    // anti-explosión
   if(pipsRiesgo > 500) pipsRiesgo = 500;

   double lotes = riesgo / (pipsRiesgo * tv);
   if(lotes < lMin) lotes = lMin;
   if(lotes > lMax) lotes = lMax;
   return NormalizeDouble(lotes, dLote);
  }

//====================================================================
//=================== FEATURES =======================================
//====================================================================
void ExtraerFeatures(string sym, double &f[])
  {
   double rsi = iRSI(sym, PERIOD_CURRENT, 14, PRICE_CLOSE, 0);
   f[0] = (rsi - 50.0) / 50.0;

   double macd = iMACD(sym, PERIOD_CURRENT, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 0);
   double atr  = iATR(sym, PERIOD_CURRENT, 14, 0);
   f[1] = (atr > 0) ? MathMax(-1.0, MathMin(1.0, macd / atr)) : 0;

   double e20 = iMA(sym, PERIOD_CURRENT, 20, 0, MODE_EMA, PRICE_CLOSE, 0);
   double e50 = iMA(sym, PERIOD_CURRENT, 50, 0, MODE_EMA, PRICE_CLOSE, 0);
   double precio = MarketInfo(sym, MODE_BID);
   f[2] = (precio > 0) ? MathMax(-1.0, MathMin(1.0, (e20 - e50) / precio * 500)) : 0;

   double up = iBands(sym, PERIOD_CURRENT, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, 0);
   double lo = iBands(sym, PERIOD_CURRENT, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, 0);
   f[3] = (up > lo) ? ((precio - lo) / (up - lo)) * 2.0 - 1.0 : 0;

   double atr100 = iATR(sym, PERIOD_CURRENT, 100, 0);
   f[4] = (atr100 > 0) ? MathMax(-1.0, MathMin(1.0, (atr / atr100) - 1.0)) : 0;

   if(Bars > 6)
     {
      double mom = (Close[0] - Close[5]) / MathMax(atr, 0.00001);
      f[5] = MathMax(-1.0, MathMin(1.0, mom));
     }
   else f[5] = 0;

   double stoch = iStochastic(sym, PERIOD_CURRENT, 14, 3, 3, MODE_SMA, 0, MODE_MAIN, 0);
   f[6] = (stoch - 50.0) / 50.0;

   double cci = iCCI(sym, PERIOD_CURRENT, 20, PRICE_TYPICAL, 0);
   f[7] = MathMax(-1.0, MathMin(1.0, cci / 200.0));

   f[8] = MathSin(2.0 * 3.14159 * Hour() / 24.0);
   f[9] = MathCos(2.0 * 3.14159 * DayOfWeek() / 7.0);
  }

bool FeaturesEnBarra(string sym, int bar, double &f[])
  {
   if(bar + 100 >= Bars) return false;

   double rsi = iRSI(sym, PERIOD_CURRENT, 14, PRICE_CLOSE, bar);
   f[0] = (rsi - 50.0) / 50.0;

   double macd = iMACD(sym, PERIOD_CURRENT, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, bar);
   double atr  = iATR(sym, PERIOD_CURRENT, 14, bar);
   f[1] = (atr > 0) ? MathMax(-1.0, MathMin(1.0, macd / atr)) : 0;

   double e20 = iMA(sym, PERIOD_CURRENT, 20, 0, MODE_EMA, PRICE_CLOSE, bar);
   double e50 = iMA(sym, PERIOD_CURRENT, 50, 0, MODE_EMA, PRICE_CLOSE, bar);
   double precio = Close[bar];
   f[2] = (precio > 0) ? MathMax(-1.0, MathMin(1.0, (e20 - e50) / precio * 500)) : 0;

   double up = iBands(sym, PERIOD_CURRENT, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, bar);
   double lo = iBands(sym, PERIOD_CURRENT, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, bar);
   f[3] = (up > lo) ? ((precio - lo) / (up - lo)) * 2.0 - 1.0 : 0;

   double atr100 = iATR(sym, PERIOD_CURRENT, 100, bar);
   f[4] = (atr100 > 0) ? MathMax(-1.0, MathMin(1.0, (atr / atr100) - 1.0)) : 0;

   if(bar + 5 < Bars)
     {
      double mom = (Close[bar] - Close[bar+5]) / MathMax(atr, 0.00001);
      f[5] = MathMax(-1.0, MathMin(1.0, mom));
     }
   else f[5] = 0;

   double stoch = iStochastic(sym, PERIOD_CURRENT, 14, 3, 3, MODE_SMA, 0, MODE_MAIN, bar);
   f[6] = (stoch - 50.0) / 50.0;

   double cci = iCCI(sym, PERIOD_CURRENT, 20, PRICE_TYPICAL, bar);
   f[7] = MathMax(-1.0, MathMin(1.0, cci / 200.0));

   datetime t = Time[bar];
   f[8] = MathSin(2.0 * 3.14159 * TimeHour(t) / 24.0);
   f[9] = MathCos(2.0 * 3.14159 * TimeDayOfWeek(t) / 7.0);
   return true;
  }

//====================================================================
//=================== NN =============================================
//====================================================================
void InicializarRedNeural()
  {
   MathSrand((int)TimeLocal());
   for(int i = 0; i < NN_W1_SIZE; i++)
     { g_W1[i] = (MathRand()/32767.0 - 0.5) * 0.5; g_vW1[i] = 0; }
   for(int i = 0; i < NN_B1_SIZE; i++) { g_B1[i] = 0; g_vB1[i] = 0; }
   for(int i = 0; i < NN_W2_SIZE; i++)
     { g_W2[i] = (MathRand()/32767.0 - 0.5) * 0.5; g_vW2[i] = 0; }
   for(int i = 0; i < NN_B2_SIZE; i++) { g_B2[i] = 0; g_vB2[i] = 0; }
  }

double Sigmoid(double x)
  {
   if(x >  20) return 1.0;
   if(x < -20) return 0.0;
   return 1.0 / (1.0 + MathExp(-x));
  }
double SigmoidDeriv(double y) { return y * (1.0 - y); }
double Tanh(double x) { return 2.0 * Sigmoid(2.0 * x) - 1.0; }

double ForwardPass(double &entrada[])
  {
   for(int i = 0; i < NN_INPUTS; i++) g_input[i] = entrada[i];
   for(int h = 0; h < NN_HIDDEN; h++)
     {
      double s = g_B1[h];
      for(int i = 0; i < NN_INPUTS; i++)
         s += g_input[i] * g_W1[i * NN_HIDDEN + h];
      g_hidden[h] = Tanh(s);
     }
   double out = g_B2[0];
   for(int h = 0; h < NN_HIDDEN; h++)
      out += g_hidden[h] * g_W2[h];
   g_output[0] = Sigmoid(out);
   return g_output[0];
  }

void BackpropUnaMuestra(double &entrada[], double target)
  {
   double pred = ForwardPass(entrada);
   double error = target - pred;
   double dOut = error * SigmoidDeriv(pred);

   double dHidden[NN_HIDDEN];
   for(int h = 0; h < NN_HIDDEN; h++)
      dHidden[h] = dOut * g_W2[h] * (1.0 - g_hidden[h] * g_hidden[h]);

   for(int h = 0; h < NN_HIDDEN; h++)
     {
      double grad = dOut * g_hidden[h];
      g_vW2[h] = MomentumNN * g_vW2[h] + LearningRateNN * grad;
      g_W2[h] += g_vW2[h];
     }
   g_vB2[0] = MomentumNN * g_vB2[0] + LearningRateNN * dOut;
   g_B2[0] += g_vB2[0];

   for(int i = 0; i < NN_INPUTS; i++)
      for(int h = 0; h < NN_HIDDEN; h++)
        {
         double grad = dHidden[h] * entrada[i];
         int idxW = i * NN_HIDDEN + h;
         g_vW1[idxW] = MomentumNN * g_vW1[idxW] + LearningRateNN * grad;
         g_W1[idxW] += g_vW1[idxW];
        }
   for(int h = 0; h < NN_HIDDEN; h++)
     {
      g_vB1[h] = MomentumNN * g_vB1[h] + LearningRateNN * dHidden[h];
      g_B1[h] += g_vB1[h];
     }
  }

void EntrenarRedSupervisado()
  {
   if(!ActivarRedNeural) return;
   int maxB = MathMin(VentanaEntrenamiento, Bars - 20);
   if(maxB < 50) return;

   double sumaErr = 0;
   int muestras = 0;
   g_estadoIA = "ENTRENANDO";

   for(int b = 1; b <= maxB; b++)
     {
      double f[NN_INPUTS];
      if(!FeaturesEnBarra(Symbol(), b, f)) continue;
      double ret = Close[b-1] - Close[b];
      double target = (ret > 0) ? 1.0 : 0.0;
      double pred = ForwardPass(f);
      double error = target - pred;
      sumaErr += error * error;
      muestras++;
      BackpropUnaMuestra(f, target);
      if(muestras >= 200) break;
     }
   double mse = (muestras > 0) ? sumaErr / muestras : 0;
   g_estadoIA = "MSE=" + DoubleToString(mse, 4);
  }

//====================================================================
//=================== POOL GENÉTICO ==================================
//====================================================================
void InicializarPool()
  {
   MathSrand((int)TimeLocal() + 42);
   for(int s = 0; s < TamanoPoolEstrategias; s++)
     {
      for(int i = 0; i < STRAT_FEATURES; i++)
         g_Pool[s][i] = (MathRand()/32767.0 - 0.5) * 2.0;
      g_Fitness[s] = 0;
      g_EdadEstrategia[s] = 0;
     }
  }

double VotarEstrategias(double &features[])
  {
   double sumaPond = 0, sumaPesos = 0;
   for(int s = 0; s < TamanoPoolEstrategias; s++)
     {
      double voto = 0;
      for(int i = 0; i < STRAT_FEATURES; i++)
         voto += g_Pool[s][i] * features[i];
      voto = Tanh(voto);
      double peso = MathMax(0.01, g_Fitness[s] + 0.5);
      sumaPond += voto * peso;
      sumaPesos += peso;
     }
   if(sumaPesos < 0.001) return 0;
   return sumaPond / sumaPesos;
  }

void EvolucionarPool()
  {
   for(int s = 0; s < TamanoPoolEstrategias; s++)
      g_Fitness[s] = EvaluarEstrategia(s, 200);

   int indices[64];
   for(int i = 0; i < TamanoPoolEstrategias; i++) indices[i] = i;
   for(int i = 0; i < TamanoPoolEstrategias - 1; i++)
      for(int j = i + 1; j < TamanoPoolEstrategias; j++)
         if(g_Fitness[indices[j]] > g_Fitness[indices[i]])
           { int t = indices[i]; indices[i] = indices[j]; indices[j] = t; }

   int top = TamanoPoolEstrategias / 2;
   double nueva[64][STRAT_FEATURES];
   double nuevosFit[64];

   for(int i = 0; i < top; i++)
     {
      int src = indices[i];
      for(int k = 0; k < STRAT_FEATURES; k++) nueva[i][k] = g_Pool[src][k];
      nuevosFit[i] = g_Fitness[src];
     }

   MathSrand((int)TimeLocal() + g_Generacion * 97);
   for(int i = top; i < TamanoPoolEstrategias; i++)
     {
      int p1 = indices[MathRand() % top];
      int p2 = indices[MathRand() % top];
      int cruce = MathRand() % STRAT_FEATURES;
      for(int k = 0; k < STRAT_FEATURES; k++)
        {
         double gen = (k < cruce) ? g_Pool[p1][k] : g_Pool[p2][k];
         if((MathRand() % 100) < 15)
            gen += (MathRand()/32767.0 - 0.5) * 0.8;
         if(gen >  2.0) gen =  2.0;
         if(gen < -2.0) gen = -2.0;
         nueva[i][k] = gen;
        }
      nuevosFit[i] = 0;
     }

   for(int i = 0; i < TamanoPoolEstrategias; i++)
     {
      for(int k = 0; k < STRAT_FEATURES; k++) g_Pool[i][k] = nueva[i][k];
      g_Fitness[i] = nuevosFit[i];
      g_EdadEstrategia[i]++;
     }
   g_Generacion++;
   Print("Pool Gen #", g_Generacion);
  }

double EvaluarEstrategia(int idx, int barras)
  {
   int maxB = MathMin(barras, Bars - 20);
   double aciertos = 0, total = 0;
   for(int b = 1; b <= maxB; b++)
     {
      double f[NN_INPUTS];
      if(!FeaturesEnBarra(Symbol(), b, f)) continue;
      double voto = 0;
      for(int k = 0; k < STRAT_FEATURES; k++)
         voto += g_Pool[idx][k] * f[k];
      voto = Tanh(voto);
      double ret = Close[b-1] - Close[b];
      if(MathAbs(voto) < 0.2) continue;
      if(voto > 0 && ret > 0) aciertos++;
      else if(voto < 0 && ret < 0) aciertos++;
      total++;
     }
   return (total > 0) ? aciertos / total : 0.5;
  }

//====================================================================
//=================== REPLAY =========================================
//====================================================================
void RegistrarExperiencia(double &features[], double accion, double recompensa)
  {
   int cap = MathMin(MaxExperiencia, MAX_EXP_HARD);
   int pos = g_exp_pos;
   for(int i = 0; i < NN_INPUTS; i++) g_exp_feat[pos][i] = features[i];
   g_exp_acc[pos] = accion;
   g_exp_rew[pos] = recompensa;
   g_exp_tim[pos] = TimeCurrent();
   g_exp_pos = (g_exp_pos + 1) % cap;
   if(g_exp_count < cap) g_exp_count++;
  }

void EntrenarConReplay(int batchSize)
  {
   if(g_exp_count < 100) return;
   MathSrand((int)TimeLocal() + g_exp_entrenamientos);
   double sumaErr = 0;
   int exitos = 0;
   double buffer[NN_INPUTS];

   for(int b = 0; b < batchSize; b++)
     {
      int idx = MathRand() % g_exp_count;
      double target;
      if(g_exp_acc[idx] > 0.5)        target = (g_exp_rew[idx] > 0) ? 1.0 : 0.0;
      else if(g_exp_acc[idx] < -0.5)  target = (g_exp_rew[idx] > 0) ? 0.0 : 1.0;
      else continue;
      for(int i = 0; i < NN_INPUTS; i++) buffer[i] = g_exp_feat[idx][i];
      double pred = ForwardPass(buffer);
      double error = target - pred;
      sumaErr += error * error;
      exitos++;
      BackpropUnaMuestra(buffer, target);
     }
   g_exp_entrenamientos++;
   if(g_exp_entrenamientos % 10 == 0)
      Print("Replay #", g_exp_entrenamientos, " buffer=", g_exp_count);
  }

//====================================================================
//=================== REGISTRO APERTURA / CIERRE =====================
//====================================================================
void RegistrarApertura(int ticket, double &features[], double accion,
                       double predNN, double votoEns, double score, double slDist)
  {
   if(g_ticketCount >= MAX_TICKETS) return;
   int i = g_ticketCount;
   g_ticketPendiente[i] = ticket;
   for(int k = 0; k < NN_INPUTS; k++) g_ticketFeat[i][k] = features[k];
   g_ticketAccion[i]  = accion;
   g_ticketPredNN[i]  = predNN;
   g_ticketVotoEns[i] = votoEns;
   g_ticketScore[i]   = score;
   g_ticketHora[i]    = TimeCurrent();
   g_mgmtR[i]         = slDist;
   g_mgmtBE[i]        = false;
   g_mgmtParcial[i]   = false;
   for(int r = 0; r < SS_MAX_RULES; r++) g_ticketSAMLFire[i][r] = 0;
   g_ticketCount++;
  }

void ProcesarCierres()
  {
   int total = OrdersHistoryTotal();
   for(int h = total - 1; h >= 0 && h >= total - 30; h--)
     {
      if(!OrderSelect(h, SELECT_BY_POS, MODE_HISTORY)) continue;
      if(OrderMagicNumber() != Magic1 && OrderMagicNumber() != Magic2) continue;
      if(OrderType() != OP_BUY && OrderType() != OP_SELL) continue;

      int tk = OrderTicket();

      // Saltar si ya procesado
      bool procesado = false;
      for(int k = 0; k < g_ticketCount; k++)
         if(g_ticketPendiente[k] == -tk) { procesado = true; break; }
      if(procesado) continue;

      double pnl = OrderProfit() + OrderSwap() + OrderCommission();

      // Encontrar contexto
      double f[NN_INPUTS];
      ArrayInitialize(f, 0);
      double accion = 0;
      int fired[SS_MAX_RULES];
      for(int r = 0; r < SS_MAX_RULES; r++) fired[r] = 0;

      for(int k = 0; k < g_ticketCount; k++)
        {
         if(g_ticketPendiente[k] == tk)
           {
            for(int i = 0; i < NN_INPUTS; i++) f[i] = g_ticketFeat[k][i];
            accion = g_ticketAccion[k];
            for(int r = 0; r < SS_MAX_RULES; r++) fired[r] = g_ticketSAMLFire[k][r];
            g_ticketPendiente[k] = -tk;
            break;
           }
        }

      // Reward normalizado por riesgo
      double rewardR = 0;
      double riesgoUSD = 0;
      if(OrderStopLoss() > 0 && OrderOpenPrice() > 0)
        {
         double dist = MathAbs(OrderOpenPrice() - OrderStopLoss());
         double tv = MarketInfo(OrderSymbol(), MODE_TICKVALUE);
         double ts = MarketInfo(OrderSymbol(), MODE_TICKSIZE);
         if(tv > 0 && ts > 0)
           {
            riesgoUSD = (dist / ts) * tv * OrderLots();
            if(riesgoUSD > 0) rewardR = pnl / riesgoUSD;
           }
        }

      RegistrarExperiencia(f, accion, rewardR);

      // SAML: actualizar fitness
      if(ActivarSAML)
        {
         bool win = (pnl > 0);
         for(int r = 0; r < g_SSRuleCount; r++)
           {
            if(fired[r] == 1)
              {
               if(win) g_SSRules[r].hits++;
               else    g_SSRules[r].misses++;
               int tot = g_SSRules[r].hits + g_SSRules[r].misses;
               if(tot > 0) g_SSRules[r].fitness = (double)g_SSRules[r].hits / tot;
              }
           }
         g_SSTradesEvo++;
         if(g_SSTradesEvo >= SAML_EvolucionCada)
           {
            g_SSTradesEvo = 0;
            SS_Evolve();
           }
        }

      // Stats
      g_totalTrades++;
      if(pnl > 0) g_totalWins++; else g_totalLosses++;
      g_totalPnL += pnl;

      int idxS = BuscarIdxSimbolo(OrderSymbol());
      if(idxS >= 0)
        {
         g_trades[idxS]++;
         if(pnl > 0) { g_wins[idxS]++; g_consecWin[idxS]++; g_consecLoss[idxS] = 0; }
         else        { g_losses[idxS]++; g_consecLoss[idxS]++; g_consecWin[idxS] = 0; }
         g_pnl[idxS] += pnl;
        }

      // Journal
      EscribirJournal(tk, OrderSymbol(), pnl, rewardR);
     }

   // Evolución pool genético
   g_tradesDesdeEvolucion++;
   if(g_tradesDesdeEvolucion >= FrecuenciaEvolucion)
     {
      g_tradesDesdeEvolucion = 0;
      EvolucionarPool();
     }

   ActualizarMetaPesos();
  }

void ActualizarMetaPesos()
  {
   // Simplificado: usar WR global de NN vs ensemble mediante SAML hits
   // (mantenemos pesos fijos por seguridad)
   if(g_pesoNN < 0.1) g_pesoNN = 0.1;
   if(g_pesoEns < 0.1) g_pesoEns = 0.1;
  }

//====================================================================
//=================== CIRCUIT BREAKER ================================
//====================================================================
void ActualizarCircuitBreaker()
  {
   if(!ActivarCircuitBreaker) return;
   double eq = AccountEquity();
   if(eq > g_peakEquity) g_peakEquity = eq;
   double dd = (g_peakEquity > 0) ? (g_peakEquity - eq)/g_peakEquity*100.0 : 0;
   if(dd > g_maxDDHist) g_maxDDHist = dd;

   if(dd >= DD_Nivel3)
     {
      g_NivelDD = 3;
      g_PausaHasta = TimeCurrent() + HorasPausaDD * 3600;
      CerrarTodo();
      Print("CB: DD ", DoubleToString(dd,2), "% — pausa ", HorasPausaDD, "h");
     }
   else if(dd >= DD_Nivel2) g_NivelDD = 2;
   else if(dd >= DD_Nivel1) g_NivelDD = 1;
   else                     g_NivelDD = 0;
  }

void CerrarTodo()
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderMagicNumber() != Magic1 && OrderMagicNumber() != Magic2) continue;
      if(OrderType() == OP_BUY)
         OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 20, clrRed);
      else if(OrderType() == OP_SELL)
         OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 20, clrRed);
     }
  }

//====================================================================
//=================== REGÍMENES ======================================
//====================================================================
int DetectarRegimen(string sym)
  {
   double atr14  = iATR(sym, PERIOD_CURRENT, 14, 0);
   double atr100 = iATR(sym, PERIOD_CURRENT, 100, 0);
   if(atr100 <= 0) return REG_RANGO;
   double ratio = atr14 / atr100;
   double limCaos = ModoCripto ? 3.0 : 1.8;
   if(ratio > limCaos) return REG_CAOS;

   double adx = iADX(sym, PERIOD_CURRENT, 14, PRICE_CLOSE, MODE_MAIN, 0);
   double e50 = iMA(sym, PERIOD_CURRENT, 50, 0, MODE_EMA, PRICE_CLOSE, 0);
   double e200= iMA(sym, PERIOD_CURRENT, 200, 0, MODE_EMA, PRICE_CLOSE, 0);
   if(adx > 25)
     {
      if(e50 > e200) return REG_ALZA;
      if(e50 < e200) return REG_BAJA;
     }
   return REG_RANGO;
  }

bool EsCripto(string sym)
  {
   if(!ModoCripto) return false;
   if(StringFind(sym, "BTC") >= 0) return true;
   if(StringFind(sym, "ETH") >= 0) return true;
   if(StringFind(sym, "XRP") >= 0) return true;
   if(StringFind(sym, "LTC") >= 0) return true;
   if(StringFind(sym, "ADA") >= 0) return true;
   if(StringFind(sym, "SOL") >= 0) return true;
   return false;
  }

//====================================================================
//=================== SAML ENGINE ====================================
//====================================================================
void SS_InitSemilla()
  {
   g_SSRuleCount = 0;
   g_SSNextId = 1;
   g_SSGeneration = 0;

   // R1: RSI extremo → BOOST
   SS_AddRule(10, 0, SS_OP_GT, 0.7, 0, 0.10);
   // R2: NN bajista fuerte → lot reducido
   SS_AddRule(8, SS_FEAT_NN, SS_OP_LT, -0.5, 1, 0.85);
   // R3: DD≥6% → BLOCK
   SS_AddRule(15, SS_FEAT_DD, SS_OP_GE, 6.0, 2, 0);
   // R4: racha negativa → lot reducido
   SS_AddRule(7, SS_FEAT_CL, SS_OP_GE, 2, 1, 0.75);
   // R5: score fuerte + → BOOST
   SS_AddRule(6, SS_FEAT_SCORE, SS_OP_GT, 0.5, 0, 0.08);

   Print("SAML: ", g_SSRuleCount, " reglas semilla");
  }

void SS_AddRule(int prio, int idx1, int op1, double v1, int act, double av)
  {
   if(g_SSRuleCount >= SS_MAX_RULES) return;
   int i = g_SSRuleCount;
   g_SSRules[i].id = g_SSNextId++;
   g_SSRules[i].priority = prio;
   g_SSRules[i].active = 1;
   g_SSRules[i].condCount = 1;
   g_SSRules[i].condIdx[0] = idx1;
   g_SSRules[i].condOp[0]  = op1;
   g_SSRules[i].condVal[0] = v1;
   g_SSRules[i].condLogic[0] = 0;
   for(int c = 1; c < SS_MAX_COND; c++)
     {
      g_SSRules[i].condIdx[c] = 0;
      g_SSRules[i].condOp[c]  = SS_OP_GT;
      g_SSRules[i].condVal[c] = 0;
      g_SSRules[i].condLogic[c] = 0;
     }
   g_SSRules[i].actionType = act;
   g_SSRules[i].actionVal  = av;
   g_SSRules[i].hits = 0; g_SSRules[i].misses = 0;
   g_SSRules[i].fitness = 0.5;
   g_SSRules[i].generation = 0;
   g_SSRuleCount++;
  }

void SS_AddRuleFull(int prio, int nc,
                    int idx1, int op1, double v1, int log1,
                    int idx2, int op2, double v2, int log2,
                    int act, double av)
  {
   if(g_SSRuleCount >= SS_MAX_RULES) return;
   int i = g_SSRuleCount;
   g_SSRules[i].id = g_SSNextId++;
   g_SSRules[i].priority = prio;
   g_SSRules[i].active = 1;
   g_SSRules[i].condCount = (nc < 1) ? 1 : ((nc > SS_MAX_COND) ? SS_MAX_COND : nc);
   g_SSRules[i].condIdx[0] = idx1; g_SSRules[i].condOp[0] = op1;
   g_SSRules[i].condVal[0] = v1;   g_SSRules[i].condLogic[0] = log1;
   g_SSRules[i].condIdx[1] = idx2; g_SSRules[i].condOp[1] = op2;
   g_SSRules[i].condVal[1] = v2;   g_SSRules[i].condLogic[1] = log2;
   g_SSRules[i].condIdx[2] = 0; g_SSRules[i].condOp[2] = SS_OP_GT;
   g_SSRules[i].condVal[2] = 0; g_SSRules[i].condLogic[2] = 0;
   g_SSRules[i].actionType = act;
   g_SSRules[i].actionVal  = av;
   g_SSRules[i].hits = 0; g_SSRules[i].misses = 0;
   g_SSRules[i].fitness = 0.5;
   g_SSRules[i].generation = g_SSGeneration;
   g_SSRuleCount++;
  }

bool SS_EvalCond(int idx, int op, double val, double &features[],
                 double predNN, double votoEns, double score,
                 double wr, double dd, int cl, int cw)
  {
   double lhs = 0;
   switch(idx)
     {
      case SS_FEAT_NN:    lhs = (predNN - 0.5) * 2.0; break;
      case SS_FEAT_ENS:   lhs = votoEns; break;
      case SS_FEAT_SCORE: lhs = score; break;
      case SS_FEAT_WR:    lhs = wr; break;
      case SS_FEAT_DD:    lhs = dd; break;
      case SS_FEAT_CL:    lhs = (double)cl; break;
      case SS_FEAT_CW:    lhs = (double)cw; break;
      default:
         if(idx >= 0 && idx < NN_INPUTS) lhs = features[idx];
         else return false;
     }
   switch(op)
     {
      case SS_OP_GT: return (lhs >  val);
      case SS_OP_LT: return (lhs <  val);
      case SS_OP_GE: return (lhs >= val);
      case SS_OP_LE: return (lhs <= val);
     }
   return false;
  }

void SS_Evaluate(int symIdx, string sym, double &features[],
                 double predNN, double votoEns, double score,
                 double &outBoost, double &outLotMult, bool &outBlocked,
                 double &outSL, double &outTP, int &fired[], int &nFired)
  {
   outBoost = 0; outLotMult = 1.0; outBlocked = false;
   outSL = 1.0; outTP = 1.0; nFired = 0;

   double dd = (g_peakEquity > 0)
             ? (g_peakEquity - AccountEquity())/g_peakEquity*100.0 : 0;
   double wr = 0.5;
   int cl = 0, cw = 0;
   if(symIdx >= 0 && symIdx < 30)
     {
      if(g_trades[symIdx] > 0) wr = (double)g_wins[symIdx] / g_trades[symIdx];
      cl = g_consecLoss[symIdx];
      cw = g_consecWin[symIdx];
     }

   // Ordenar por prioridad
   int order[SS_MAX_RULES];
   for(int i = 0; i < g_SSRuleCount; i++) order[i] = i;
   for(int i = 0; i < g_SSRuleCount - 1; i++)
      for(int j = i + 1; j < g_SSRuleCount; j++)
         if(g_SSRules[order[j]].priority > g_SSRules[order[i]].priority)
           { int t = order[i]; order[i] = order[j]; order[j] = t; }

   for(int oi = 0; oi < g_SSRuleCount; oi++)
     {
      int i = order[oi];
      if(g_SSRules[i].active == 0) continue;

      bool result = SS_EvalCond(g_SSRules[i].condIdx[0], g_SSRules[i].condOp[0],
                                g_SSRules[i].condVal[0], features, predNN, votoEns,
                                score, wr, dd, cl, cw);
      if(g_SSRules[i].condCount >= 2)
        {
         bool r2 = SS_EvalCond(g_SSRules[i].condIdx[1], g_SSRules[i].condOp[1],
                               g_SSRules[i].condVal[1], features, predNN, votoEns,
                               score, wr, dd, cl, cw);
         if(g_SSRules[i].condLogic[0] == 0) result = result && r2;
         else                                result = result || r2;
        }
      if(g_SSRules[i].condCount >= 3)
        {
         bool r3 = SS_EvalCond(g_SSRules[i].condIdx[2], g_SSRules[i].condOp[2],
                               g_SSRules[i].condVal[2], features, predNN, votoEns,
                               score, wr, dd, cl, cw);
         if(g_SSRules[i].condLogic[1] == 0) result = result && r3;
         else                                result = result || r3;
        }
      if(!result) continue;

      if(nFired < SS_MAX_RULES) { fired[nFired] = i; nFired++; }

      switch(g_SSRules[i].actionType)
        {
         case SS_ACT_BOOST:     outBoost += g_SSRules[i].actionVal; break;
         case SS_ACT_LOT_MULT:  outLotMult *= g_SSRules[i].actionVal; break;
         case SS_ACT_BLOCK:     outBlocked = true; break;
         case SS_ACT_SL_MULT:   outSL *= g_SSRules[i].actionVal; break;
         case SS_ACT_TP_MULT:   outTP *= g_SSRules[i].actionVal; break;
        }
     }

   // Clamps
   if(outBoost >  0.5) outBoost =  0.5;
   if(outBoost < -0.5) outBoost = -0.5;
   if(outLotMult > SAML_LotMultCap) outLotMult = SAML_LotMultCap;
   if(outLotMult < 0.4) outLotMult = 0.4;
   if(outSL > 2.0) outSL = 2.0;
   if(outSL < 0.5) outSL = 0.5;
   if(outTP > 2.5) outTP = 2.5;
   if(outTP < 0.5) outTP = 0.5;
  }

void SS_Evolve()
  {
   if(g_SSRuleCount == 0) return;
   g_SSGeneration++;

   int order[SS_MAX_RULES];
   for(int i = 0; i < g_SSRuleCount; i++) order[i] = i;
   for(int i = 0; i < g_SSRuleCount - 1; i++)
      for(int j = i + 1; j < g_SSRuleCount; j++)
         if(g_SSRules[order[j]].fitness > g_SSRules[order[i]].fitness)
           { int t = order[i]; order[i] = order[j]; order[j] = t; }

   int eliteN = g_SSRuleCount / 4;
   if(eliteN < 2) eliteN = 2;

   // Desactivar malas
   for(int i = 0; i < g_SSRuleCount; i++)
     {
      int tot = g_SSRules[i].hits + g_SSRules[i].misses;
      if(tot >= 10 && g_SSRules[i].fitness < 0.35)
         g_SSRules[i].active = 0;
     }

   // Mutar élite
   MathSrand((int)TimeLocal() + g_SSGeneration * 137 + g_totalTrades);
   for(int i = 0; i < eliteN; i++)
     {
      int src = order[i];
      if((MathRand() % 100) < (int)(SAML_TasaMutacion * 100))
        {
         int c = MathRand() % g_SSRules[src].condCount;
         g_SSRules[src].condVal[c] += (MathRand()/32767.0 - 0.5) * 0.3;
        }
     }

   // Crear nueva (cruce)
   if(g_SSRuleCount < SS_MAX_RULES && eliteN >= 2)
     {
      int p1 = order[MathRand() % eliteN];
      int p2 = order[MathRand() % eliteN];
      int i = g_SSRuleCount;
      g_SSRules[i].id = g_SSNextId++;
      g_SSRules[i].priority = (g_SSRules[p1].priority + g_SSRules[p2].priority) / 2;
      g_SSRules[i].active = 1;
      g_SSRules[i].condCount = MathMin(g_SSRules[p1].condCount, SS_MAX_COND);
      for(int c = 0; c < SS_MAX_COND; c++)
        {
         int par = ((MathRand() % 2) == 0) ? p1 : p2;
         g_SSRules[i].condIdx[c]   = g_SSRules[par].condIdx[c];
         g_SSRules[i].condOp[c]    = g_SSRules[par].condOp[c];
         g_SSRules[i].condVal[c]   = g_SSRules[par].condVal[c] +
                                     (MathRand()/32767.0 - 0.5) * 0.15;
         g_SSRules[i].condLogic[c] = g_SSRules[par].condLogic[c];
        }
      int parA = ((MathRand() % 2) == 0) ? p1 : p2;
      g_SSRules[i].actionType = g_SSRules[parA].actionType;
      g_SSRules[i].actionVal  = g_SSRules[parA].actionVal;
      g_SSRules[i].hits = 0; g_SSRules[i].misses = 0;
      g_SSRules[i].fitness = 0.5;
      g_SSRules[i].generation = g_SSGeneration;
      g_SSRuleCount++;
     }

   if(SAML_AutoGenerar && g_SSRuleCount < SS_MAX_RULES && g_exp_count >= 100)
      SS_GenerateFromPattern();

   SS_Save();
   Print("SAML Gen #", g_SSGeneration, " — reglas=", g_SSRuleCount);
  }

void SS_GenerateFromPattern()
  {
   int fi = MathRand() % NN_INPUTS;
   int signo = (MathRand() % 2) == 0 ? 1 : -1;

   double vals[500];
   int n = MathMin(g_exp_count, 500);
   for(int i = 0; i < n; i++)
     {
      int idx = (g_exp_count < MAX_EXP_HARD) ? i : ((g_exp_pos + i) % MAX_EXP_HARD);
      vals[i] = g_exp_feat[idx][fi];
     }
   for(int i = 0; i < n - 1; i++)
      for(int j = i + 1; j < n; j++)
         if(vals[j] < vals[i]) { double t = vals[i]; vals[i] = vals[j]; vals[j] = t; }

   double umbral = vals[(int)(n * 0.7)];
   double umbralBajo = vals[(int)(n * 0.3)];

   int op; double cv;
   if(signo > 0) { op = SS_OP_GT; cv = umbral; }
   else          { op = SS_OP_LT; cv = umbralBajo; }

   int nPos = 0, nNeg = 0;
   for(int i = 0; i < n; i++)
     {
      int idx = (g_exp_count < MAX_EXP_HARD) ? i : ((g_exp_pos + i) % MAX_EXP_HARD);
      bool cumple = (signo > 0) ? (g_exp_feat[idx][fi] > umbral) : (g_exp_feat[idx][fi] < umbralBajo);
      if(!cumple) continue;
      if(g_exp_rew[idx] > 0) nPos++; else nNeg++;
     }
   if(nPos + nNeg < 10) return;

   double wrPat = (double)nPos / (nPos + nNeg);
   if(wrPat > 0.60)
     {
      SS_AddRuleFull(5, 1, fi, op, cv, 0, 0, 0, 0, 0, SS_ACT_BOOST, 0.10);
      Print("SAML auto: patrón BUENO WR=", DoubleToString(wrPat,2));
     }
   else if(wrPat < 0.35)
     {
      SS_AddRuleFull(12, 1, fi, op, cv, 0, 0, 0, 0, 0, SS_ACT_BLOCK, 1.0);
      Print("SAML auto: patrón MALO WR=", DoubleToString(wrPat,2), " → BLOCK");
     }
  }

void SS_Save()
  {
   // Texto legible
   int h = FileOpen(ARCHIVO_SAML, FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(h != INVALID_HANDLE)
     {
      FileWrite(h, "REM SAMU Auto-Learning Script v9.0");
      FileWrite(h, "REM Gen: " + IntegerToString(g_SSGeneration));
      FileWrite(h, "REM Formato: id|prio|active|hits|miss|fitness|gen|act|av|nc|i1|o1|v1|l1|i2|o2|v2|l2|i3|o3|v3");
      for(int i = 0; i < g_SSRuleCount; i++)
        {
         string ln = IntegerToString(g_SSRules[i].id) + "|" +
                     IntegerToString(g_SSRules[i].priority) + "|" +
                     IntegerToString(g_SSRules[i].active) + "|" +
                     IntegerToString(g_SSRules[i].hits) + "|" +
                     IntegerToString(g_SSRules[i].misses) + "|" +
                     DoubleToString(g_SSRules[i].fitness,4) + "|" +
                     IntegerToString(g_SSRules[i].generation) + "|" +
                     IntegerToString(g_SSRules[i].actionType) + "|" +
                     DoubleToString(g_SSRules[i].actionVal,4) + "|" +
                     IntegerToString(g_SSRules[i].condCount);
         for(int c = 0; c < SS_MAX_COND; c++)
            ln += "|" + IntegerToString(g_SSRules[i].condIdx[c]) +
                  "|" + IntegerToString(g_SSRules[i].condOp[c]) +
                  "|" + DoubleToString(g_SSRules[i].condVal[c],4) +
                  "|" + IntegerToString(g_SSRules[i].condLogic[c]);
         FileWrite(h, ln);
        }
      FileClose(h);
     }

   // Binario
   int hb = FileOpen(ARCHIVO_SAML_BIN, FILE_WRITE | FILE_BIN);
   if(hb == INVALID_HANDLE) return;
   FileWriteInteger(hb, 0x534D4C32);
   FileWriteInteger(hb, g_SSRuleCount);
   FileWriteInteger(hb, g_SSNextId);
   FileWriteInteger(hb, g_SSGeneration);
   for(int i = 0; i < g_SSRuleCount; i++)
     {
      FileWriteInteger(hb, g_SSRules[i].id);
      FileWriteInteger(hb, g_SSRules[i].priority);
      FileWriteInteger(hb, g_SSRules[i].active);
      FileWriteInteger(hb, g_SSRules[i].condCount);
      for(int c = 0; c < SS_MAX_COND; c++)
        {
         FileWriteInteger(hb, g_SSRules[i].condIdx[c]);
         FileWriteInteger(hb, g_SSRules[i].condOp[c]);
         FileWriteDouble (hb, g_SSRules[i].condVal[c]);
         FileWriteInteger(hb, g_SSRules[i].condLogic[c]);
        }
      FileWriteInteger(hb, g_SSRules[i].actionType);
      FileWriteDouble (hb, g_SSRules[i].actionVal);
      FileWriteInteger(hb, g_SSRules[i].hits);
      FileWriteInteger(hb, g_SSRules[i].misses);
      FileWriteDouble (hb, g_SSRules[i].fitness);
      FileWriteInteger(hb, g_SSRules[i].generation);
     }
   FileClose(hb);
  }

bool SS_Load()
  {
   if(!FileIsExist(ARCHIVO_SAML_BIN)) return false;
   int h = FileOpen(ARCHIVO_SAML_BIN, FILE_READ | FILE_BIN);
   if(h == INVALID_HANDLE) return false;
   int firma = FileReadInteger(h);
   if(firma != 0x534D4C32) { FileClose(h); return false; }
   int n = FileReadInteger(h);
   if(n < 0 || n > SS_MAX_RULES) n = 0;
   g_SSNextId = FileReadInteger(h);
   g_SSGeneration = FileReadInteger(h);
   g_SSRuleCount = 0;
   for(int i = 0; i < n; i++)
     {
      g_SSRules[i].id       = FileReadInteger(h);
      g_SSRules[i].priority = FileReadInteger(h);
      g_SSRules[i].active   = FileReadInteger(h);
      g_SSRules[i].condCount= FileReadInteger(h);
      for(int c = 0; c < SS_MAX_COND; c++)
        {
         g_SSRules[i].condIdx[c]   = FileReadInteger(h);
         g_SSRules[i].condOp[c]    = FileReadInteger(h);
         g_SSRules[i].condVal[c]   = FileReadDouble(h);
         g_SSRules[i].condLogic[c] = FileReadInteger(h);
        }
      g_SSRules[i].actionType = FileReadInteger(h);
      g_SSRules[i].actionVal  = FileReadDouble(h);
      g_SSRules[i].hits       = FileReadInteger(h);
      g_SSRules[i].misses     = FileReadInteger(h);
      g_SSRules[i].fitness    = FileReadDouble(h);
      g_SSRules[i].generation = FileReadInteger(h);
      g_SSRuleCount++;
     }
   FileClose(h);
   return (g_SSRuleCount > 0);
  }

//====================================================================
//=================== PERSISTENCIA ===================================
//====================================================================
void GuardarCerebro()
  {
   int h = FileOpen(ARCHIVO_CEREBRO, FILE_WRITE | FILE_BIN);
   if(h == INVALID_HANDLE) return;
   FileWriteInteger(h, 0x53414D55);
   FileWriteInteger(h, 900);
   FileWriteArray(h, g_W1, 0, NN_W1_SIZE);
   FileWriteArray(h, g_B1, 0, NN_B1_SIZE);
   FileWriteArray(h, g_W2, 0, NN_W2_SIZE);
   FileWriteArray(h, g_B2, 0, NN_B2_SIZE);
   for(int s = 0; s < TamanoPoolEstrategias; s++)
      for(int k = 0; k < STRAT_FEATURES; k++)
         FileWriteDouble(h, g_Pool[s][k]);
   FileWriteDouble(h, g_pesoNN);
   FileWriteDouble(h, g_pesoEns);
   FileWriteInteger(h, g_Generacion);
   FileWriteInteger(h, g_totalTrades);
   FileWriteInteger(h, g_totalWins);
   FileWriteInteger(h, g_totalLosses);
   FileWriteDouble(h, g_totalPnL);
   FileWriteDouble(h, g_maxDDHist);
   FileClose(h);
  }

bool CargarCerebro()
  {
   if(!FileIsExist(ARCHIVO_CEREBRO)) return false;
   int h = FileOpen(ARCHIVO_CEREBRO, FILE_READ | FILE_BIN);
   if(h == INVALID_HANDLE) return false;
   int firma = FileReadInteger(h);
   if(firma != 0x53414D55) { FileClose(h); return false; }
   int ver = FileReadInteger(h);
   if(ver != 900) { FileClose(h); return false; }
   FileReadArray(h, g_W1, 0, NN_W1_SIZE);
   FileReadArray(h, g_B1, 0, NN_B1_SIZE);
   FileReadArray(h, g_W2, 0, NN_W2_SIZE);
   FileReadArray(h, g_B2, 0, NN_B2_SIZE);
   for(int s = 0; s < TamanoPoolEstrategias; s++)
      for(int k = 0; k < STRAT_FEATURES; k++)
         g_Pool[s][k] = FileReadDouble(h);
   g_pesoNN      = FileReadDouble(h);
   g_pesoEns     = FileReadDouble(h);
   g_Generacion  = FileReadInteger(h);
   g_totalTrades = FileReadInteger(h);
   g_totalWins   = FileReadInteger(h);
   g_totalLosses = FileReadInteger(h);
   g_totalPnL    = FileReadDouble(h);
   g_maxDDHist   = FileReadDouble(h);
   FileClose(h);
   Print("Cerebro cargado — ", g_totalTrades, " trades, Gen ", g_Generacion);
   return true;
  }

void GuardarExperiencia()
  {
   int h = FileOpen(ARCHIVO_EXPERIENCIA, FILE_WRITE | FILE_BIN);
   if(h == INVALID_HANDLE) return;
   FileWriteInteger(h, g_exp_count);
   FileWriteInteger(h, g_exp_pos);
   int cap = MathMin(MaxExperiencia, MAX_EXP_HARD);
   int inicio = (g_exp_count < cap) ? 0 : g_exp_pos;
   for(int k = 0; k < g_exp_count; k++)
     {
      int idx = (inicio + k) % cap;
      for(int i = 0; i < NN_INPUTS; i++) FileWriteDouble(h, g_exp_feat[idx][i]);
      FileWriteDouble(h, g_exp_acc[idx]);
      FileWriteDouble(h, g_exp_rew[idx]);
      FileWriteInteger(h, (int)g_exp_tim[idx]);
     }
   FileClose(h);
  }

void CargarExperiencia()
  {
   if(!FileIsExist(ARCHIVO_EXPERIENCIA)) return;
   int h = FileOpen(ARCHIVO_EXPERIENCIA, FILE_READ | FILE_BIN);
   if(h == INVALID_HANDLE) return;
   int cap = MathMin(MaxExperiencia, MAX_EXP_HARD);
   int count = FileReadInteger(h);
   int pos   = FileReadInteger(h);
   if(count > cap) count = cap;
   for(int k = 0; k < count; k++)
     {
      int idx = k % cap;
      for(int i = 0; i < NN_INPUTS; i++) g_exp_feat[idx][i] = FileReadDouble(h);
      g_exp_acc[idx] = FileReadDouble(h);
      g_exp_rew[idx] = FileReadDouble(h);
      g_exp_tim[idx] = (datetime)FileReadInteger(h);
     }
   g_exp_count = count;
   g_exp_pos   = pos;
   FileClose(h);
   Print("Experiencia cargada: ", g_exp_count, " muestras");
  }

//====================================================================
//=================== JOURNAL / STATS ================================
//====================================================================
void InicializarJournal()
  {
   if(FileIsExist(ARCHIVO_JOURNAL)) return;
   int h = FileOpen(ARCHIVO_JOURNAL, FILE_WRITE | FILE_CSV, ';');
   if(h == INVALID_HANDLE) return;
   FileWrite(h,"Fecha","Ticket","Simbolo","PnL","RewardR","Modo","Gen");
   FileClose(h);
  }

void EscribirJournal(int tk, string sym, double pnl, double rew)
  {
   int h = FileOpen(ARCHIVO_JOURNAL, FILE_READ|FILE_WRITE|FILE_CSV, ';');
   if(h == INVALID_HANDLE) return;
   FileSeek(h, 0, SEEK_END);
   FileWrite(h, TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS),
      IntegerToString(tk), sym, DoubleToString(pnl,2),
      DoubleToString(rew,3), NombreModo(), IntegerToString(g_Generacion));
   FileClose(h);
  }

void GuardarStatsCSV()
  {
   int h = FileOpen(ARCHIVO_STATS, FILE_WRITE | FILE_CSV, ';');
   if(h == INVALID_HANDLE) return;
   FileWrite(h,"Simbolo","Trades","Wins","Losses","WinRate","PnL");
   for(int i = 0; i < NumSimbolos; i++)
     {
      double wr = (g_trades[i] > 0) ? (double)g_wins[i]/g_trades[i]*100 : 0;
      FileWrite(h, ListaSimbolos[i], IntegerToString(g_trades[i]),
                   IntegerToString(g_wins[i]), IntegerToString(g_losses[i]),
                   DoubleToString(wr,1), DoubleToString(g_pnl[i],2));
     }
   FileWrite(h, "");
   FileWrite(h, "GLOBAL");
   FileWrite(h, "TotalTrades", IntegerToString(g_totalTrades));
   FileWrite(h, "TotalWins",   IntegerToString(g_totalWins));
   FileWrite(h, "TotalLosses", IntegerToString(g_totalLosses));
   FileWrite(h, "TotalPnL",    DoubleToString(g_totalPnL,2));
   FileWrite(h, "MaxDD",       DoubleToString(g_maxDDHist,2));
   FileWrite(h, "PoolGen",     IntegerToString(g_Generacion));
   FileWrite(h, "SAML_Gen",    IntegerToString(g_SSGeneration));
   FileWrite(h, "SAML_Rules",  IntegerToString(g_SSRuleCount));
   FileClose(h);
  }

void ExportarParaIAExterna()
  {
   int h = FileOpen(ARCHIVO_EXPORT, FILE_WRITE | FILE_CSV, ',');
   if(h == INVALID_HANDLE) return;
   FileWrite(h, "# SAMU AI v9.0 Export");
   FileWrite(h, "# Timestamp,", TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS));
   FileWrite(h, "NN_INPUTS,", IntegerToString(NN_INPUTS));
   FileWrite(h, "NN_HIDDEN,", IntegerToString(NN_HIDDEN));
   FileWrite(h, "GENERACION,", IntegerToString(g_Generacion));
   FileWrite(h, "SAML_RULES,", IntegerToString(g_SSRuleCount));
   FileWrite(h, "SAML_GEN,", IntegerToString(g_SSGeneration));
   FileWrite(h, "TOTAL_TRADES,", IntegerToString(g_totalTrades));
   FileWrite(h, "TOTAL_PNL,", DoubleToString(g_totalPnL,2));
   FileWrite(h, "MAX_DD,", DoubleToString(g_maxDDHist,2));
   FileWrite(h, "");
   FileWrite(h, "# W1");
   for(int i = 0; i < NN_INPUTS; i++)
     {
      string ln = "";
      for(int hh = 0; hh < NN_HIDDEN; hh++)
        { if(hh > 0) ln += ","; ln += DoubleToString(g_W1[i*NN_HIDDEN+hh],6); }
      FileWrite(h, ln);
     }
   FileClose(h);
  }

//====================================================================
//=================== UTILS ==========================================
//====================================================================
int BuscarIdxSimbolo(string sym)
  {
   for(int i = 0; i < NumSimbolos; i++)
      if(ListaSimbolos[i] == sym) return i;
   return -1;
  }

string NombreModo()
  {
   if(g_modoActual == MODE_RECOVERY) return "RECOVERY/" + NombreTactica(g_tacticaActual);
   if(g_modoActual == MODE_PROTECT)  return "PROTECT";
   return "NORMAL";
  }

//====================================================================
//=================== VISUAL =========================================
//====================================================================
void InicializarVisuales()
  {
   if(PintarVelas)
     {
      ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, clrLime);
      ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, clrRed);
      ChartSetInteger(0, CHART_COLOR_CHART_UP,   clrLime);
      ChartSetInteger(0, CHART_COLOR_CHART_DOWN, clrRed);
      ChartSetInteger(0, CHART_COLOR_CHART_LINE, clrWhite);
      ChartSetInteger(0, CHART_COLOR_GRID,       C'60,60,60');
     }
   ChartRedraw();
  }

void ActualizarNiveles()
  {
   if(Time[0] == g_UltimaBarraNiv) return;
   g_UltimaBarraNiv = Time[0];
   if(Bars < 150) return;

   for(int i = ObjectsTotal() - 1; i >= 0; i--)
     {
      string nm = ObjectName(i);
      if(StringFind(nm, "SR_") == 0) ObjectDelete(nm);
     }
   int iHi = iHighest(Symbol(), PERIOD_CURRENT, MODE_HIGH, 100, 1);
   int iLo = iLowest (Symbol(), PERIOD_CURRENT, MODE_LOW,  100, 1);
   if(iHi < 0 || iLo < 0) return;
   double t = iHigh(Symbol(), PERIOD_CURRENT, iHi);
   double p = iLow (Symbol(), PERIOD_CURRENT, iLo);
   datetime t1 = Time[100];
   datetime t2 = Time[0] + PeriodSeconds() * 20;
   ObjectCreate("SR_Techo", OBJ_TREND, 0, t1, t, t2, t);
   ObjectSet("SR_Techo", OBJPROP_COLOR, clrTomato);
   ObjectSet("SR_Techo", OBJPROP_STYLE, STYLE_DASH);
   ObjectSet("SR_Techo", OBJPROP_RAY_RIGHT, true);
   ObjectCreate("SR_Piso", OBJ_TREND, 0, t1, p, t2, p);
   ObjectSet("SR_Piso", OBJPROP_COLOR, clrLime);
   ObjectSet("SR_Piso", OBJPROP_STYLE, STYLE_DASH);
   ObjectSet("SR_Piso", OBJPROP_RAY_RIGHT, true);
  }

void Etiqueta(string nm, int x, int y, string txt, int tam, color clr)
  {
   if(ObjectFind(nm) < 0) ObjectCreate(nm, OBJ_LABEL, 0, 0, 0);
   ObjectSet(nm, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSet(nm, OBJPROP_XDISTANCE, x);
   ObjectSet(nm, OBJPROP_YDISTANCE, y);
   ObjectSet(nm, OBJPROP_BACK, false);
   ObjectSet(nm, OBJPROP_SELECTABLE, false);
   ObjectSet(nm, OBJPROP_ZORDER, 100);
   ObjectSetText(nm, txt, tam, "Consolas", clr);
  }

void Rectangulo(string nm, int x, int y, int w, int h, color cf, color cb)
  {
   if(ObjectFind(nm) < 0) ObjectCreate(nm, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSet(nm, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSet(nm, OBJPROP_XDISTANCE, x);
   ObjectSet(nm, OBJPROP_YDISTANCE, y);
   ObjectSet(nm, OBJPROP_XSIZE, w);
   ObjectSet(nm, OBJPROP_YSIZE, h);
   ObjectSet(nm, OBJPROP_BGCOLOR, cf);
   ObjectSet(nm, OBJPROP_COLOR, cb);
   ObjectSet(nm, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSet(nm, OBJPROP_BACK, false);
   ObjectSet(nm, OBJPROP_ZORDER, 1);
  }

void ActualizarPanel()
  {
   color FP=C'15,22,36', FC=C'0,90,150', FS=C'35,52,78';
   color FF1=C'24,35,52', FF2=C'19,28,42', BRD=C'90,120,160';
   color TBL=clrWhite, TGR=C'200,210,225', TAZ=C'130,200,255';
   color TVE=C'120,230,140', TRO=C'255,130,130', TAM=C'255,210,90';

   int x=10, y=20, W=520;
   int dy=20, ds=24, pX=12, pY=4;
   int cL=12, cV=210;

   bool balBajo = (AccountBalance() < BALANCE_MINIMO);
   color cBal = balBajo ? TRO : TVE;
   double dd = (g_peakEquity > 0)
             ? (g_peakEquity - AccountEquity())/g_peakEquity*100.0 : 0;
   color cDD = (g_NivelDD==0) ? TVE : (g_NivelDD==1 ? TAM : TRO);

   int yc=y;
   Rectangulo("P_F", x, y, W, 580, FP, BRD);
   Rectangulo("P_C", x, yc, W, 26, FC, BRD);
   Etiqueta("P_T", x+pX, yc+7, "SAMU AI v9.0 — " + NombreModo(), 11, TBL);
   yc += 26;

   Etiqueta("P_D", x+pX, yc+pY, TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS), 9, TGR);
   yc += dy;

   Etiqueta("P_1", x+cL, yc+pY, "Balance", 9, TGR);
   Etiqueta("P_V1", x+cV, yc+pY, "$ "+DoubleToString(AccountBalance(),2), 9, cBal);
   yc += dy;
   Etiqueta("P_2", x+cL, yc+pY, "Equity", 9, TGR);
   Etiqueta("P_V2", x+cV, yc+pY, "$ "+DoubleToString(AccountEquity(),2), 9, TAZ);
   yc += dy;
   Etiqueta("P_3", x+cL, yc+pY, "DD / Nivel CB", 9, TGR);
   Etiqueta("P_V3", x+cV, yc+pY,
            DoubleToString(dd,2)+"% / N"+IntegerToString(g_NivelDD), 9, cDD);
   yc += dy;
   Etiqueta("P_4", x+cL, yc+pY, "Flotante / Pico", 9, TGR);
   Etiqueta("P_V4", x+cV, yc+pY,
            "$ "+DoubleToString(g_floatingNow,2)+" / $ "+DoubleToString(g_floatingPeak,2),
            9, (g_floatingNow >= 0 ? TVE : TRO));
   yc += dy;

   Etiqueta("P_5", x+cL, yc+pY, "Modo", 9, TGR);
   color cm = (g_modoActual == MODE_NORMAL) ? TVE
            : (g_modoActual == MODE_RECOVERY ? TAM : TRO);
   Etiqueta("P_V5", x+cV, yc+pY, NombreModo(), 9, cm);
   yc += dy;
   Etiqueta("P_6", x+cL, yc+pY, "Intentos recovery", 9, TGR);
   Etiqueta("P_V6", x+cV, yc+pY,
            IntegerToString(g_intentosRecovery)+" / "+IntegerToString(Recov_MaxIntentos),
            9, TBL);
   yc += dy;

   Etiqueta("P_7", x+cL, yc+pY, "Pred NN / Ens / Score", 9, TGR);
   Etiqueta("P_V7", x+cV, yc+pY,
            DoubleToString(UlimoPredNN,3)+" / "+DoubleToString(UltimoVotoEns,3)+
            " / "+DoubleToString(UltimoScore,3), 9, TBL);
   yc += dy;
   Etiqueta("P_8", x+cL, yc+pY, "Boost SAML / LotMult", 9, TGR);
   Etiqueta("P_V8", x+cV, yc+pY,
            DoubleToString(g_SSUltBoost,3)+" / "+DoubleToString(g_SSUltLotMult,2)+
            (g_SSUltBlocked?" [BLOCKED]":""), 9, TAM);
   yc += dy;

   Etiqueta("P_9", x+cL, yc+pY, "Pool Gen / Replays", 9, TGR);
   Etiqueta("P_V9", x+cV, yc+pY,
            IntegerToString(g_Generacion)+" / "+IntegerToString(g_exp_entrenamientos),
            9, TBL);
   yc += dy;
   Etiqueta("P_10", x+cL, yc+pY, "SAML reglas / Gen", 9, TGR);
   Etiqueta("P_V10", x+cV, yc+pY,
            IntegerToString(g_SSRuleCount)+" / "+IntegerToString(g_SSGeneration), 9, TBL);
   yc += dy;
   Etiqueta("P_11", x+cL, yc+pY, "Buffer experiencia", 9, TGR);
   Etiqueta("P_V11", x+cV, yc+pY,
            IntegerToString(g_exp_count)+" / "+IntegerToString(MaxExperiencia), 9, TBL);
   yc += dy;

   Etiqueta("P_12", x+cL, yc+pY, "Trades W/L", 9, TGR);
   Etiqueta("P_V12", x+cV, yc+pY,
            IntegerToString(g_totalTrades)+" ("+IntegerToString(g_totalWins)+
            "/"+IntegerToString(g_totalLosses)+")", 9, TBL);
   yc += dy;
   Etiqueta("P_13", x+cL, yc+pY, "PnL / MaxDD", 9, TGR);
   Etiqueta("P_V13", x+cV, yc+pY,
            "$ "+DoubleToString(g_totalPnL,2)+" / "+DoubleToString(g_maxDDHist,2)+"%",
            9, (g_totalPnL >= 0 ? TVE : TRO));
   yc += dy;

   ChartRedraw();
  }
//+------------------------------------------------------------------+

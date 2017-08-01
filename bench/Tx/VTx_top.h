// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Primary design header
//
// This header should be included by all source files instantiating the design.
// The class here is then constructed to instantiate the design.
// See the Verilator manual for examples.

#ifndef _VTx_top_H_
#define _VTx_top_H_

#include "verilated.h"
class VTx_top__Syms;
class VerilatedVcd;

//----------

VL_MODULE(VTx_top) {
  public:
    // CELLS
    // Public to allow access to /*verilator_public*/ items;
    // otherwise the application code can consider these internals.
    
    // PORTS
    // The application code writes and reads these signals to
    // propagate new values into/out from the Verilated model.
    VL_IN8(clk,0,0);
    VL_IN8(start,0,0);
    VL_IN8(i_data,7,0);
    VL_OUT8(serial_out,0,0);
    VL_OUT8(o_busy,0,0);
    //char	__VpadToAlign5[3];
    
    // LOCAL SIGNALS
    // Internals; generally not touched by application code
    VL_SIG8(Tx_top__DOT__bg__DOT__ck_stb,0,0);
    VL_SIG8(Tx_top__DOT__start_tx,0,0);
    VL_SIG8(Tx_top__DOT__tx__DOT__state,3,0);
    //char	__VpadToAlign15[1];
    VL_SIG16(Tx_top__DOT__PISO__DOT__data_shift_reg,8,0);
    //char	__VpadToAlign18[2];
    VL_SIG(Tx_top__DOT__bg__DOT__counter,31,0);
    
    // LOCAL VARIABLES
    // Internals; generally not touched by application code
    static VL_ST_SIG8(__Vtable1_Tx_top__DOT__tx__DOT__state[64],3,0);
    VL_SIG8(__Vdly__Tx_top__DOT__tx__DOT__state,3,0);
    VL_SIG8(__VinpClk__TOP__Tx_top__DOT__bg__DOT__ck_stb,0,0);
    VL_SIG8(__Vclklast__TOP__clk,0,0);
    VL_SIG8(__Vclklast__TOP____VinpClk__TOP__Tx_top__DOT__bg__DOT__ck_stb,0,0);
    VL_SIG8(__Vchglast__TOP__Tx_top__DOT__bg__DOT__ck_stb,0,0);
    //char	__VpadToAlign33[3];
    VL_SIG(__Vm_traceActivity,31,0);
    VL_SIG8(__Vtablechg1[64],0,0);
    
    // INTERNAL VARIABLES
    // Internals; generally not touched by application code
    //char	__VpadToAlign108[4];
    VTx_top__Syms*	__VlSymsp;		// Symbol table
    
    // PARAMETERS
    // Parameters marked /*verilator public*/ for use by application code
    
    // CONSTRUCTORS
  private:
    VTx_top& operator= (const VTx_top&);	///< Copying not allowed
    VTx_top(const VTx_top&);	///< Copying not allowed
  public:
    /// Construct the model; called by application code
    /// The special name  may be used to make a wrapper with a
    /// single model invisible WRT DPI scope names.
    VTx_top(const char* name="TOP");
    /// Destroy the model; called (often implicitly) by application code
    ~VTx_top();
    /// Trace signals in the model; called by application code
    void trace (VerilatedVcdC* tfp, int levels, int options=0);
    
    // USER METHODS
    
    // API METHODS
    /// Evaluate the model.  Application must call when inputs change.
    void eval();
    /// Simulation complete, run final blocks.  Application must call on completion.
    void final();
    
    // INTERNAL METHODS
  private:
    static void _eval_initial_loop(VTx_top__Syms* __restrict vlSymsp);
  public:
    void __Vconfigure(VTx_top__Syms* symsp, bool first);
  private:
    static QData	_change_request(VTx_top__Syms* __restrict vlSymsp);
    void	_configure_coverage(VTx_top__Syms* __restrict vlSymsp, bool first);
    void	_ctor_var_reset();
  public:
    static void	_eval(VTx_top__Syms* __restrict vlSymsp);
    static void	_eval_initial(VTx_top__Syms* __restrict vlSymsp);
    static void	_eval_settle(VTx_top__Syms* __restrict vlSymsp);
    static void	_initial__TOP__1(VTx_top__Syms* __restrict vlSymsp);
    static void	_initial__TOP__3(VTx_top__Syms* __restrict vlSymsp);
    static void	_initial__TOP__5(VTx_top__Syms* __restrict vlSymsp);
    static void	_sequent__TOP__2(VTx_top__Syms* __restrict vlSymsp);
    static void	_sequent__TOP__4(VTx_top__Syms* __restrict vlSymsp);
    static void	_sequent__TOP__6(VTx_top__Syms* __restrict vlSymsp);
    static void	_settle__TOP__7(VTx_top__Syms* __restrict vlSymsp);
    static void	traceChgThis(VTx_top__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code);
    static void	traceChgThis__2(VTx_top__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code);
    static void	traceChgThis__3(VTx_top__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code);
    static void	traceChgThis__4(VTx_top__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code);
    static void	traceChgThis__5(VTx_top__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code);
    static void	traceChgThis__6(VTx_top__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code);
    static void	traceChgThis__7(VTx_top__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code);
    static void	traceFullThis(VTx_top__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code);
    static void	traceFullThis__1(VTx_top__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code);
    static void	traceInitThis(VTx_top__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code);
    static void	traceInitThis__1(VTx_top__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code);
    static void traceInit (VerilatedVcd* vcdp, void* userthis, uint32_t code);
    static void traceFull (VerilatedVcd* vcdp, void* userthis, uint32_t code);
    static void traceChg  (VerilatedVcd* vcdp, void* userthis, uint32_t code);
} VL_ATTR_ALIGNED(128);

#endif  /*guard*/

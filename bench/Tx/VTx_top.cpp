// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See VTx_top.h for the primary calling header

#include "VTx_top.h"           // For This
#include "VTx_top__Syms.h"

//--------------------
// STATIC VARIABLES

VL_ST_SIG8(VTx_top::__Vtable1_Tx_top__DOT__tx__DOT__state[64],3,0);

//--------------------

VL_CTOR_IMP(VTx_top) {
    VTx_top__Syms* __restrict vlSymsp = __VlSymsp = new VTx_top__Syms(this, name());
    VTx_top* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Reset internal values
    
    // Reset structure values
    _ctor_var_reset();
}

void VTx_top::__Vconfigure(VTx_top__Syms* vlSymsp, bool first) {
    if (0 && first) {}  // Prevent unused
    this->__VlSymsp = vlSymsp;
}

VTx_top::~VTx_top() {
    delete __VlSymsp; __VlSymsp=NULL;
}

//--------------------


void VTx_top::eval() {
    VTx_top__Syms* __restrict vlSymsp = this->__VlSymsp; // Setup global symbol table
    VTx_top* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Initialize
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) _eval_initial_loop(vlSymsp);
    // Evaluate till stable
    VL_DEBUG_IF(VL_PRINTF("\n----TOP Evaluate VTx_top::eval\n"); );
    int __VclockLoop = 0;
    QData __Vchange=1;
    while (VL_LIKELY(__Vchange)) {
	VL_DEBUG_IF(VL_PRINTF(" Clock loop\n"););
	vlSymsp->__Vm_activity = true;
	_eval(vlSymsp);
	__Vchange = _change_request(vlSymsp);
	if (++__VclockLoop > 100) vl_fatal(__FILE__,__LINE__,__FILE__,"Verilated model didn't converge");
    }
}

void VTx_top::_eval_initial_loop(VTx_top__Syms* __restrict vlSymsp) {
    vlSymsp->__Vm_didInit = true;
    _eval_initial(vlSymsp);
    vlSymsp->__Vm_activity = true;
    int __VclockLoop = 0;
    QData __Vchange=1;
    while (VL_LIKELY(__Vchange)) {
	_eval_settle(vlSymsp);
	_eval(vlSymsp);
	__Vchange = _change_request(vlSymsp);
	if (++__VclockLoop > 100) vl_fatal(__FILE__,__LINE__,__FILE__,"Verilated model didn't DC converge");
    }
}

//--------------------
// Internal Methods

void VTx_top::_initial__TOP__1(VTx_top__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_PRINTF("    VTx_top::_initial__TOP__1\n"); );
    VTx_top* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    // INITIAL at ../rtl//shift_register.v:8
    vlTOPp->serial_out = 1U;
}

VL_INLINE_OPT void VTx_top::_sequent__TOP__2(VTx_top__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_PRINTF("    VTx_top::_sequent__TOP__2\n"); );
    VTx_top* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Variables
    VL_SIG8(__Vtableidx1,5,0);
    //char	__VpadToAlign25[3];
    VL_SIG(__Vdly__Tx_top__DOT__bg__DOT__counter,31,0);
    // Body
    __Vdly__Tx_top__DOT__bg__DOT__counter = vlTOPp->Tx_top__DOT__bg__DOT__counter;
    vlTOPp->__Vdly__Tx_top__DOT__tx__DOT__state = vlTOPp->Tx_top__DOT__tx__DOT__state;
    // ALWAYS at ../rtl//TxUART.v:32
    __Vtableidx1 = (((IData)(vlTOPp->Tx_top__DOT__start_tx) 
		     << 5U) | (((IData)(vlTOPp->Tx_top__DOT__tx__DOT__state) 
				<< 1U) | (IData)(vlTOPp->Tx_top__DOT__bg__DOT__ck_stb)));
    if (vlTOPp->__Vtablechg1[__Vtableidx1]) {
	vlTOPp->__Vdly__Tx_top__DOT__tx__DOT__state 
	    = vlTOPp->__Vtable1_Tx_top__DOT__tx__DOT__state
	    [__Vtableidx1];
    }
    // ALWAYS at ../rtl//baud_generator.v:11
    vlTOPp->Tx_top__DOT__bg__DOT__ck_stb = (1U & (IData)(
							 (VL_ULL(1) 
							  & ((VL_ULL(0xd1b71) 
							      + (QData)((IData)(vlTOPp->Tx_top__DOT__bg__DOT__counter))) 
							     >> 0x20U))));
    __Vdly__Tx_top__DOT__bg__DOT__counter = ((IData)(0xd1b71U) 
					     + vlTOPp->Tx_top__DOT__bg__DOT__counter);
    vlTOPp->Tx_top__DOT__bg__DOT__counter = __Vdly__Tx_top__DOT__bg__DOT__counter;
}

void VTx_top::_initial__TOP__3(VTx_top__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_PRINTF("    VTx_top::_initial__TOP__3\n"); );
    VTx_top* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    // INITIAL at ../rtl//baud_generator.v:9
    vlTOPp->Tx_top__DOT__bg__DOT__counter = 0U;
}

VL_INLINE_OPT void VTx_top::_sequent__TOP__4(VTx_top__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_PRINTF("    VTx_top::_sequent__TOP__4\n"); );
    VTx_top* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Variables
    VL_SIG16(__Vdly__Tx_top__DOT__PISO__DOT__data_shift_reg,8,0);
    //char	__VpadToAlign74[2];
    // Body
    __Vdly__Tx_top__DOT__PISO__DOT__data_shift_reg 
	= vlTOPp->Tx_top__DOT__PISO__DOT__data_shift_reg;
    // ALWAYS at ../rtl//shift_register.v:10
    __Vdly__Tx_top__DOT__PISO__DOT__data_shift_reg 
	= ((IData)(vlTOPp->Tx_top__DOT__start_tx) ? 
	   ((0x100U & (VL_REDXOR_32((IData)(vlTOPp->i_data)) 
		       << 8U)) | (IData)(vlTOPp->i_data))
	    : (0x100U | (0xffU & ((IData)(vlTOPp->Tx_top__DOT__PISO__DOT__data_shift_reg) 
				  >> 1U))));
    // ALWAYS at ../rtl//shift_register.v:18
    vlTOPp->serial_out = (1U & ((~ (IData)(vlTOPp->Tx_top__DOT__start_tx)) 
				& (IData)(vlTOPp->Tx_top__DOT__PISO__DOT__data_shift_reg)));
    vlTOPp->Tx_top__DOT__PISO__DOT__data_shift_reg 
	= __Vdly__Tx_top__DOT__PISO__DOT__data_shift_reg;
}

void VTx_top::_initial__TOP__5(VTx_top__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_PRINTF("    VTx_top::_initial__TOP__5\n"); );
    VTx_top* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    // INITIAL at ../rtl//TxUART.v:22
    vlTOPp->Tx_top__DOT__start_tx = 0U;
}

VL_INLINE_OPT void VTx_top::_sequent__TOP__6(VTx_top__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_PRINTF("    VTx_top::_sequent__TOP__6\n"); );
    VTx_top* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    // ALWAYS at ../rtl//TxUART.v:24
    if (vlTOPp->start) {
	vlTOPp->Tx_top__DOT__start_tx = 1U;
    } else {
	if ((1U == (IData)(vlTOPp->Tx_top__DOT__tx__DOT__state))) {
	    vlTOPp->Tx_top__DOT__start_tx = 0U;
	}
    }
    vlTOPp->Tx_top__DOT__tx__DOT__state = vlTOPp->__Vdly__Tx_top__DOT__tx__DOT__state;
    vlTOPp->o_busy = ((0U != (IData)(vlTOPp->Tx_top__DOT__tx__DOT__state)) 
		      | (IData)(vlTOPp->Tx_top__DOT__start_tx));
}

void VTx_top::_settle__TOP__7(VTx_top__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_PRINTF("    VTx_top::_settle__TOP__7\n"); );
    VTx_top* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->o_busy = ((0U != (IData)(vlTOPp->Tx_top__DOT__tx__DOT__state)) 
		      | (IData)(vlTOPp->Tx_top__DOT__start_tx));
}

void VTx_top::_eval(VTx_top__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_PRINTF("    VTx_top::_eval\n"); );
    VTx_top* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    if (((IData)(vlTOPp->clk) & (~ (IData)(vlTOPp->__Vclklast__TOP__clk)))) {
	vlTOPp->_sequent__TOP__2(vlSymsp);
	vlTOPp->__Vm_traceActivity = (2U | vlTOPp->__Vm_traceActivity);
    }
    if (((IData)(vlTOPp->__VinpClk__TOP__Tx_top__DOT__bg__DOT__ck_stb) 
	 & (~ (IData)(vlTOPp->__Vclklast__TOP____VinpClk__TOP__Tx_top__DOT__bg__DOT__ck_stb)))) {
	vlTOPp->_sequent__TOP__4(vlSymsp);
	vlTOPp->__Vm_traceActivity = (4U | vlTOPp->__Vm_traceActivity);
    }
    if (((IData)(vlTOPp->clk) & (~ (IData)(vlTOPp->__Vclklast__TOP__clk)))) {
	vlTOPp->_sequent__TOP__6(vlSymsp);
	vlTOPp->__Vm_traceActivity = (8U | vlTOPp->__Vm_traceActivity);
    }
    // Final
    vlTOPp->__Vclklast__TOP__clk = vlTOPp->clk;
    vlTOPp->__Vclklast__TOP____VinpClk__TOP__Tx_top__DOT__bg__DOT__ck_stb 
	= vlTOPp->__VinpClk__TOP__Tx_top__DOT__bg__DOT__ck_stb;
    vlTOPp->__VinpClk__TOP__Tx_top__DOT__bg__DOT__ck_stb 
	= vlTOPp->Tx_top__DOT__bg__DOT__ck_stb;
}

void VTx_top::_eval_initial(VTx_top__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_PRINTF("    VTx_top::_eval_initial\n"); );
    VTx_top* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->_initial__TOP__1(vlSymsp);
    vlTOPp->__Vm_traceActivity = (1U | vlTOPp->__Vm_traceActivity);
    vlTOPp->_initial__TOP__3(vlSymsp);
    vlTOPp->_initial__TOP__5(vlSymsp);
}

void VTx_top::final() {
    VL_DEBUG_IF(VL_PRINTF("    VTx_top::final\n"); );
    // Variables
    VTx_top__Syms* __restrict vlSymsp = this->__VlSymsp;
    VTx_top* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
}

void VTx_top::_eval_settle(VTx_top__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_PRINTF("    VTx_top::_eval_settle\n"); );
    VTx_top* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->_settle__TOP__7(vlSymsp);
}

VL_INLINE_OPT QData VTx_top::_change_request(VTx_top__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_PRINTF("    VTx_top::_change_request\n"); );
    VTx_top* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    // Change detection
    QData __req = false;  // Logically a bool
    __req |= ((vlTOPp->Tx_top__DOT__bg__DOT__ck_stb ^ vlTOPp->__Vchglast__TOP__Tx_top__DOT__bg__DOT__ck_stb));
    VL_DEBUG_IF( if(__req && ((vlTOPp->Tx_top__DOT__bg__DOT__ck_stb ^ vlTOPp->__Vchglast__TOP__Tx_top__DOT__bg__DOT__ck_stb))) VL_PRINTF("	CHANGE: ../rtl//baud_generator.v:8: Tx_top.bg.ck_stb\n"); );
    // Final
    vlTOPp->__Vchglast__TOP__Tx_top__DOT__bg__DOT__ck_stb 
	= vlTOPp->Tx_top__DOT__bg__DOT__ck_stb;
    return __req;
}

void VTx_top::_ctor_var_reset() {
    VL_DEBUG_IF(VL_PRINTF("    VTx_top::_ctor_var_reset\n"); );
    // Body
    clk = VL_RAND_RESET_I(1);
    start = VL_RAND_RESET_I(1);
    i_data = VL_RAND_RESET_I(8);
    serial_out = VL_RAND_RESET_I(1);
    o_busy = VL_RAND_RESET_I(1);
    Tx_top__DOT__start_tx = VL_RAND_RESET_I(1);
    Tx_top__DOT__tx__DOT__state = VL_RAND_RESET_I(4);
    Tx_top__DOT__bg__DOT__ck_stb = VL_RAND_RESET_I(1);
    Tx_top__DOT__bg__DOT__counter = VL_RAND_RESET_I(32);
    Tx_top__DOT__PISO__DOT__data_shift_reg = VL_RAND_RESET_I(9);
    __Vtablechg1[0] = 0U;
    __Vtablechg1[1] = 1U;
    __Vtablechg1[2] = 0U;
    __Vtablechg1[3] = 1U;
    __Vtablechg1[4] = 0U;
    __Vtablechg1[5] = 1U;
    __Vtablechg1[6] = 0U;
    __Vtablechg1[7] = 1U;
    __Vtablechg1[8] = 0U;
    __Vtablechg1[9] = 1U;
    __Vtablechg1[10] = 0U;
    __Vtablechg1[11] = 1U;
    __Vtablechg1[12] = 0U;
    __Vtablechg1[13] = 1U;
    __Vtablechg1[14] = 0U;
    __Vtablechg1[15] = 1U;
    __Vtablechg1[16] = 0U;
    __Vtablechg1[17] = 1U;
    __Vtablechg1[18] = 0U;
    __Vtablechg1[19] = 1U;
    __Vtablechg1[20] = 0U;
    __Vtablechg1[21] = 1U;
    __Vtablechg1[22] = 0U;
    __Vtablechg1[23] = 1U;
    __Vtablechg1[24] = 0U;
    __Vtablechg1[25] = 1U;
    __Vtablechg1[26] = 0U;
    __Vtablechg1[27] = 1U;
    __Vtablechg1[28] = 0U;
    __Vtablechg1[29] = 1U;
    __Vtablechg1[30] = 0U;
    __Vtablechg1[31] = 1U;
    __Vtablechg1[32] = 0U;
    __Vtablechg1[33] = 1U;
    __Vtablechg1[34] = 0U;
    __Vtablechg1[35] = 1U;
    __Vtablechg1[36] = 0U;
    __Vtablechg1[37] = 1U;
    __Vtablechg1[38] = 0U;
    __Vtablechg1[39] = 1U;
    __Vtablechg1[40] = 0U;
    __Vtablechg1[41] = 1U;
    __Vtablechg1[42] = 0U;
    __Vtablechg1[43] = 1U;
    __Vtablechg1[44] = 0U;
    __Vtablechg1[45] = 1U;
    __Vtablechg1[46] = 0U;
    __Vtablechg1[47] = 1U;
    __Vtablechg1[48] = 0U;
    __Vtablechg1[49] = 1U;
    __Vtablechg1[50] = 0U;
    __Vtablechg1[51] = 1U;
    __Vtablechg1[52] = 0U;
    __Vtablechg1[53] = 1U;
    __Vtablechg1[54] = 0U;
    __Vtablechg1[55] = 1U;
    __Vtablechg1[56] = 0U;
    __Vtablechg1[57] = 1U;
    __Vtablechg1[58] = 0U;
    __Vtablechg1[59] = 1U;
    __Vtablechg1[60] = 0U;
    __Vtablechg1[61] = 1U;
    __Vtablechg1[62] = 0U;
    __Vtablechg1[63] = 1U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[0] = 0U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[1] = 0U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[2] = 0U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[3] = 2U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[4] = 0U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[5] = 3U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[6] = 0U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[7] = 4U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[8] = 0U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[9] = 5U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[10] = 0U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[11] = 6U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[12] = 0U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[13] = 7U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[14] = 0U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[15] = 8U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[16] = 0U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[17] = 9U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[18] = 0U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[19] = 0xaU;
    __Vtable1_Tx_top__DOT__tx__DOT__state[20] = 0U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[21] = 0xbU;
    __Vtable1_Tx_top__DOT__tx__DOT__state[22] = 0U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[23] = 0U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[24] = 0U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[25] = 0U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[26] = 0U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[27] = 0U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[28] = 0U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[29] = 0U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[30] = 0U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[31] = 0U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[32] = 0U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[33] = 1U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[34] = 0U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[35] = 2U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[36] = 0U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[37] = 3U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[38] = 0U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[39] = 4U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[40] = 0U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[41] = 5U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[42] = 0U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[43] = 6U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[44] = 0U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[45] = 7U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[46] = 0U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[47] = 8U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[48] = 0U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[49] = 9U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[50] = 0U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[51] = 0xaU;
    __Vtable1_Tx_top__DOT__tx__DOT__state[52] = 0U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[53] = 0xbU;
    __Vtable1_Tx_top__DOT__tx__DOT__state[54] = 0U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[55] = 0U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[56] = 0U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[57] = 0U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[58] = 0U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[59] = 0U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[60] = 0U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[61] = 0U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[62] = 0U;
    __Vtable1_Tx_top__DOT__tx__DOT__state[63] = 0U;
    __Vdly__Tx_top__DOT__tx__DOT__state = VL_RAND_RESET_I(4);
    __VinpClk__TOP__Tx_top__DOT__bg__DOT__ck_stb = VL_RAND_RESET_I(1);
    __Vclklast__TOP__clk = VL_RAND_RESET_I(1);
    __Vclklast__TOP____VinpClk__TOP__Tx_top__DOT__bg__DOT__ck_stb = VL_RAND_RESET_I(1);
    __Vchglast__TOP__Tx_top__DOT__bg__DOT__ck_stb = VL_RAND_RESET_I(1);
    __Vm_traceActivity = VL_RAND_RESET_I(32);
}

void VTx_top::_configure_coverage(VTx_top__Syms* __restrict vlSymsp, bool first) {
    VL_DEBUG_IF(VL_PRINTF("    VTx_top::_configure_coverage\n"); );
    // Body
    if (0 && vlSymsp && first) {} // Prevent unused
}

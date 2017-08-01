// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "VTx_top__Syms.h"


//======================

void VTx_top::traceChg(VerilatedVcd* vcdp, void* userthis, uint32_t code) {
    // Callback from vcd->dump()
    VTx_top* t=(VTx_top*)userthis;
    VTx_top__Syms* __restrict vlSymsp = t->__VlSymsp; // Setup global symbol table
    if (vlSymsp->getClearActivity()) {
	t->traceChgThis (vlSymsp, vcdp, code);
    }
}

//======================


void VTx_top::traceChgThis(VTx_top__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    VTx_top* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c=code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
	if (VL_UNLIKELY((1U & (vlTOPp->__Vm_traceActivity 
			       | (vlTOPp->__Vm_traceActivity 
				  >> 1U))))) {
	    vlTOPp->traceChgThis__2(vlSymsp, vcdp, code);
	}
	if (VL_UNLIKELY((1U & (vlTOPp->__Vm_traceActivity 
			       | (vlTOPp->__Vm_traceActivity 
				  >> 3U))))) {
	    vlTOPp->traceChgThis__3(vlSymsp, vcdp, code);
	}
	if (VL_UNLIKELY((2U & vlTOPp->__Vm_traceActivity))) {
	    vlTOPp->traceChgThis__4(vlSymsp, vcdp, code);
	}
	if (VL_UNLIKELY((4U & vlTOPp->__Vm_traceActivity))) {
	    vlTOPp->traceChgThis__5(vlSymsp, vcdp, code);
	}
	if (VL_UNLIKELY((8U & vlTOPp->__Vm_traceActivity))) {
	    vlTOPp->traceChgThis__6(vlSymsp, vcdp, code);
	}
	vlTOPp->traceChgThis__7(vlSymsp, vcdp, code);
    }
    // Final
    vlTOPp->__Vm_traceActivity = 0U;
}

void VTx_top::traceChgThis__2(VTx_top__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    VTx_top* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c=code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
	vcdp->chgBus  (c+1,(vlTOPp->Tx_top__DOT__bg__DOT__counter),32);
    }
}

void VTx_top::traceChgThis__3(VTx_top__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    VTx_top* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c=code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
	vcdp->chgBit  (c+2,(vlTOPp->Tx_top__DOT__start_tx));
    }
}

void VTx_top::traceChgThis__4(VTx_top__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    VTx_top* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c=code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
	vcdp->chgBit  (c+3,(vlTOPp->Tx_top__DOT__bg__DOT__ck_stb));
    }
}

void VTx_top::traceChgThis__5(VTx_top__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    VTx_top* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c=code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
	vcdp->chgBus  (c+4,(vlTOPp->Tx_top__DOT__PISO__DOT__data_shift_reg),9);
    }
}

void VTx_top::traceChgThis__6(VTx_top__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    VTx_top* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c=code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
	vcdp->chgBus  (c+5,(vlTOPp->Tx_top__DOT__tx__DOT__state),4);
    }
}

void VTx_top::traceChgThis__7(VTx_top__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    VTx_top* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c=code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
	vcdp->chgBit  (c+6,(vlTOPp->clk));
	vcdp->chgBit  (c+7,(vlTOPp->start));
	vcdp->chgBus  (c+8,(vlTOPp->i_data),8);
	vcdp->chgBit  (c+9,(vlTOPp->serial_out));
	vcdp->chgBit  (c+10,(vlTOPp->o_busy));
	vcdp->chgBit  (c+11,((1U & VL_REDXOR_32((IData)(vlTOPp->i_data)))));
	vcdp->chgBus  (c+12,(((0x100U & (VL_REDXOR_32((IData)(vlTOPp->i_data)) 
					 << 8U)) | (IData)(vlTOPp->i_data))),9);
    }
}

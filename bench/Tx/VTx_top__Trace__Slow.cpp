// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "VTx_top__Syms.h"


//======================

void VTx_top::trace (VerilatedVcdC* tfp, int, int) {
    tfp->spTrace()->addCallback (&VTx_top::traceInit, &VTx_top::traceFull, &VTx_top::traceChg, this);
}
void VTx_top::traceInit(VerilatedVcd* vcdp, void* userthis, uint32_t code) {
    // Callback from vcd->open()
    VTx_top* t=(VTx_top*)userthis;
    VTx_top__Syms* __restrict vlSymsp = t->__VlSymsp; // Setup global symbol table
    if (!Verilated::calcUnusedSigs()) vl_fatal(__FILE__,__LINE__,__FILE__,"Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    vcdp->scopeEscape(' ');
    t->traceInitThis (vlSymsp, vcdp, code);
    vcdp->scopeEscape('.');
}
void VTx_top::traceFull(VerilatedVcd* vcdp, void* userthis, uint32_t code) {
    // Callback from vcd->dump()
    VTx_top* t=(VTx_top*)userthis;
    VTx_top__Syms* __restrict vlSymsp = t->__VlSymsp; // Setup global symbol table
    t->traceFullThis (vlSymsp, vcdp, code);
}

//======================


void VTx_top::traceInitThis(VTx_top__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    VTx_top* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c=code;
    if (0 && vcdp && c) {}  // Prevent unused
    vcdp->module(vlSymsp->name()); // Setup signal names
    // Body
    {
	vlTOPp->traceInitThis__1(vlSymsp, vcdp, code);
    }
}

void VTx_top::traceFullThis(VTx_top__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    VTx_top* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c=code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
	vlTOPp->traceFullThis__1(vlSymsp, vcdp, code);
    }
    // Final
    vlTOPp->__Vm_traceActivity = 0U;
}

void VTx_top::traceInitThis__1(VTx_top__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    VTx_top* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c=code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
	vcdp->declBit  (c+6,"clk",-1);
	vcdp->declBit  (c+7,"start",-1);
	vcdp->declBus  (c+8,"i_data",-1,7,0);
	vcdp->declBit  (c+9,"serial_out",-1);
	vcdp->declBit  (c+10,"o_busy",-1);
	vcdp->declBit  (c+6,"Tx_top clk",-1);
	vcdp->declBit  (c+7,"Tx_top start",-1);
	vcdp->declBus  (c+8,"Tx_top i_data",-1,7,0);
	vcdp->declBit  (c+9,"Tx_top serial_out",-1);
	vcdp->declBit  (c+10,"Tx_top o_busy",-1);
	vcdp->declBit  (c+3,"Tx_top baud_clk",-1);
	vcdp->declBit  (c+7,"Tx_top enable",-1);
	vcdp->declBit  (c+2,"Tx_top start_tx",-1);
	vcdp->declBit  (c+11,"Tx_top parity_bit",-1);
	vcdp->declBit  (c+6,"Tx_top tx clk",-1);
	vcdp->declBit  (c+3,"Tx_top tx baud_clk",-1);
	vcdp->declBit  (c+7,"Tx_top tx enable",-1);
	vcdp->declBus  (c+8,"Tx_top tx i_data",-1,7,0);
	vcdp->declBit  (c+10,"Tx_top tx o_busy",-1);
	vcdp->declBit  (c+2,"Tx_top tx start_tx",-1);
	vcdp->declBus  (c+5,"Tx_top tx state",-1,3,0);
	vcdp->declBit  (c+6,"Tx_top bg clk",-1);
	vcdp->declBit  (c+3,"Tx_top bg baud_clk",-1);
	vcdp->declBit  (c+3,"Tx_top bg ck_stb",-1);
	vcdp->declBus  (c+1,"Tx_top bg counter",-1,31,0);
	vcdp->declBit  (c+3,"Tx_top PISO clk",-1);
	vcdp->declBit  (c+2,"Tx_top PISO valid",-1);
	vcdp->declBus  (c+12,"Tx_top PISO data_in",-1,8,0);
	vcdp->declBit  (c+9,"Tx_top PISO data_out",-1);
	vcdp->declBus  (c+4,"Tx_top PISO data_shift_reg",-1,8,0);
    }
}

void VTx_top::traceFullThis__1(VTx_top__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    VTx_top* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c=code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
	vcdp->fullBus  (c+1,(vlTOPp->Tx_top__DOT__bg__DOT__counter),32);
	vcdp->fullBit  (c+2,(vlTOPp->Tx_top__DOT__start_tx));
	vcdp->fullBit  (c+3,(vlTOPp->Tx_top__DOT__bg__DOT__ck_stb));
	vcdp->fullBus  (c+4,(vlTOPp->Tx_top__DOT__PISO__DOT__data_shift_reg),9);
	vcdp->fullBus  (c+5,(vlTOPp->Tx_top__DOT__tx__DOT__state),4);
	vcdp->fullBit  (c+6,(vlTOPp->clk));
	vcdp->fullBit  (c+7,(vlTOPp->start));
	vcdp->fullBus  (c+8,(vlTOPp->i_data),8);
	vcdp->fullBit  (c+9,(vlTOPp->serial_out));
	vcdp->fullBit  (c+10,(vlTOPp->o_busy));
	vcdp->fullBit  (c+11,((1U & VL_REDXOR_32((IData)(vlTOPp->i_data)))));
	vcdp->fullBus  (c+12,(((0x100U & (VL_REDXOR_32((IData)(vlTOPp->i_data)) 
					  << 8U)) | (IData)(vlTOPp->i_data))),9);
    }
}

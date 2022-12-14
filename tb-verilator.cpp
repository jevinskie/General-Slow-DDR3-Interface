#include <VslowDDR3_tb.h>
#include <unistd.h>
#include <verilated.h>

vluint64_t main_time = 0;
double sc_time_stamp() {
    return main_time;
}

int main(int argc, char *argv[]) {
    Verilated::commandArgs(argc, argv);
    VslowDDR3_tb *top = new VslowDDR3_tb;
    while (!Verilated::gotFinish()) {
        top->eval();
        main_time = top->nextTimeSlot();
    }
    top->final();
    delete top;
    return 0;
}

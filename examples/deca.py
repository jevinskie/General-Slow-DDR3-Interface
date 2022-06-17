#!/usr/bin/env python3

# Copyright (c) 2022 Jevin Sweval <jevinsweval@gmail.com>
# SPDX-License-Identifier: BSD-2-Clause


import argparse
import os

from litex.soc.cores.clock import *
from litex.soc.cores.led import LedChaser
from litex.soc.integration.builder import *
from litex.soc.integration.soc_core import *
from litex.soc.interconnect import stream
from litex.soc.interconnect.csr import *
from litex_boards.platforms import terasic_deca
from litex_boards.targets.terasic_deca import _CRG
from migen import *


# Base SoC -----------------------------------------------------------------------------------------

class BaseSoC(SoCCore):
    def __init__(
        self, with_jtagbone=False, with_uartbone=True, with_analyzer=True, sys_clk_freq=int(100e6), **kwargs
    ):
        platform = terasic_deca.Platform()

        # SoCCore ----------------------------------------------------------------------------------
        SoCCore.__init__(
            self,
            platform,
            clk_freq=sys_clk_freq,
            ident="litelitedram example on on MAX10 DECA",
            **kwargs,
        )

        # CRG --------------------------------------------------------------------------------------
        self.submodules.crg = _CRG(platform, sys_clk_freq)

        # Slow DDR3 --------------------------------------------------------------------------------
        # ddr3_pads = platform.request("ddram")

        # JTAGbone ---------------------------------------------------------------------------------
        if with_jtagbone:
            self.add_jtagbone()

        # UARTbone ---------------------------------------------------------------------------------
        if with_uartbone:
            self.add_uartbone("gpio_serial", sys_clk_freq, baudrate=kwargs["uart_baudrate"])

        # scope ------------------------------------------------------------------------------------
        if with_analyzer:
            from litescope import LiteScopeAnalyzer

            analyzer_signals = [
                Signal(),
                # ddr3_pads,
            ]
            self.submodules.analyzer = LiteScopeAnalyzer(
                analyzer_signals,
                depth=1024,
                clock_domain="sys",
                rle_nbits_min=15,
                csr_csv="analyzer.csv",
            )

        # LEDs -------------------------------------------------------------------------------------
        self.submodules.leds = LedChaser(
            pads=platform.request_remaining("user_led"), sys_clk_freq=sys_clk_freq
        )


# Main ---------------------------------------------------------------------------------------------

def main():
    from litex.soc.integration.soc import LiteXSoCArgumentParser
    parser = LiteXSoCArgumentParser(description="litelitedram example on on MAX10 DECA")
    target_group = parser.add_argument_group(title="Target options")
    target_group.add_argument("--build", action="store_true", help="Build bitstream")
    target_group.add_argument("--load", action="store_true", help="Load bitstream")
    target_group.add_argument("--with-analyzer", action="store_true", help="Enable litescope")
    builder_args(parser)
    soc_core_args(parser)
    args = parser.parse_args()

    soc_kwargs = soc_core_argdict(args)
    soc_kwargs["uart_name"] = "crossover"
    soc_kwargs["uart_baudrate"] = 2_000_000

    soc = BaseSoC(
        with_analyzer=args.with_analyzer,
        **soc_kwargs,
    )
    builder = Builder(soc, csr_csv="csr.csv")
    builder.build(run=args.build, verbose=False)

    if args.load:
        prog = soc.platform.create_programmer()
        prog.load_bitstream(os.path.join(builder.gateware_dir, soc.build_name + ".sof"))


if __name__ == "__main__":
    main()

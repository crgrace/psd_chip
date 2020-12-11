// File Name: regfile_assign.sv
// Engineer:  Carl Grace (crgrace@lbl.gov)
// Description:  Code used in regfile.sv for assignment
//          
///////////////////////////////////////////////////////////////////

        for (int i = 0; i < 64; i++) begin
            config_bits[PIXEL_TRIM + i] <= 8'h10;
        end        
        config_bits[GLOBAL_THRESH] <= 8'hFF;
        config_bits[CSA_CTRL] <= 8'h04;
        for (int i = 0; i < 8; i++) begin
            config_bits[CSA_ENABLE + i] <= 8'h00;
        end
        config_bits[IBIAS_TDAC] <= 8'h08;
        config_bits[IBIAS_COMP] <= 8'h08;
        config_bits[IBIAS_BUFFER] <= 8'h08;
        config_bits[IBIAS_CSA] <= 8'h08;
        config_bits[IBIAS_VREF] <= 8'h08;
        config_bits[IBIAS_VCM] <= 8'h08;
        config_bits[IBIAS_TPULSE] <= 8'h05;
        config_bits[REFGEN] <= 8'h10;
        config_bits[DAC_VREF] <= 8'hDB;
        config_bits[DAC_VCM] <= 8'h4D;
        for (int i = 0; i < 8; i++) begin
            config_bits[BYPASS_SELECT + i] <= 8'h00;
        end
        for (int i = 0; i < 8; i++) begin
            config_bits[CSA_MONITOR_SEL + i] <= 8'h00;
        end
        for (int i = 0; i < 8; i++) begin
            config_bits[CSA_TEST_ENABLE + i] <= 8'hFF;
        end
        config_bits[CSA_TEST_DAC] <= 8'h00;
        config_bits[IMONITOR0] <= 8'h00;
        config_bits[IMONITOR1] <= 8'h00;
        config_bits[IMONITOR2] <= 8'h00;
        config_bits[IMONITOR3] <= 8'h00;
        config_bits[VMONITOR0] <= 8'h00;
        config_bits[VMONITOR1] <= 8'h00;
        config_bits[VMONITOR2] <= 8'h00;
        config_bits[VMONITOR3] <= 8'h00;
        config_bits[VMONITOR4] <= 8'h00;
        config_bits[DMONITOR0] <= 8'h00;
        config_bits[DMONITOR1] <= 8'h00;
        for (int i = 0; i < 2; i++) begin
            config_bits[ADC_HOLD_DELAY + i] <= 8'h00;
        end
        config_bits[CHIP_ID] <= 8'h01;
        config_bits[DIGITAL] <= 8'h40;
        config_bits[ENABLE_PISO_UP] <= 8'h00;
        config_bits[ENABLE_PISO_DOWN] <= 8'h00;
        config_bits[ENABLE_POSI] <= 8'h0F;
        config_bits[UART_TEST_MODE] <= 8'h00;
        config_bits[ENABLE_TRIG_MODES] <= 8'h60;
        config_bits[SHADOW_RESET_LENGTH] <= 8'h00;
        config_bits[ADC_BURST] <= 8'h00;
        for (int i = 0; i< 8; i++) begin
            config_bits[CHANNEL_MASK + i] <= 8'hFF;
        end
        for (int i = 0; i < 8; i++) begin
            config_bits[EXTERN_TRIG_MASK + i] <= 8'hFF;
        end
        for (int i = 0; i < 8; i++) begin
            config_bits[CROSS_TRIG_MASK + i] <= 8'hFF;
        end
        for (int i = 0; i < 8; i++) begin
            config_bits[PER_TRIG_MASK + i] <= 8'hFF;
        end
        for (int i = 0; i < 3; i++) begin
            if (i == 1)
                config_bits[RESET_CYCLES + i] <= 8'h10;
            else
                config_bits[RESET_CYCLES + i] <= 8'h00;
        end
        for (int i = 0; i < 4; i++) begin
            config_bits[PER_TRIG_CYC + i] <= 8'h0;
        end
        config_bits[ENABLE_ADC_MODES] <= 8'h4C;
        config_bits[MIN_DELTA_ADC] <= 8'b00;
        config_bits[RESET_THRESHOLD] <= 8'h00;
        for (int i = 0; i < 64; i++) begin
            config_bits[DIGITAL_THRESHOLD + i] <= 8'b00;
        end
        config_bits[LIGHTPIX0] <= 8'h20;
        config_bits[LIGHTPIX1] <= 8'h1E;
        config_bits[TRX0] <= 8'h88;
        config_bits[TRX1] <= 8'h88;
        config_bits[TRX2] <= 8'hCC;
        config_bits[TRX3] <= 8'hCC;
        config_bits[TRX4] <= 8'h88;
        config_bits[TRX5] <= 8'h88;
        config_bits[TRX6] <= 8'h88;
        config_bits[TRX7] <= 8'h08;
        config_bits[TRX8] <= 8'h04;
        config_bits[TRX9] <= 8'h04;
        config_bits[TRX10] <= 8'h04;
        config_bits[TRX11] <= 8'h04;
        config_bits[TRX12] <= 8'h00;
        config_bits[TRX13] <= 8'h00;
        config_bits[TRX14] <= 8'h00;
        config_bits[TRX15] <= 8'h55;
        config_bits[TRX16] <= 8'h55;


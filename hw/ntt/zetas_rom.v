`timescale 1ns/1ps

module zetas_rom (
    input  [6:0] addr,
    output signed [15:0] data
);

    function [15:0] get_zeta(input [6:0] idx);
        case (idx)

        7'd0: get_zeta = -16'd1044;
        7'd1: get_zeta = -16'd758;
        7'd2: get_zeta = -16'd359;
        7'd3: get_zeta = -16'd1517;
        7'd4: get_zeta = 16'd1493;
        7'd5: get_zeta = 16'd1422;
        7'd6: get_zeta = 16'd287;
        7'd7: get_zeta = 16'd202;
        7'd8: get_zeta = -16'd171;
        7'd9: get_zeta = 16'd622;
        7'd10: get_zeta = 16'd1577;
        7'd11: get_zeta = 16'd182;
        7'd12: get_zeta = 16'd962;
        7'd13: get_zeta = -16'd1202;
        7'd14: get_zeta = -16'd1474;
        7'd15: get_zeta = 16'd1468;
        7'd16: get_zeta = 16'd573;
        7'd17: get_zeta = -16'd1325;
        7'd18: get_zeta = 16'd264;
        7'd19: get_zeta = 16'd383;
        7'd20: get_zeta = -16'd829;
        7'd21: get_zeta = 16'd1458;
        7'd22: get_zeta = -16'd1602;
        7'd23: get_zeta = -16'd130;
        7'd24: get_zeta = -16'd681;
        7'd25: get_zeta = 16'd1017;
        7'd26: get_zeta = 16'd732;
        7'd27: get_zeta = 16'd608;
        7'd28: get_zeta = -16'd1542;
        7'd29: get_zeta = 16'd411;
        7'd30: get_zeta = -16'd205;
        7'd31: get_zeta = -16'd1571;
        7'd32: get_zeta = 16'd1223;
        7'd33: get_zeta = 16'd652;
        7'd34: get_zeta = -16'd552;
        7'd35: get_zeta = 16'd1015;
        7'd36: get_zeta = -16'd1293;
        7'd37: get_zeta = 16'd1491;
        7'd38: get_zeta = -16'd282;
        7'd39: get_zeta = -16'd1544;
        7'd40: get_zeta = 16'd516;
        7'd41: get_zeta = -16'd8;
        7'd42: get_zeta = -16'd320;
        7'd43: get_zeta = -16'd666;
        7'd44: get_zeta = -16'd1618;
        7'd45: get_zeta = -16'd1162;
        7'd46: get_zeta = 16'd126;
        7'd47: get_zeta = 16'd1469;
        7'd48: get_zeta = -16'd853;
        7'd49: get_zeta = -16'd90;
        7'd50: get_zeta = -16'd271;
        7'd51: get_zeta = 16'd830;
        7'd52: get_zeta = 16'd107;
        7'd53: get_zeta = -16'd1421;
        7'd54: get_zeta = -16'd247;
        7'd55: get_zeta = -16'd951;
        7'd56: get_zeta = -16'd398;
        7'd57: get_zeta = 16'd961;
        7'd58: get_zeta = -16'd1508;
        7'd59: get_zeta = -16'd725;
        7'd60: get_zeta = 16'd448;
        7'd61: get_zeta = -16'd1065;
        7'd62: get_zeta = 16'd677;
        7'd63: get_zeta = -16'd1275;
        7'd64: get_zeta = -16'd1103;
        7'd65: get_zeta = 16'd430;
        7'd66: get_zeta = 16'd555;
        7'd67: get_zeta = 16'd843;
        7'd68: get_zeta = -16'd1251;
        7'd69: get_zeta = 16'd871;
        7'd70: get_zeta = 16'd1550;
        7'd71: get_zeta = 16'd105;
        7'd72: get_zeta = 16'd422;
        7'd73: get_zeta = 16'd587;
        7'd74: get_zeta = 16'd177;
        7'd75: get_zeta = -16'd235;
        7'd76: get_zeta = -16'd291;
        7'd77: get_zeta = -16'd460;
        7'd78: get_zeta = 16'd1574;
        7'd79: get_zeta = 16'd1653;
        7'd80: get_zeta = -16'd246;
        7'd81: get_zeta = 16'd778;
        7'd82: get_zeta = 16'd1159;
        7'd83: get_zeta = -16'd147;
        7'd84: get_zeta = -16'd777;
        7'd85: get_zeta = 16'd1483;
        7'd86: get_zeta = -16'd602;
        7'd87: get_zeta = 16'd1119;
        7'd88: get_zeta = -16'd1590;
        7'd89: get_zeta = 16'd644;
        7'd90: get_zeta = -16'd872;
        7'd91: get_zeta = 16'd349;
        7'd92: get_zeta = 16'd418;
        7'd93: get_zeta = 16'd329;
        7'd94: get_zeta = -16'd156;
        7'd95: get_zeta = -16'd75;
        7'd96: get_zeta = 16'd817;
        7'd97: get_zeta = 16'd1097;
        7'd98: get_zeta = 16'd603;
        7'd99: get_zeta = 16'd610;
        7'd100: get_zeta = 16'd1322;
        7'd101: get_zeta = -16'd1285;
        7'd102: get_zeta = -16'd1465;
        7'd103: get_zeta = 16'd384;
        7'd104: get_zeta = -16'd1215;
        7'd105: get_zeta = -16'd136;
        7'd106: get_zeta = 16'd1218;
        7'd107: get_zeta = -16'd1335;
        7'd108: get_zeta = -16'd874;
        7'd109: get_zeta = 16'd220;
        7'd110: get_zeta = -16'd1187;
        7'd111: get_zeta = -16'd1659;
        7'd112: get_zeta = -16'd1185;
        7'd113: get_zeta = -16'd1530;
        7'd114: get_zeta = -16'd1278;
        7'd115: get_zeta = 16'd794;
        7'd116: get_zeta = -16'd1510;
        7'd117: get_zeta = -16'd854;
        7'd118: get_zeta = -16'd870;
        7'd119: get_zeta = 16'd478;
        7'd120: get_zeta = -16'd108;
        7'd121: get_zeta = -16'd308;
        7'd122: get_zeta = 16'd996;
        7'd123: get_zeta = 16'd991;
        7'd124: get_zeta = 16'd958;
        7'd125: get_zeta = -16'd1460;
        7'd126: get_zeta = 16'd1522;
        default: get_zeta = 16'd1628;  // idx=127
        endcase
    endfunction

    assign data = $signed(get_zeta(addr));

endmodule

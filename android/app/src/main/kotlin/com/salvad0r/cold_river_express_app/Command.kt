package com.salvad0r.cold_river_express_app

object Command {
    private const val ESC: Byte = 0x1B
    private const val FS: Byte = 0x1C
    private const val GS: Byte = 0x1D
    private const val US: Byte = 0x1F
    private const val DLE: Byte = 0x10
    private const val DC4: Byte = 0x14
    private const val DC1: Byte = 0x11
    private const val SP: Byte = 0x20
    private const val NL: Byte = 0x0A
    private const val FF: Byte = 0x0C

    const val PIECE: Byte = 0xFF.toByte()
    const val NUL: Byte = 0x00.toByte()

    // Printer Initialization
    val ESC_Init = byteArrayOf(ESC, '@'.code.toByte())
    // Print commands
    val LF = byteArrayOf(NL)
    val ESC_J = byteArrayOf(ESC, 'J'.code.toByte(), 0x00)
    val ESC_d = byteArrayOf(ESC, 'd'.code.toByte(), 0x00)
    val US_vt_eot = byteArrayOf(US, DC1, 0x04)
    val ESC_B_m_n = byteArrayOf(ESC, 'B'.code.toByte(), 0x00, 0x00)
    val GS_V_n = byteArrayOf(GS, 'V'.code.toByte(), 0x00)
    val GS_V_m_n = byteArrayOf(GS, 'V'.code.toByte(), 'B'.code.toByte(), 0x00)
    val GS_i = byteArrayOf(ESC, 'i'.code.toByte())
    val GS_m = byteArrayOf(ESC, 'm'.code.toByte())

    // Character settings
    val ESC_SP = byteArrayOf(ESC, SP, 0x00)
    val ESC_ExclamationMark = byteArrayOf(ESC, '!'.code.toByte(), 0x00)
    val GS_ExclamationMark = byteArrayOf(GS, '!'.code.toByte(), 0x00)
    val GS_B = byteArrayOf(GS, 'B'.code.toByte(), 0x00)
    val ESC_V = byteArrayOf(ESC, 'V'.code.toByte(), 0x00)
    val ESC_M = byteArrayOf(ESC, 'M'.code.toByte(), 0x00)
    val ESC_G = byteArrayOf(ESC, 'G'.code.toByte(), 0x00)
    val ESC_E = byteArrayOf(ESC, 'E'.code.toByte(), 0x00)
    val ESC_LeftBrace = byteArrayOf(ESC, '{'.code.toByte(), 0x00)
    val ESC_Minus = byteArrayOf(ESC, 45, 0x00)
    val FS_dot = byteArrayOf(FS, 46)
    val FS_and = byteArrayOf(FS, '&'.code.toByte())
    val FS_ExclamationMark = byteArrayOf(FS, '!'.code.toByte(), 0x00)
    val FS_Minus = byteArrayOf(FS, 45, 0x00)
    val FS_S = byteArrayOf(FS, 'S'.code.toByte(), 0x00, 0x00)
    val ESC_t = byteArrayOf(ESC, 't'.code.toByte(), 0x00)

    // Formatting commands
    val ESC_Two = byteArrayOf(ESC, 50)
    val ESC_Three = byteArrayOf(ESC, 51, 0x00)
    val ESC_Align = byteArrayOf(ESC, 'a'.code.toByte(), 0x00)
    val GS_LeftSp = byteArrayOf(GS, 'L'.code.toByte(), 0x00, 0x00)
    val ESC_Relative = byteArrayOf(ESC, '$'.code.toByte(), 0x00, 0x00)
    val ESC_Absolute = byteArrayOf(ESC, 92, 0x00, 0x00)
    val GS_W = byteArrayOf(GS, 'W'.code.toByte(), 0x00, 0x00)

    // Status commands
    val DLE_eot = byteArrayOf(DLE, 0x04, 0x00)
    val DLE_DC4 = byteArrayOf(DLE, DC4, 0x00, 0x00, 0x00)
    val ESC_p = byteArrayOf(ESC, 'F'.code.toByte(), 0x00, 0x00, 0x00)

    // Barcode commands
    val GS_H = byteArrayOf(GS, 'H'.code.toByte(), 0x00)
    val GS_h = byteArrayOf(GS, 'h'.code.toByte(), 0xA2.toByte())
    val GS_w = byteArrayOf(GS, 'w'.code.toByte(), 0x00)
    val GS_f = byteArrayOf(GS, 'f'.code.toByte(), 0x00)
    val GS_x = byteArrayOf(GS, 'x'.code.toByte(), 0x00)
    val GS_k = byteArrayOf(GS, 'k'.code.toByte(), 'A'.code.toByte(), FF)

    // QR code related commands
    val GS_k_m_v_r_nL_nH = byteArrayOf(ESC, 'Z'.code.toByte(), 0x03, 0x03, 0x08, 0x00, 0x00)
}
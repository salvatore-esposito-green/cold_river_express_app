package com.salvad0r.cold_river_express_app

import java.io.UnsupportedEncodingException
import com.salvad0r.cold_river_express_app.Utils
import com.salvad0r.cold_river_express_app.Command

object PrinterCommand {

    fun POS_Set_PrtInit(): ByteArray {
        return Utils.byteArraysToBytes(arrayOf(Command.ESC_Init))
    }

    fun POS_Set_LF(): ByteArray {
        return Utils.byteArraysToBytes(arrayOf(Command.LF))
    }

    fun POS_Set_PrtAndFeedPaper(feed: Int): ByteArray? {
        if (feed !in 0..255) return null
        Command.ESC_J[2] = feed.toByte()
        return Utils.byteArraysToBytes(arrayOf(Command.ESC_J))
    }

    fun POS_Set_PrtSelfTest(): ByteArray {
        return Utils.byteArraysToBytes(arrayOf(Command.US_vt_eot))
    }

    fun POS_Set_Beep(m: Int, t: Int): ByteArray? {
        if (m !in 1..9 || t !in 1..9) return null
        Command.ESC_B_m_n[2] = m.toByte()
        Command.ESC_B_m_n[3] = t.toByte()
        return Utils.byteArraysToBytes(arrayOf(Command.ESC_B_m_n))
    }

    fun POS_Set_Cut(cut: Int): ByteArray? {
        if (cut !in 0..255) return null
        Command.GS_V_m_n[3] = cut.toByte()
        return Utils.byteArraysToBytes(arrayOf(Command.GS_V_m_n))
    }

    fun POS_Set_Cashbox(nMode: Int, nTime1: Int, nTime2: Int): ByteArray? {
        if (nMode !in 0..1 || nTime1 !in 0..255 || nTime2 !in 0..255) return null
        Command.ESC_p[2] = nMode.toByte()
        Command.ESC_p[3] = nTime1.toByte()
        Command.ESC_p[4] = nTime2.toByte()
        return Utils.byteArraysToBytes(arrayOf(Command.ESC_p))
    }

    fun POS_Set_Absolute(absolute: Int): ByteArray? {
        if (absolute !in 0..65535) return null
        Command.ESC_Relative[2] = (absolute % 0x100).toByte()
        Command.ESC_Relative[3] = (absolute / 0x100).toByte()
        return Utils.byteArraysToBytes(arrayOf(Command.ESC_Relative))
    }

    fun POS_Set_Relative(relative: Int): ByteArray? {
        if (relative !in 0..65535) return null
        Command.ESC_Absolute[2] = (relative % 0x100).toByte()
        Command.ESC_Absolute[3] = (relative / 0x100).toByte()
        return Utils.byteArraysToBytes(arrayOf(Command.ESC_Absolute))
    }

    fun POS_Set_LeftSP(left: Int): ByteArray? {
        if (left !in 0..255) return null
        Command.GS_LeftSp[2] = (left % 100).toByte()
        Command.GS_LeftSp[3] = (left / 100).toByte()
        return Utils.byteArraysToBytes(arrayOf(Command.GS_LeftSp))
    }

    fun POS_S_Align(align: Int): ByteArray? {
        if (align !in 0..2 || align !in 48..50) return null
        return Command.ESC_Align.apply { this[2] = align.toByte() }
    }

    fun POS_Set_PrintWidth(width: Int): ByteArray? {
        if (width !in 0..255) return null
        Command.GS_W[2] = (width % 100).toByte()
        Command.GS_W[3] = (width / 100).toByte()
        return Utils.byteArraysToBytes(arrayOf(Command.GS_W))
    }

    fun POS_Set_DefLineSpace(): ByteArray {
        return Command.ESC_Two
    }

    fun POS_Set_LineSpace(space: Int): ByteArray? {
        if (space !in 0..255) return null
        Command.ESC_Three[2] = space.toByte()
        return Utils.byteArraysToBytes(arrayOf(Command.ESC_Three))
    }

    fun POS_Set_CodePage(page: Int): ByteArray? {
        if (page > 255) return null
        Command.ESC_t[2] = page.toByte()
        return Utils.byteArraysToBytes(arrayOf(Command.ESC_t))
    }

    fun POS_Print_Text(
        pszString: String,
        encoding: String,
        codepage: Int,
        nWidthTimes: Int,
        nHeightTimes: Int,
        nFontType: Int
    ): ByteArray? {
        if (codepage !in 0..255 || pszString.isEmpty()) return null

        val pbString: ByteArray = try {
            pszString.toByteArray(charset(encoding))
        } catch (e: UnsupportedEncodingException) {
            return null
        }

        val intToWidth = byteArrayOf(0x00, 0x10, 0x20, 0x30)
        val intToHeight = byteArrayOf(0x00, 0x01, 0x02, 0x03)

        Command.GS_ExclamationMark[2] = (intToWidth[nWidthTimes] + intToHeight[nHeightTimes]).toByte()
        Command.ESC_t[2] = codepage.toByte()
        Command.ESC_M[2] = nFontType.toByte()

        return if (codepage == 0) {
            Utils.byteArraysToBytes(arrayOf(Command.GS_ExclamationMark, Command.ESC_t, Command.FS_and, Command.ESC_M, pbString))
        } else {
            Utils.byteArraysToBytes(arrayOf(Command.GS_ExclamationMark, Command.ESC_t, Command.FS_dot, Command.ESC_M, pbString))
        }
    }

    fun POS_Set_Bold(bold: Int): ByteArray {
        Command.ESC_E[2] = bold.toByte()
        Command.ESC_G[2] = bold.toByte()
        return Utils.byteArraysToBytes(arrayOf(Command.ESC_E, Command.ESC_G))
    }

    fun POS_Set_LeftBrace(brace: Int): ByteArray {
        Command.ESC_LeftBrace[2] = brace.toByte()
        return Utils.byteArraysToBytes(arrayOf(Command.ESC_LeftBrace))
    }

    fun POS_Set_UnderLine(line: Int): ByteArray? {
        if (line !in 0..2) return null
        Command.ESC_Minus[2] = line.toByte()
        Command.FS_Minus[2] = line.toByte()
        return Utils.byteArraysToBytes(arrayOf(Command.ESC_Minus, Command.FS_Minus))
    }

    fun POS_Set_FontSize(size1: Int, size2: Int): ByteArray? {
        if (size1 !in 0..7 || size2 !in 0..7) return null
        val intToWidth = byteArrayOf(0x00, 0x10, 0x20, 0x30, 0x40, 0x50, 0x60, 0x70)
        val intToHeight = byteArrayOf(0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07)
        Command.GS_ExclamationMark[2] = (intToWidth[size1] + intToHeight[size2]).toByte()
        return Utils.byteArraysToBytes(arrayOf(Command.GS_ExclamationMark))
    }

    fun POS_Set_Inverse(inverse: Int): ByteArray {
        Command.GS_B[2] = inverse.toByte()
        return Utils.byteArraysToBytes(arrayOf(Command.GS_B))
    }

    fun POS_Set_Rotate(rotate: Int): ByteArray? {
        if (rotate !in 0..1) return null
        Command.ESC_V[2] = rotate.toByte()
        return Utils.byteArraysToBytes(arrayOf(Command.ESC_V))
    }

    fun POS_Set_ChoseFont(font: Int): ByteArray? {
        if (font !in 0..1) return null
        Command.ESC_M[2] = font.toByte()
        return Utils.byteArraysToBytes(arrayOf(Command.ESC_M))
    }
}
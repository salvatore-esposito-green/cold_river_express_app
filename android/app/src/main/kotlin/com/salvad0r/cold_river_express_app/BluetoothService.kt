package com.salvad0r.cold_river_express_app

import android.bluetooth.*
import android.content.Context
import android.os.Bundle
import android.os.Handler
import android.os.Message
import android.util.Log
import java.io.IOException
import java.io.InputStream
import java.io.OutputStream
import java.util.*

class BluetoothService(private val context: Context, private val handler: Handler) {
    private val adapter: BluetoothAdapter? = (context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager).adapter
    private var acceptThread: AcceptThread? = null
    private var connectThread: ConnectThread? = null
    private var connectedThread: ConnectedThread? = null
    private var state: Int = STATE_NONE

    @Synchronized
    private fun setState(newState: Int) {
        Log.d(TAG, "setState() $state -> $newState")
        state = newState
    }

    @Synchronized
    fun getState(): Int = state

    @Synchronized
    fun start() {
        Log.d(TAG, "start")

        connectThread?.cancel()
        connectThread = null

        connectedThread?.cancel()
        connectedThread = null

        if (acceptThread == null) {
            acceptThread = AcceptThread().apply { start() }
        }

        setState(STATE_LISTEN)
    }

    @Synchronized
    fun connect(device: BluetoothDevice) {
        Log.d(TAG, "connect to: $device")

        if (state == STATE_CONNECTING) {
            connectThread?.cancel()
            connectThread = null
        }

        connectedThread?.cancel()
        connectedThread = null

        connectThread = ConnectThread(device).apply { start() }
        setState(STATE_CONNECTING)
    }

    @Synchronized
    fun connected(socket: BluetoothSocket, device: BluetoothDevice) {
        Log.d(TAG, "connected")

        connectThread?.cancel()
        connectThread = null

        connectedThread?.cancel()
        connectedThread = null

        acceptThread?.cancel()
        acceptThread = null

        connectedThread = ConnectedThread(socket).apply { start() }

        val msg = handler.obtainMessage()
        val bundle = Bundle().apply { putString("Device Name", device.name) }
        msg.data = bundle
        handler.sendMessage(msg)

        setState(STATE_CONNECTED)
    }

    @Synchronized
    fun stop() {
        Log.d(TAG, "stop")
        setState(STATE_NONE)

        connectThread?.cancel()
        connectThread = null

        connectedThread?.cancel()
        connectedThread = null

        acceptThread?.cancel()
        acceptThread = null
    }

    fun write(out: ByteArray) {
        val r: ConnectedThread?
        synchronized(this) {
            if (state != STATE_CONNECTED) return
            r = connectedThread
        }
        r?.write(out)
    }

    private fun connectionFailed() {
        setState(STATE_LISTEN)
        val msg = handler.obtainMessage()
        val bundle = Bundle().apply { putString("Toast", "Unable to connect device") }
        msg.data = bundle
        handler.sendMessage(msg)
    }

    private fun connectionLost() {
        val msg = handler.obtainMessage()
        val bundle = Bundle().apply { putString("Toast", "Device connection was lost") }
        msg.data = bundle
        handler.sendMessage(msg)
    }

    private inner class AcceptThread : Thread() {
        private val serverSocket: BluetoothServerSocket? =
            adapter?.listenUsingRfcommWithServiceRecord(NAME, MY_UUID)

        override fun run() {
            Log.d(TAG, "BEGIN mAcceptThread$this")
            name = "AcceptThread"
            var socket: BluetoothSocket?

            while (this@BluetoothService.state != STATE_CONNECTED) {
                try {
                    socket = serverSocket?.accept()
                    socket?.let {
                        synchronized(this@BluetoothService) {
                            when (this@BluetoothService.state) {  // Explicit reference to BluetoothService's state
                                STATE_LISTEN, STATE_CONNECTING -> connected(it, it.remoteDevice)
                                STATE_NONE, STATE_CONNECTED -> it.close()
                                else -> it.close()
                            }
                        }
                    }
                } catch (e: IOException) {
                    Log.e(TAG, "accept() failed", e)
                    break
                }
            }
            Log.i(TAG, "END mAcceptThread")
        }

        fun cancel() {
            try {
                serverSocket?.close()
            } catch (e: IOException) {
                Log.e(TAG, "close() of server failed", e)
            }
        }
    }

    private inner class ConnectThread(private val device: BluetoothDevice) : Thread() {
        private val socket: BluetoothSocket? =
            try {
                device.createRfcommSocketToServiceRecord(MY_UUID)
            } catch (e: IOException) {
                Log.e(TAG, "create() failed", e)
                null
            }

        override fun run() {
            Log.i(TAG, "BEGIN mConnectThread")
            name = "ConnectThread"
            adapter?.cancelDiscovery()

            try {
                socket?.connect()
            } catch (e: IOException) {
                connectionFailed()
                try {
                    socket?.close()
                } catch (e2: IOException) {
                    Log.e(TAG, "unable to close() socket during connection failure", e2)
                }
                this@BluetoothService.start()
                return
            }

            synchronized(this@BluetoothService) {
                connectThread = null
            }

            connected(socket!!, device)
        }

        fun cancel() {
            try {
                socket?.close()
            } catch (e: IOException) {
                Log.e(TAG, "close() of connect socket failed", e)
            }
        }
    }

    private inner class ConnectedThread(private val socket: BluetoothSocket) : Thread() {
        private val inStream: InputStream? = socket.inputStream
        private val outStream: OutputStream? = socket.outputStream

        override fun run() {
            Log.i(TAG, "BEGIN mConnectedThread")
            val buffer = ByteArray(256)

            while (true) {
                try {
                    val bytes = inStream?.read(buffer) ?: -1
                    if (bytes > 0) {
                        
                    } else {
                        Log.e(TAG, "disconnected")
                        connectionLost()
                        if (this@BluetoothService.state != STATE_NONE) this@BluetoothService.start()
                        break
                    }
                } catch (e: IOException) {
                    Log.e(TAG, "disconnected", e)
                    connectionLost()
                    if (this@BluetoothService.state != STATE_NONE) this@BluetoothService.start()
                    break
                }
            }
        }

        fun write(buffer: ByteArray) {
            try {
                outStream?.write(buffer)
                outStream?.flush()
                Log.i("BTPWRITE", String(buffer, charset("GBK")))
            } catch (e: IOException) {
                Log.e(TAG, "Exception during write", e)
            }
        }

        fun cancel() {
            try {
                socket.close()
            } catch (e: IOException) {
                Log.e(TAG, "close() of connect socket failed", e)
            }
        }
    }

    companion object {
        private const val TAG = "BluetoothService"
        private const val NAME = "ZJPrinter"
        private val MY_UUID: UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")

        const val STATE_NONE = 0
        const val STATE_LISTEN = 1
        const val STATE_CONNECTING = 2
        const val STATE_CONNECTED = 3

        var ErrorMessage = "No_Error_Message"
    }
}